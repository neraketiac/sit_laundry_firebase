import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/services/database_loyalty.dart';
import 'package:laundry_firebase/features/customers/models/customermodel.dart';
import 'package:laundry_firebase/features/customers/repository/customer_repository.dart';
import 'package:web/web.dart' as web;

class CustomerLocationPage extends StatefulWidget {
  const CustomerLocationPage({super.key});

  @override
  State<CustomerLocationPage> createState() => _CustomerLocationPageState();
}

class _CustomerLocationPageState extends State<CustomerLocationPage> {
  double? _lat;
  double? _lng;
  bool _mapVisible = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final String _mapId =
      'customer-pin-map-${DateTime.now().millisecondsSinceEpoch}';
  late web.HTMLIFrameElement _iframe;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initMap() {
    const defaultLat = 14.5995;
    const defaultLng = 120.9842;

    final html = _buildHtml(defaultLat, defaultLng);
    final blob = web.Blob(
      [html.toJS].toJS,
      web.BlobPropertyBag(type: 'text/html'),
    );
    final url = web.URL.createObjectURL(blob);

    _iframe = web.HTMLIFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';

    web.window.addEventListener(
        'message',
        (web.Event e) {
          final msg = e as web.MessageEvent;
          final data = msg.data.dartify();
          if (data == 'map-ready') {
            // map ready
          } else if (data is Map) {
            final lat = (data['lat'] as num?)?.toDouble();
            final lng = (data['lng'] as num?)?.toDouble();
            if (lat != null && lng != null) {
              setState(() {
                _lat = lat;
                _lng = lng;
              });
            }
          }
        }.toJS);

    ui_web.platformViewRegistry.registerViewFactory(_mapId, (_) => _iframe);
  }

  void _sendToMap(Map<String, dynamic> data) {
    _iframe.contentWindow?.postMessage(data.jsify(), '*'.toJS);
  }

