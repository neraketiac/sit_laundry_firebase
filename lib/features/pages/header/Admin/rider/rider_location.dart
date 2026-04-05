import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;
import 'dart:ui_web' as ui_web;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;
import 'package:laundry_firebase/core/services/firebase_service.dart';
import 'package:laundry_firebase/features/pages/header/Admin/rider/rider_route_planner.dart';
import 'package:laundry_firebase/core/global/variables.dart';

@JS('navigator.wakeLock.request')
external JSPromise<JSObject> _requestWakeLock(JSString type);

const _kWatchers = 'rider_watchers';
const _kCollection = 'rider_location';
const _kDoc = 'current';
const _kSubCollection = 'push_subscriptions';
const _kPushServer = 'https://rider-push-server.onrender.com/send';

// Watcher is considered stale if lastSeen is older than this
const _kStaleThreshold = Duration(minutes: 2);

// Shorthand for the secondary Firestore (zpos-d985c) — same DB the customer app uses
FirebaseFirestore get _db => FirebaseService.secondaryFirestore;

// ===================== NOTIFICATION HELPERS =====================

Future<void> _notifyAllSubscribers() async {
  final snap = await _db.collection(_kSubCollection).get();
  final tokens =
      snap.docs.map((d) => d.data()['token']).whereType<String>().toList();

  if (tokens.isEmpty) return;

  await http.post(
    Uri.parse(_kPushServer),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'tokens': tokens,
      'title': 'Rider is Available!',
      'body': 'Your rider is now online and sharing location.',
      'url': 'https://washkolang.online',
    }),
  );
}

// ===================== INLINE MAP WIDGET =====================

class RiderLocationWidget extends StatefulWidget {
  final bool previewSelf;
  const RiderLocationWidget({super.key, this.previewSelf = false});

  @override
  State<RiderLocationWidget> createState() => _RiderLocationWidgetState();
}

// slot key -> display label
const _scheduleSlotLabels = {
  'slot7to9': '7am-9am',
  'slot9to10': '9am-10am',
  'slot10to12': '10am-12pm',
  'slot1to3': '1pm-3pm',
  'slot3to5': '3pm-5pm',
  'slot5to7': '5pm-7pm',
  'slot7to9pm': '7pm-9pm',
};
const _scheduleSlotEndHour = {
  'slot7to9': 9,
  'slot9to10': 10,
  'slot10to12': 12,
  'slot1to3': 15,
  'slot3to5': 17,
  'slot5to7': 19,
  'slot7to9pm': 21,
};

class _RiderLocationWidgetState extends State<RiderLocationWidget> {
  double? _lat;
  double? _lng;
  String? _facing; // 'left' or 'right'
  bool _loading = true;
  bool _offline = false;
  String? _lastUpdated;
  StreamSubscription? _sub;

  List<String> _todaySlots = [];
  bool _loadingSlots = false;

  @override
  void initState() {
    super.initState();
    _openStream();
  }

  Future<void> _loadTodaySlots() async {
    final now = DateTime.now();
    final docId =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    setState(() => _loadingSlots = true);
    try {
      final doc = await _db.collection('Rider_schedule').doc(docId).get();
      if (!doc.exists) {
        if (mounted)
          setState(() {
            _todaySlots = [];
            _loadingSlots = false;
          });
        return;
      }
      final data = doc.data()!;
      final slots = <String>[];
      for (final entry in _scheduleSlotLabels.entries) {
        final key = entry.key;
        final label = entry.value;
        final enabled = data[key] == true;
        final endHour = _scheduleSlotEndHour[key] ?? 0;
        if (enabled && now.hour < endHour) slots.add(label);
      }
      if (mounted)
        setState(() {
          _todaySlots = slots;
          _loadingSlots = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _todaySlots = [];
          _loadingSlots = false;
        });
    }
  }

