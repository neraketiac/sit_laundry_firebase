import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/customers/models/customermodel.dart';
import 'package:laundry_firebase/features/customers/repository/customer_repository.dart';
import 'package:web/web.dart' as web;
import 'package:web/web.dart' as web;

// ── Model ──────────────────────────────────────────────────────────────────

class _RouteStop {
  final String name;
  final String address;
  final double lat;
  final double lng;

  _RouteStop({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });
}

// ── Page ───────────────────────────────────────────────────────────────────

class RiderRoutePlannerPage extends StatefulWidget {
  const RiderRoutePlannerPage({super.key});

  @override
  State<RiderRoutePlannerPage> createState() => _RiderRoutePlannerPageState();
}

class _RiderRoutePlannerPageState extends State<RiderRoutePlannerPage> {
  final List<_RouteStop> _stops = [];
  CustomerModel? _selectedCustomer;
  bool _mapVisible = true;
  bool _mapReady = false;

  final String _mapId =
      'route-map-${DateTime.now().millisecondsSinceEpoch}';
  late web.HTMLIFrameElement _iframe;

  @override
  void initState() {
    super.initState();
    _initMap();
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

    web.window.addEventListener('message', (web.Event e) {
      final msg = e as web.MessageEvent;
      if (msg.data.dartify() == 'map-ready') {
        setState(() => _mapReady = true);
      }
    }.toJS);

    ui_web.platformViewRegistry.registerViewFactory(_mapId, (_) => _iframe);
  }

  void _sendToMap(Map<String, dynamic> data) {
    _iframe.contentWindow?.postMessage(data.jsify(), '*'.toJS);
  }

  void _refreshMap() {
    final stops = _stops
        .map((s) => {'name': s.name, 'lat': s.lat, 'lng': s.lng})
        .toList();
    _sendToMap({'type': 'setRoute', 'stops': stops});
  }

  Future<void> _addRoute() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer first.')),
      );
      return;
    }

    // fetch GPS from loyalty
    final snap = await FirebaseFirestore.instance
        .collection('loyalty')
        .where('cardNumber', isEqualTo: _selectedCustomer!.customerId)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${_selectedCustomer!.name} has no GPS saved. Use Edit Customer Location first.')),
      );
      return;
    }

    final data = snap.docs.first.data();
    final lat = (data['lat'] as num?)?.toDouble();
    final lng = (data['lng'] as num?)?.toDouble();

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${_selectedCustomer!.name} has no GPS coordinates saved.')),
      );
      return;
    }

    // check duplicate
    if (_stops.any((s) => s.name == _selectedCustomer!.name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${_selectedCustomer!.name} is already in the route.')),
      );
      return;
    }

    setState(() {
      _stops.add(_RouteStop(
        name: _selectedCustomer!.name,
        address: _selectedCustomer!.address,
        lat: lat,
        lng: lng,
      ));
      _selectedCustomer = null;
    });

    _refreshMap();
  }

  void _removeStop(int index) {
    setState(() => _stops.removeAt(index));
    _refreshMap();
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _stops.removeAt(oldIndex);
      _stops.insert(newIndex, item);
    });
    _refreshMap();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Rider Route Planner'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_stops.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                icon: const Icon(Icons.delete_sweep, color: Colors.white),
                label: const Text('Clear', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  setState(() => _stops.clear());
                  _refreshMap();
                },
              ),
            ),
        ],
      ),
      body: isWide
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 340,
                    child: SingleChildScrollView(child: _buildPanel()),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMap()),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: _buildPanel(),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: _buildMap(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPanel() {
    return Container(
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
          // Title
          Row(
            children: [
              Icon(Icons.route, color: Colors.teal.shade700, size: 20),
              const SizedBox(width: 8),
              Text('Plan Route',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800)),
            ],
          ),
          const SizedBox(height: 16),

          // Customer search
          _CustomerSearchField(
            onSelected: (c) => setState(() => _selectedCustomer = c),
            selected: _selectedCustomer,
          ),

          const SizedBox(height: 10),

          // Add Route button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Add to Route'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _addRoute,
            ),
          ),

          if (_stops.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.drag_indicator,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('Drag to reorder route',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 8),

            // Reorderable stop list
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stops.length,
              onReorder: _reorder,
              itemBuilder: (ctx, i) {
                final stop = _stops[i];
                return _StopTile(
                  key: ValueKey('${stop.name}_$i'),
                  index: i,
                  stop: stop,
                  onRemove: () => _removeStop(i),
                );
              },
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 14, color: Colors.teal.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search a customer and tap "Add to Route" to build the delivery route.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.teal.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
</style>
</head>
<body>
<div id="map"></div>
<script>
var map=L.map('map').setView([$lat,$lng],14);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{attribution:''}).addTo(map);