  Future<void> _loadCustomerLocation(int cardNumber) async {
    try {
      // Use loyaltyCardDb for loyalty collection
      final loyaltyFirestore = FirebaseFirestore.instanceFor(
        app: Firebase.apps.firstWhere(
          (app) => app.name == 'loyaltyCardDb',
          orElse: () => Firebase.app(),
        ),
      );
      final snap = await loyaltyFirestore
          .collection('loyalty')
          .where('cardNumber', isEqualTo: cardNumber)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return;
      final data = snap.docs.first.data();
      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        setState(() {
          _lat = lat;
          _lng = lng;
        });
        _sendToMap({'lat': lat, 'lng': lng, 'center': true});
      }
    } catch (e) {
      debugPrint('loadCustomerLocation error: $e');
    }
  }

  Future<void> _save() async {
    debugPrint(
        '_save: customerId=${autocompleteSelected.customerId} lat=$_lat lng=$_lng');
    if (autocompleteSelected.customerId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer first.')),
      );
      return;
    }
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please drop a pin on the map first.')),
      );
      return;
    }

    setState(() => _mapVisible = false);

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirm Save'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.person, 'Customer', autocompleteSelected.name),
            const SizedBox(height: 8),
            _infoRow(Icons.my_location, 'Coordinates',
                '${_lat!.toStringAsFixed(6)}, ${_lng!.toStringAsFixed(6)}'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
          ),
        ],
      ),
    );

    setState(() => _mapVisible = true);

    if (confirm != true) return;

    final success = await DatabaseLoyalty().saveLocation(
      autocompleteSelected.customerId,
      _lat!,
      _lng!,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(success ? Icons.check_circle : Icons.error,
                  color: Colors.white),
              const SizedBox(width: 8),
              Text(success
                  ? 'Location saved for ${autocompleteSelected.name}'
                  : 'Customer not found in loyalty records.'),
            ],
          ),
          backgroundColor:
              success ? Colors.green.shade700 : Colors.red.shade700,
        ),
      );
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text('Customer Location',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800)),
            ],
          ),
          const SizedBox(height: 16),

          // Customer selector — inline search (keyboard-safe)
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search customer...',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              isDense: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (v) => setState(() => _searchQuery = v.trim()),
          ),

          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 4),
            Builder(builder: (ctx) {
              final q = _searchQuery.toLowerCase();
              final results = CustomerRepository.instance.customers
                  .where((c) =>
                      c.name.toLowerCase().contains(q) ||
                      c.customerId.toString().contains(q))
                  .take(8)
                  .toList();

              if (results.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('No customers found.',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: results.asMap().entries.map((entry) {
                    final i = entry.key;
                    final c = entry.value;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              autocompleteSelected = CustomerModel(
                                customerId: c.customerId,
                                name: c.name,
                                address: c.address,
                                contact: c.contact,
                                remarks: c.remarks,
                                loyaltyCount: c.loyaltyCount,
                              );
                            });
                            FocusScope.of(ctx).unfocus();
                            _loadCustomerLocation(c.customerId);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(c.name,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      if (c.address.isNotEmpty)
                                        Text(c.address,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade500)),
                                    ],
                                  ),
                                ),
                                Icon(Icons.location_on,
                                    size: 18, color: Colors.blue.shade400),
                              ],
                            ),
                          ),
                        ),
                        if (i < results.length - 1)
                          Divider(height: 1, color: Colors.grey.shade200),
                      ],
                    );
                  }).toList(),
                ),
              );
            }),
          ],

          // Selected customer display
          if (autocompleteSelected.customerId != 0 && _searchQuery.isEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      autocompleteSelected.name,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        size: 16, color: Colors.blue.shade400),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() {
                      autocompleteSelected = CustomerModel(
                        customerId: 0,
                        name: '',
                        address: '',
                        contact: '',
                        remarks: '',
                        loyaltyCount: 0,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Pin info
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _lat != null && _lng != null
                ? Container(
                    key: const ValueKey('pin'),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.push_pin,
                                size: 14, color: Colors.green.shade700),
                            const SizedBox(width: 6),
                            Text('Pin Dropped',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Lat: ${_lat!.toStringAsFixed(6)}',
                            style: const TextStyle(
                                fontSize: 12, fontFamily: 'monospace')),
                        Text('Lng: ${_lng!.toStringAsFixed(6)}',
                            style: const TextStyle(
                                fontSize: 12, fontFamily: 'monospace')),
                      ],
                    ),
                  )
                : Container(
                    key: const ValueKey('no-pin'),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tap the map to drop a pin for the customer.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          // Instructions
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How to use',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700)),
                const SizedBox(height: 6),
                _hint('📍', 'Tap map to drop customer pin'),
                _hint('🔵', 'My Location — centers map on you'),
                _hint('🔄', 'Toggle Drop Pin ON/OFF'),
                _hint('✋', 'Drag pin to fine-tune position'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hint(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(fontSize: 11, color: Colors.blue.shade800)),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: _mapVisible
          ? HtmlElementView(viewType: _mapId)
          : Container(
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator()),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Edit Customer Location'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isWide
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 320,
                    child: SingleChildScrollView(child: _buildSidePanel()),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMap()),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: _buildSidePanel(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: _buildMap(),
                  ),
                ),
              ],
            ),
    );
  }

  static String _buildHtml(double lat, double lng) {
    return '''<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<style>
html,body,#map{margin:0;padding:0;width:100%;height:100%;}
.ctrl-btn{
  position:absolute;z-index:1000;
  background:white;border:2px solid #ccc;border-radius:10px;
  padding:8px 14px;cursor:pointer;font-size:13px;font-weight:600;
  box-shadow:0 2px 8px rgba(0,0,0,0.18);
  display:flex;align-items:center;gap:6px;transition:all .15s;
}
.ctrl-btn:hover{background:#f5f5f5;transform:scale(1.03);}
#myLocationBtn{bottom:20px;right:12px;}
#pinBtn{bottom:68px;right:12px;}
#pinBtn.active{background:#e3f2fd;border-color:#1976d2;color:#1976d2;}
</style>
</head>
<body>
<div id="map"></div>
<button class="ctrl-btn" id="myLocationBtn">🔵 My Location</button>
<button class="ctrl-btn active" id="pinBtn">📍 Drop Pin: ON</button>
<script>
var map=L.map('map',{zoomControl:true}).setView([$lat,$lng],15);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{attribution:''}).addTo(map);

var customerMarker=null,myMarker=null,dropPinMode=true;

var pinIcon=L.divIcon({
  html:'<div style="font-size:32px;line-height:1;filter:drop-shadow(0 2px 4px rgba(0,0,0,0.4))">📍</div>',
  iconSize:[32,32],iconAnchor:[16,32],className:''
});

function placePin(lat,lng){
  if(customerMarker){
    customerMarker.setLatLng([lat,lng]);
  } else {
    customerMarker=L.marker([lat,lng],{draggable:true,icon:pinIcon}).addTo(map);
    customerMarker.on('dragend',function(){
      var p=customerMarker.getLatLng();
      window.parent.postMessage({lat:p.lat,lng:p.lng},'*');
    });
  }
  window.parent.postMessage({lat:lat,lng:lng},'*');
}

map.on('click',function(e){
  if(!dropPinMode) return;
  placePin(e.latlng.lat,e.latlng.lng);
});

document.getElementById('pinBtn').addEventListener('click',function(){
  dropPinMode=!dropPinMode;
  this.textContent=dropPinMode?'📍 Drop Pin: ON':'📍 Drop Pin: OFF';
  this.className='ctrl-btn'+(dropPinMode?' active':'');
  map.getContainer().style.cursor=dropPinMode?'crosshair':'';
});

document.getElementById('myLocationBtn').addEventListener('click',function(){
  if(!navigator.geolocation){alert('Geolocation not supported');return;}
  navigator.geolocation.getCurrentPosition(function(pos){
    var lat=pos.coords.latitude,lng=pos.coords.longitude;
    if(myMarker){myMarker.setLatLng([lat,lng]);}
    else{
      myMarker=L.circleMarker([lat,lng],{
        radius:10,color:'#1976d2',fillColor:'#42a5f5',fillOpacity:0.85,weight:3
      }).addTo(map).bindPopup('<b>My Location</b>').openPopup();
    }
    map.setView([lat,lng],17);
  },function(err){alert('Could not get location: '+err.message);});
});

// receive commands from Flutter (center on existing customer location)
window.addEventListener('message',function(e){
  var d=e.data;
  if(d&&d.lat!==undefined&&d.lng!==undefined){
    placePin(d.lat,d.lng);
    if(d.center) map.setView([d.lat,d.lng],17);
  }
});

window.parent.postMessage('map-ready','*');
</script>
</body>
</html>''';
  }
}