  void _openStream() {
    final ref = _db.collection(_kCollection).doc(_kDoc);
    _sub = ref.snapshots().listen((snap) {
      if (!snap.exists) {
        if (mounted)
          setState(() {
            _loading = false;
            _offline = true;
          });
        _loadTodaySlots();
        return;
      }
      final data = snap.data()!;
      final isOnline = data['isOnline'] as bool? ?? true;
      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['lng'] as num?)?.toDouble();
      final facing = data['facing'] as String?;
      final ts = data['updatedAt'] as Timestamp?;

      if (mounted) {
        setState(() {
          _loading = false;
          _offline = !isOnline;
          if (lat != null) _lat = lat;
          if (lng != null) _lng = lng;
          if (facing != null) _facing = facing;
          if (ts != null) {
            final d = ts.toDate().toLocal();
            _lastUpdated =
                '${d.month}/${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
          }
        });
      }
      if (!isOnline) _loadTodaySlots();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // No location yet — show offline/schedule view
    if (_lat == null || _lng == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.electric_moped,
                size: 40,
                color: Colors.blueGrey,
              ),
              const SizedBox(height: 8),
              const Text(
                'Rider is not currently sharing location.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (_loadingSlots)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (_todaySlots.isNotEmpty) ...[
                const Text(
                  "Today's rider schedule:",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: _todaySlots
                      .map(
                        (slot) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Check back during these times.',
                  style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                ),
              ] else
                const Text(
                  'No more rider slots available today.\nCheck back tomorrow.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        if (_offline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: Colors.orange.shade100,
            child: const Text(
              'Rider stopped sharing - showing last known location',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.deepOrange),
            ),
          )
        else if (_lastUpdated != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Last updated: $_lastUpdated',
              style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
            ),
          ),
        Expanded(
          child: _LeafletMap(
            key: const ValueKey('rider-map'),
            lat: _lat!,
            lng: _lng!,
            facing: _facing,
          ),
        ),
      ],
    );
  }
}

// ===================== LEAFLET MAP =====================

class _LeafletMap extends StatefulWidget {
  final double lat;
  final double lng;
  final String? facing;
  const _LeafletMap({
    super.key,
    required this.lat,
    required this.lng,
    this.facing,
  });

  @override
  State<_LeafletMap> createState() => _LeafletMapState();
}

class _LeafletMapState extends State<_LeafletMap> {
  late final String _viewId;
  late web.HTMLIFrameElement _iframe;
  bool _ready = false;
  double? _pendingLat;
  double? _pendingLng;
  String? _pendingFacing;

  @override
  void initState() {
    super.initState();
    _viewId = 'leaflet-map-${DateTime.now().millisecondsSinceEpoch}';

    final html = _buildLeafletHtml(widget.lat, widget.lng);
    final blob = web.Blob(
      [html.toJS].toJS,
      web.BlobPropertyBag(type: 'text/html'),
    );
    final url = web.URL.createObjectURL(blob);

    _iframe = web.HTMLIFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true;

    web.window.addEventListener(
      'message',
      (web.Event e) {
        final msg = e as web.MessageEvent;
        if (msg.data.dartify() == 'leaflet-ready') {
          _ready = true;
          // Always send current position + facing immediately on ready
          _sendUpdate(
            _pendingLat ?? widget.lat,
            _pendingLng ?? widget.lng,
            _pendingFacing ?? widget.facing,
          );
          _pendingLat = null;
          _pendingLng = null;
          _pendingFacing = null;
        }
      }.toJS,
    );

    ui_web.platformViewRegistry.registerViewFactory(_viewId, (_) => _iframe);
  }

  void _sendUpdate(double lat, double lng, String? facing) {
    final data = <String, dynamic>{'lat': lat, 'lng': lng};
    if (facing != null) data['facing'] = facing;
    _iframe.contentWindow?.postMessage(data.jsify(), '*'.toJS);
  }

  void updatePosition(double lat, double lng, String? facing) {
    if (_ready) {
      _sendUpdate(lat, lng, facing);
    } else {
      _pendingLat = lat;
      _pendingLng = lng;
      _pendingFacing = facing;
    }
  }