var markers=[];
var polyline=null;

function clearAll(){
  markers.forEach(function(m){map.removeLayer(m);});
  markers=[];
  if(polyline){map.removeLayer(polyline);polyline=null;}
}

function setRoute(stops){
  clearAll();
  if(!stops||stops.length===0) return;

  var latlngs=[];
  stops.forEach(function(s,i){
    var num=i+1;
    var icon=L.divIcon({
      html:'<div style="background:#00897b;color:white;border-radius:50%;width:28px;height:28px;display:flex;align-items:center;justify-content:center;font-weight:bold;font-size:13px;box-shadow:0 2px 6px rgba(0,0,0,0.3);">'+num+'</div>',
      iconSize:[28,28],iconAnchor:[14,14],className:''
    });
    var m=L.marker([s.lat,s.lng],{icon:icon})
      .addTo(map)
      .bindPopup('<b>'+num+'. '+s.name+'</b>');
    markers.push(m);
    latlngs.push([s.lat,s.lng]);
  });

  if(latlngs.length>1){
    polyline=L.polyline(latlngs,{
      color:'#00897b',weight:3,opacity:0.8,dashArray:'8,6'
    }).addTo(map);
  }

  // fit bounds
  var group=L.featureGroup(markers);
  map.fitBounds(group.getBounds().pad(0.2));
}

window.addEventListener('message',function(e){
  var d=e.data;
  if(d&&d.type==='setRoute') setRoute(d.stops);
});

window.parent.postMessage('map-ready','*');
</script>
</body>
</html>''';
  }
}

// ── Stop tile ──────────────────────────────────────────────────────────────

class _StopTile extends StatelessWidget {
  final int index;
  final _RouteStop stop;
  final VoidCallback onRemove;

  const _StopTile({
    super.key,
    required this.index,
    required this.stop,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.teal.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('${index + 1}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stop.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                if (stop.address.isNotEmpty)
                  Text(stop.address,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const Icon(Icons.drag_handle, color: Colors.grey, size: 18),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: Colors.red, size: 18),
          ),
        ],
      ),
    );
  }
}

// ── Customer search field ──────────────────────────────────────────────────

class _CustomerSearchField extends StatefulWidget {
  final ValueChanged<CustomerModel?> onSelected;
  final CustomerModel? selected;

  const _CustomerSearchField({
    required this.onSelected,
    required this.selected,
  });

  @override
  State<_CustomerSearchField> createState() => _CustomerSearchFieldState();
}

class _CustomerSearchFieldState extends State<_CustomerSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers = CustomerRepository.instance.customers;

    return Autocomplete<CustomerModel>(
      displayStringForOption: (c) => c.name,
      optionsBuilder: (value) {
        if (value.text.trim().isEmpty) return const [];
        final q = value.text.toLowerCase();
        return customers.where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.address.toLowerCase().contains(q));
      },
      onSelected: (c) {
        widget.onSelected(c);
        _controller.text = c.name;
      },
      fieldViewBuilder: (ctx, controller, focusNode, onSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Search customer...',
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: widget.selected != null
                ? const Icon(Icons.check_circle,
                    color: Colors.teal, size: 18)
                : null,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.teal.shade400),
            ),
          ),
        );
      },
      optionsViewBuilder: (ctx, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final c = options.elementAt(i);
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.person_outline, size: 16),
                    title: Text(c.name,
                        style: const TextStyle(fontSize: 13)),
                    subtitle: Text(c.address,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                    onTap: () => onSelected(c),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