  @override
  void didUpdateWidget(_LeafletMap old) {
    super.didUpdateWidget(old);
    if (old.lat != widget.lat ||
        old.lng != widget.lng ||
        old.facing != widget.facing) {
      updatePosition(widget.lat, widget.lng, widget.facing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }

  static String _buildLeafletHtml(double lat, double lng) {
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
var map=L.map('map',{zoomControl:true,attributionControl:false}).setView([$lat,$lng],16);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);
var facingRight=false;

function makeIcon(right){
  var flip=right?'scaleX(-1)':'scaleX(1)';
  return L.divIcon({
    html:'<div style="font-size:28px;line-height:1;display:inline-block;transform:'+flip+';">&#x1F6FA;</div>',
    iconSize:[36,36],iconAnchor:[18,18],className:''
  });
}

var marker=L.marker([$lat,$lng],{icon:makeIcon(false)}).addTo(map);

// Smooth animation state
var fromLat=$lat, fromLng=$lng;
var toLat=$lat, toLng=$lng;
var animStart=null, animDuration=800;
var rafId=null;

function animateTo(newLat,newLng){
  fromLat=currentLat(); fromLng=currentLng();
  toLat=newLat; toLng=newLng;
  animStart=null;
  if(rafId) cancelAnimationFrame(rafId);
  rafId=requestAnimationFrame(step);
}

function currentLat(){
  return marker.getLatLng().lat;
}
function currentLng(){
  return marker.getLatLng().lng;
}

function easeInOut(t){
  return t<0.5?2*t*t:1-Math.pow(-2*t+2,2)/2;
}

function step(ts){
  if(!animStart) animStart=ts;
  var t=Math.min((ts-animStart)/animDuration,1);
  var e=easeInOut(t);
  var lat=fromLat+(toLat-fromLat)*e;
  var lng=fromLng+(toLng-fromLng)*e;
  marker.setLatLng([lat,lng]);
  if(t<1){
    rafId=requestAnimationFrame(step);
  } else {
    rafId=null;
    map.panTo([toLat,toLng],{animate:true,duration:0.5,easeLinearity:0.5});
  }
}

window.parent.postMessage('leaflet-ready','*');

window.addEventListener('message',function(e){
  var d=e.data;
  if(d&&d.lat!==undefined&&d.lng!==undefined){
    if(d.facing!==undefined&&d.facing!==null){
      var right=(d.facing==='right');
      if(right!==facingRight){
        facingRight=right;
        marker.setIcon(makeIcon(facingRight));
      }
    }
    animateTo(d.lat,d.lng);
  }
});
</script>
</body>
</html>''';
  }
}

// ===================== FULL SCREEN MAP PAGE =====================

class RiderLocationScreen extends StatefulWidget {
  const RiderLocationScreen({super.key});

  @override
  State<RiderLocationScreen> createState() => _RiderLocationScreenState();
}

class _RiderLocationScreenState extends State<RiderLocationScreen> {
  final String _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  Timer? _watcherTimer;
  JSObject? _screenWakeLock;

  // Keep AdminRiderPanel alive across bottom sheet open/close
  final _adminPanelKey = GlobalKey<_AdminRiderPanelState>();

  // Live rider position streamed from Firestore → passed to route planner
  double? _riderLat;
  double? _riderLng;
  StreamSubscription? _riderPosSub;

  @override
  void initState() {
    super.initState();
    if (!isAdmin) _registerWatcher();
    _watcherTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _updateLastSeen(),
    );
    _listenRiderPosition();
    _acquireScreenWakeLock();
  }

  Future<void> _acquireScreenWakeLock() async {
    try {
      _screenWakeLock = await _requestWakeLock('screen'.toJS).toDart;
    } catch (_) {}
  }

  void _releaseScreenWakeLock() {
    try {
      _screenWakeLock?.callMethod('release'.toJS);
    } catch (_) {}
    _screenWakeLock = null;
  }

  void _listenRiderPosition() {
    _riderPosSub =
        _db.collection(_kCollection).doc(_kDoc).snapshots().listen((snap) {
      if (!snap.exists || !mounted) return;
      final data = snap.data()!;
      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        setState(() {
          _riderLat = lat;
          _riderLng = lng;
        });
      }
    });
  }

  Future<void> _registerWatcher() async {
    await _db.collection(_kWatchers).doc(_sessionId).set(
      {'joinedAt': Timestamp.now(), 'lastSeen': Timestamp.now()},
    );
  }

  Future<void> _updateLastSeen() async {
    if (isAdmin) return;
    try {
      await _db
          .collection(_kWatchers)
          .doc(_sessionId)
          .update({'lastSeen': Timestamp.now()});
    } catch (_) {}
  }

  @override
  void dispose() {
    _watcherTimer?.cancel();
    _riderPosSub?.cancel();
    _releaseScreenWakeLock();
    if (!isAdmin) _db.collection(_kWatchers).doc(_sessionId).delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFF90CAF9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Rider GPS',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const Spacer(),
                    // Controls button — opens bottom sheet on mobile
                    IconButton(
                      icon: const Icon(Icons.tune, color: Colors.blueGrey),
                      tooltip: 'GPS Controls',
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) =>
                            _ControlsSheet(panelKey: _adminPanelKey),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Route planner (full screen) ───────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: RiderRoutePlanner(
                    riderLat: _riderLat,
                    riderLng: _riderLng,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== CONTROLS BOTTOM SHEET =====================

class _ControlsSheet extends StatelessWidget {
  final GlobalKey<_AdminRiderPanelState> panelKey;
  const _ControlsSheet({required this.panelKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text('GPS Controls',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey)),
          const SizedBox(height: 20),
          AdminRiderPanel(key: panelKey),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ===================== ADMIN PANEL (floating overlay) =====================

class AdminRiderPanel extends StatefulWidget {
  const AdminRiderPanel({super.key});

  @override
  State<AdminRiderPanel> createState() => _AdminRiderPanelState();
}

class _AdminRiderPanelState extends State<AdminRiderPanel> {
  bool _sharing = false;
  bool _locating = false;
  bool _notified = false;
  bool _onDelivery = false;
  bool _showEta = false;
  String? _error;
  Timer? _timer;
  Timer? _cleanupTimer;
  int _watcherCount = 0;
  int _staleCount = 0;
  StreamSubscription? _watcherSub;
  JSObject? _wakeLock;
  double? _prevLng;
  double? _prevLat;
  DateTime? _lastWritten;
  DateTime? _sessionStart;
  String _lastFacing = 'right';

  Future<void> _acquireWakeLock() async {
    try {
      _wakeLock = await _requestWakeLock('screen'.toJS).toDart;
    } catch (_) {}
  }

  Future<void> _releaseWakeLock() async {
    try {
      _wakeLock?.callMethod('release'.toJS);
    } catch (_) {}
    _wakeLock = null;
  }

  @override
  void initState() {
    super.initState();
    _startWatcherStream();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cleanupTimer?.cancel();
    _watcherSub?.cancel();
    _releaseWakeLock();
    super.dispose();
  }

  void _startWatcherStream() {
    _watcherSub?.cancel();
    _watcherSub = _db.collection(_kWatchers).snapshots().listen((snap) {
      if (!mounted) return;
      final now = DateTime.now();
      int stale = 0;
      for (final doc in snap.docs) {
        final ts = doc.data()['lastSeen'];
        if (ts is Timestamp) {
          if (now.difference(ts.toDate()) > _kStaleThreshold) stale++;
        }
      }
      setState(() {
        _watcherCount = snap.docs.length;
        _staleCount = stale;
      });
    });
  }

  Future<int> _cleanStaleWatchers() async {
    final snap = await _db.collection(_kWatchers).get();
    final now = DateTime.now();
    final batch = _db.batch();
    int removed = 0;
    for (final doc in snap.docs) {
      final ts = doc.data()['lastSeen'];
      if (ts is Timestamp) {
        if (now.difference(ts.toDate()) > _kStaleThreshold) {
          // Save to history before deleting
          batch.set(
            _db.collection('rider_watchers_history').doc(),
            {
              ...doc.data(),
              'watcherId': doc.id,
              'clearedAt': Timestamp.now(),
            },
          );
          batch.delete(doc.reference);
          removed++;
        }
      }
    }
    if (removed > 0) await batch.commit();
    return removed;
  }

  /// Saves a history record to `rider_location_history` when the rider goes offline.
  Future<void> _saveRiderHistory() async {
    if (_prevLat == null || _prevLng == null) return;
    try {
      await _db.collection('rider_location_history').add({
        'lat': _prevLat,
        'lng': _prevLng,
        'facing': _lastFacing,
        'sessionStart':
            _sessionStart != null ? Timestamp.fromDate(_sessionStart!) : null,
        'clearedAt': Timestamp.now(),
        'lastWritten':
            _lastWritten != null ? Timestamp.fromDate(_lastWritten!) : null,
      });
    } catch (_) {}
  }

  /// On sharing start, read existing facing from Firestore so we never lose it.
  /// Falls back to 'right' only if the doc has no facing field yet (first ever run).
  Future<void> _loadFacingThenStart({bool notify = false}) async {
    try {
      final doc = await _db.collection(_kCollection).doc(_kDoc).get();
      if (doc.exists) {
        final saved = doc.data()?['facing'] as String?;
        if (saved != null) _lastFacing = saved;
      }
    } catch (_) {}
    _pushLocation(notify: notify);
  }

  /// Haversine distance in metres between two lat/lng points
  double _distanceMeters(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  void _toggleDeliveryStatus(bool val) {
    setState(() => _onDelivery = val);
    _db.collection(_kCollection).doc(_kDoc).set(
      {'status': val ? '🚚 On Delivery / Pickup' : '✅ Done Delivery / Pickup'},
      SetOptions(merge: true),
    );
  }

  void _toggleShowEta(bool val) {
    setState(() => _showEta = val);
    if (val) {
      // Just flip the flag — routeStops already saved from last Save ETAs
      _db.collection(_kCollection).doc(_kDoc).set(
        {'showEta': true},
        SetOptions(merge: true),
      );
    } else {
      // Hide route from customers — clear stops and flag together
      _db.collection(_kCollection).doc(_kDoc).set(
        {
          'showEta': false,
          'routeStops': [],
          'routeUpdatedAt': Timestamp.now(),
        },
        SetOptions(merge: true),
      );
    }
  }

  void _toggleSharing(bool val) {
    setState(() {
      _sharing = val;
      _notified = false;
    });
    if (val) {
      _acquireWakeLock();
      _sessionStart = DateTime.now();
      _loadFacingThenStart(notify: true);
      _timer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _pushLocation(notify: false),
      );
    } else {
      _timer?.cancel();
      _cleanupTimer?.cancel();
      _releaseWakeLock();
      _saveRiderHistory();
      _prevLng = null;
      _prevLat = null;
      _lastWritten = null;
      _sessionStart = null;
      // _lastFacing intentionally NOT reset — keep last known direction
      _db.collection(_kCollection).doc(_kDoc).update({'isOnline': false});
      // Clear route stops when GPS sharing stops
      _db.collection(_kCollection).doc(_kDoc).set({
        'routeStops': [],
        'routeUpdatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> _pushLocation({bool notify = false}) async {
    setState(() => _locating = true);
    try {
      final completer = Completer<(double, double)>();
      web.window.navigator.geolocation.getCurrentPosition(
        (web.GeolocationPosition pos) {
          completer.complete((pos.coords.latitude, pos.coords.longitude));
        }.toJS,
        (web.GeolocationPositionError err) {
          completer.completeError(err.message);
        }.toJS,
      );
      final (lat, lng) = await completer.future;

      // Decide whether to write to Firestore:
      // - Always write on first call (no previous position)
      // - Write if moved > 10 metres
      // - Write as fallback if 15+ seconds since last write (stay-online heartbeat)
      final now = DateTime.now();
      final movedEnough = _prevLat == null ||
          _distanceMeters(_prevLat!, _prevLng!, lat, lng) > 10;
      final fallbackDue = _lastWritten == null ||
          now.difference(_lastWritten!) >= const Duration(seconds: 15);

      if (movedEnough || fallbackDue) {
        // Update facing only when longitude actually changes
        if (_prevLng != null && lng != _prevLng) {
          _lastFacing = lng > _prevLng! ? 'right' : 'left';
        }
        _prevLat = lat;
        _prevLng = lng;
        _lastWritten = now;

        await _db.collection(_kCollection).doc(_kDoc).set({
          'lat': lat,
          'lng': lng,
          'facing': _lastFacing,
          'updatedAt': Timestamp.now(),
          'isOnline': true,
          'status': _onDelivery
              ? '🚚 On Delivery / Pickup'
              : '✅ Done Delivery / Pickup',
        }, SetOptions(merge: true));

        if (notify && !_notified) {
          await _notifyAllSubscribers();
          if (mounted) setState(() => _notified = true);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Location error: $e');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── GPS sharing ───────────────────────────────────────────
        _controlTile(
          icon: _sharing ? Icons.share_location : Icons.location_off,
          iconColor: _sharing ? Colors.green.shade700 : Colors.blueGrey,
          label: 'GPS Sharing',
          sublabel: _sharing
              ? (_locating ? 'Locating...' : 'Active — sharing location')
              : 'Off',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_locating)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              Switch(
                value: _sharing,
                onChanged: _toggleSharing,
                activeColor: Colors.green.shade700,
              ),
            ],
          ),
          color: _sharing ? Colors.green.shade50 : null,
        ),

        const SizedBox(height: 10),

        // ── Show ETA to customers ─────────────────────────────────
        _controlTile(
          icon: _showEta ? Icons.access_time_filled : Icons.access_time,
          iconColor: _showEta ? Colors.teal.shade700 : Colors.blueGrey,
          label: 'Show ETA to Customers',
          sublabel: _showEta
              ? 'Customers can see estimated arrival time'
              : 'ETA hidden from customers',
          trailing: Switch(
            value: _showEta,
            onChanged: _toggleShowEta,
            activeColor: Colors.teal.shade700,
          ),
          color: _showEta ? Colors.teal.shade50 : null,
        ),

        const SizedBox(height: 10),

        // ── Delivery status ───────────────────────────────────────
        GestureDetector(
          onTap: () => _toggleDeliveryStatus(!_onDelivery),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _onDelivery ? Colors.orange.shade50 : Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _onDelivery
                    ? Colors.orange.shade300
                    : Colors.green.shade300,
              ),
            ),
            child: Row(
              children: [
                Text(
                  _onDelivery ? '🚚' : '✅',
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _onDelivery
                            ? 'On Delivery / Pickup'
                            : 'Done Delivery / Pickup',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _onDelivery
                              ? Colors.orange.shade800
                              : Colors.green.shade800,
                        ),
                      ),
                      Text(
                        'Tap to change status',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.swap_horiz,
                  color: _onDelivery
                      ? Colors.orange.shade400
                      : Colors.green.shade400,
                ),
              ],
            ),
          ),
        ),

        // ── Watchers ──────────────────────────────────────────────
        if (_watcherCount > 0) ...[
          const SizedBox(height: 10),
          _controlTile(
            icon: Icons.visibility,
            iconColor: Colors.blueGrey,
            label: '$_watcherCount Watcher${_watcherCount > 1 ? 's' : ''}',
            sublabel: _staleCount > 0
                ? '$_staleCount stale — tap to clear'
                : 'All active',
            trailing: _staleCount > 0
                ? TextButton(
                    onPressed: () async {
                      final removed = await _cleanStaleWatchers();
                      if (mounted && removed > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Removed $removed stale watcher(s).'),
                          duration: const Duration(seconds: 2),
                        ));
                      }
                    },
                    child: const Text('Clear'),
                  )
                : null,
            color: _staleCount > 0 ? Colors.orange.shade50 : null,
          ),
        ],

        if (_error != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_error!,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.redAccent)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _controlTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String sublabel,
    required Widget? trailing,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(sublabel,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
