import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;
import 'package:laundry_firebase/core/services/firebase_service.dart';
import 'package:laundry_firebase/features/customers/models/customermodel.dart';
import 'package:laundry_firebase/features/customers/repository/customer_repository.dart';

FirebaseFirestore get _secondaryDb => FirebaseService.secondaryFirestore;

// ── Stop model ────────────────────────────────────────────────────────────────
class RouteStop {
  final int customerId;
  final String name;
  final double lat;
  final double lng;
  // Computed after OSRM call
  int? etaMinutes; // cumulative minutes from rider start
  DateTime? etaTime; // wall-clock arrival time

  RouteStop({
    required this.customerId,
    required this.name,
    required this.lat,
    required this.lng,
  });
}

// ── Route Planner Widget ──────────────────────────────────────────────────────
class RiderRoutePlanner extends StatefulWidget {
  final double? riderLat;
  final double? riderLng;

  const RiderRoutePlanner({super.key, this.riderLat, this.riderLng});

  @override
  State<RiderRoutePlanner> createState() => _RiderRoutePlannerState();
}

class _RiderRoutePlannerState extends State<RiderRoutePlanner> {
  final List<RouteStop> _stops = [];
  final _searchController = TextEditingController();
  final _stopTimeController = TextEditingController(text: '5');
  String _searchQuery = '';
  bool _searching = false;
  bool _savingEtas = false;
  bool _autoUpdate = false;
  Timer? _autoSaveDebounce;

  // Arrival detection
  static const double _arrivalRadiusMeters = 50.0;
  static const int _arrivalCountdownSecs = 10;
  bool _arrivalPending = false;
  int _arrivalCountdown = _arrivalCountdownSecs;
  Timer? _arrivalTimer;

  // Map
  late final String _mapId;
  late web.HTMLIFrameElement _iframe;

  @override
  void initState() {
    super.initState();
    _mapId = 'route-map-${DateTime.now().millisecondsSinceEpoch}';
    _initMap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stopTimeController.dispose();
    _autoSaveDebounce?.cancel();
    _arrivalTimer?.cancel();
    super.dispose();
  }

  void _initMap() {
    final lat = widget.riderLat ?? 14.5995;
    final lng = widget.riderLng ?? 120.9842;

    final html = _buildMapHtml(lat, lng);
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
          final data = msg.data.dartify();
          if (data == 'route-map-ready') {
            _pushRouteToMap();
          } else if (data is Map && data['type'] == 'legs') {
            // OSRM leg durations returned from map iframe
            final legs = (data['legs'] as List).cast<num>();
            _applyEtas(legs);
          }
        }.toJS);

    ui_web.platformViewRegistry.registerViewFactory(_mapId, (_) => _iframe);
  }

  void _sendToMap(Map<String, dynamic> data) {
    _iframe.contentWindow?.postMessage(data.jsify(), '*'.toJS);
  }

  void _pushRouteToMap() {
    final stops = <Map<String, dynamic>>[];

    if (widget.riderLat != null && widget.riderLng != null) {
      stops
          .add({'lat': widget.riderLat, 'lng': widget.riderLng, 'label': '🛵'});
    }

    for (int i = 0; i < _stops.length; i++) {
      stops.add({
        'lat': _stops[i].lat,
        'lng': _stops[i].lng,
        'label': '${i + 1}',
        'name': _stops[i].name,
      });
    }

    _sendToMap({'type': 'route', 'stops': stops});
  }

  /// Called when the map iframe sends back OSRM leg durations (seconds)
  void _applyEtas(List<num> legDurationsSeconds) {
    final stopMins = int.tryParse(_stopTimeController.text.trim()) ?? 5;
    final now = DateTime.now();
    int cumulativeSecs = 0;

    setState(() {
      for (int i = 0; i < _stops.length; i++) {
        if (i < legDurationsSeconds.length) {
          cumulativeSecs += legDurationsSeconds[i].toInt();
        }
        final stopTimeSecs = i * stopMins * 60;
        final totalSecs = cumulativeSecs + stopTimeSecs;
        _stops[i].etaMinutes = (totalSecs / 60).round();
        _stops[i].etaTime = now.add(Duration(seconds: totalSecs));
      }
    });

    // Auto-save with debounce — waits 3s after last position update
    if (_autoUpdate && _stops.isNotEmpty) {
      _autoSaveDebounce?.cancel();
      _autoSaveDebounce = Timer(const Duration(seconds: 3), _saveEtas);
    }
  }

  Future<void> _addCustomer(CustomerModel customer) async {
    if (_stops.any((s) => s.customerId == customer.customerId)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${customer.name} is already in the route.'),
          duration: const Duration(seconds: 2),
        ));
      }
      return;
    }

    setState(() => _searching = true);

    try {
      final snap = await FirebaseFirestore.instance
          .collection('loyalty')
          .where('cardNumber', isEqualTo: customer.customerId)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        if (mounted) _noGpsWarning(customer.name);
        return;
      }

      final data = snap.docs.first.data();
      final lat = (data['lat'] as num?)?.toDouble();
      final lng = (data['lng'] as num?)?.toDouble();

      if (lat == null || lng == null) {
        if (mounted) _noGpsWarning(customer.name);
        return;
      }

      setState(() {
        _stops.add(RouteStop(
          customerId: customer.customerId,
          name: customer.name,
          lat: lat,
          lng: lng,
        ));
        _searchController.clear();
      });

      _pushRouteToMap();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _noGpsWarning(String name) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '$name has no saved location. Go to Edit Customer Location to add it.'),
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.orange.shade700,
    ));
  }

  void _removeStop(int index) {
    setState(() => _stops.removeAt(index));
    _pushRouteToMap();
  }

  void _clearAll() {
    setState(() => _stops.clear());
    _pushRouteToMap();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _stops.removeAt(oldIndex);
      _stops.insert(newIndex, item);
    });
    _pushRouteToMap();
  }

  /// Save computed ETAs to each customer's loyalty doc
  Future<void> _saveEtas() async {
    final stopsWithEta = _stops.where((s) => s.etaTime != null).toList();
    if (stopsWithEta.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No ETAs computed yet. Add stops and wait for route.'),
      ));
      return;
    }

    setState(() => _savingEtas = true);

    try {
      final batch = FirebaseFirestore.instance.batch();

      for (final stop in stopsWithEta) {
        final snap = await FirebaseFirestore.instance
            .collection('loyalty')
            .where('cardNumber', isEqualTo: stop.customerId)
            .limit(1)
            .get();

        if (snap.docs.isEmpty) continue;

        batch.update(snap.docs.first.reference, {
          'riderEta': Timestamp.fromDate(stop.etaTime!),
          'riderEtaMinutes': stop.etaMinutes,
          'riderEtaUpdatedAt': Timestamp.now(),
        });
      }

      await batch.commit();

      // Write anonymized route to rider_location/current (secondary DB)
      await _secondaryDb.collection('rider_location').doc('current').set({
        'routeStops': stopsWithEta
            .map((s) => {
                  'lat': s.lat,
                  'lng': s.lng,
                  'etaTime':
                      '${s.etaTime!.hour.toString().padLeft(2, '0')}:${s.etaTime!.minute.toString().padLeft(2, '0')}',
                })
            .toList(),
        'routeUpdatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('ETAs saved for ${stopsWithEta.length} customer(s).'),
          backgroundColor: Colors.teal.shade700,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _savingEtas = false);
    }
  }

  @override
  void didUpdateWidget(RiderRoutePlanner old) {
    super.didUpdateWidget(old);
    if (old.riderLat != widget.riderLat || old.riderLng != widget.riderLng) {
      _pushRouteToMap();
      _checkArrival();
    }
  }

  // ── Haversine distance in metres ────────────────────────────────────────────
  double _distanceMeters(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * 3.141592653589793 / 180;
    final dLng = (lng2 - lng1) * 3.141592653589793 / 180;
    final a = (dLat / 2) * (dLat / 2) +
        (lat1 * 3.141592653589793 / 180).abs() *
            (lat2 * 3.141592653589793 / 180).abs() *
            (dLng / 2) *
            (dLng / 2);
    return r * 2 * (a < 1 ? a : 1);
  }

  void _checkArrival() {
    if (_stops.isEmpty) return;
    if (widget.riderLat == null || widget.riderLng == null) return;
    if (_arrivalPending) return; // already counting down

    final next = _stops.first;
    final dist =
        _distanceMeters(widget.riderLat!, widget.riderLng!, next.lat, next.lng);

    if (dist <= _arrivalRadiusMeters) {
      _startArrivalCountdown(next.name);
    }
  }

  void _startArrivalCountdown(String stopName) {
    setState(() {
      _arrivalPending = true;
      _arrivalCountdown = _arrivalCountdownSecs;
    });

    _arrivalTimer?.cancel();
    _arrivalTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _arrivalCountdown--);
      if (_arrivalCountdown <= 0) {
        t.cancel();
        _autoRemoveFirstStop();
      }
    });
  }

  void _cancelArrival() {
    _arrivalTimer?.cancel();
    setState(() {
      _arrivalPending = false;
      _arrivalCountdown = _arrivalCountdownSecs;
    });
  }

  void _autoRemoveFirstStop() {
    if (_stops.isEmpty) return;
    setState(() {
      _stops.removeAt(0);
      _arrivalPending = false;
      _arrivalCountdown = _arrivalCountdownSecs;
    });
    _pushRouteToMap();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;
    final map = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: HtmlElementView(viewType: _mapId),
    );

    if (isWide) {
      return Row(children: [
        SizedBox(
          width: 320,
          child: SingleChildScrollView(child: _buildPanel()),
        ),
        const SizedBox(width: 8),
        Expanded(child: map),
      ]);
    }

    // Mobile: panel scrolls, map fills remaining space
    return Column(children: [
      // Map takes top half
      SizedBox(height: 260, child: map),
      const SizedBox(height: 8),
      // Panel scrolls below
      Expanded(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: _buildPanel(),
        ),
      ),
    ]);
  }

  Widget _buildPanel() {
    final customers = CustomerRepository.instance.customers;
    final hasEtas = _stops.any((s) => s.etaTime != null);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.teal.shade700,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.route, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Route Planner',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
                if (_stops.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearAll,
                    icon: const Icon(Icons.clear_all,
                        color: Colors.white70, size: 16),
                    label: const Text('Clear',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Arrival banner ─────────────────────────────────────
                if (_arrivalPending && _stops.isNotEmpty)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Arrived at ${_stops.first.name}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                              Text(
                                'Removing in $_arrivalCountdown s...',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _cancelArrival,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Keep',
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                // ── Rider start ────────────────────────────────────────
                if (widget.riderLat != null)
                  _stopTile(
                    leading: const Text('🛵', style: TextStyle(fontSize: 16)),
                    title: 'Rider (Start)',
                    subtitle:
                        '${widget.riderLat!.toStringAsFixed(5)}, ${widget.riderLng!.toStringAsFixed(5)}',
                    eta: null,
                    trailing: null,
                  )
                else
                  _warningBox(
                      'Rider GPS not active — enable GPS sharing first.'),

                const SizedBox(height: 8),

                // ── Stop time per customer ─────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.timer, size: 14, color: Colors.blueGrey),
                    const SizedBox(width: 6),
                    const Text('Stop time (min):',
                        style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 52,
                      child: TextField(
                        controller: _stopTimeController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        onChanged: (_) {
                          // Recompute ETAs if we already have them
                          // (map will re-send legs on next route push)
                          _pushRouteToMap();
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('per stop',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade500)),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Customer search (inline — keyboard-safe) ──────────
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search customer...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: _searching
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 1.5)),
                          )
                        : const Icon(Icons.search, size: 18),
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                ),

                // ── Inline results list ────────────────────────────────
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Builder(builder: (ctx) {
                    final q = _searchQuery.toLowerCase();
                    final results = customers
                        .where((c) =>
                            c.name.toLowerCase().contains(q) ||
                            c.customerId.toString().contains(q))
                        .take(8)
                        .toList();

                    if (results.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text('No customers found.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500)),
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
                                  setState(() => _searchQuery = '');
                                  FocusScope.of(ctx).unfocus();
                                  _addCustomer(c);
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
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            if (c.address.isNotEmpty)
                                              Text(c.address,
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors
                                                          .grey.shade500)),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.add_circle_outline,
                                          size: 18, color: Colors.teal),
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

                const SizedBox(height: 8),

                // ── Stop list ──────────────────────────────────────────
                if (_stops.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No stops added yet.\nSearch a customer above to add.',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    onReorder: _onReorder,
                    children: [
                      for (int i = 0; i < _stops.length; i++)
                        _stopTile(
                          key: ValueKey(_stops[i].customerId),
                          leading: ReorderableDragStartListener(
                            index: i,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: Colors.teal,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text('${i + 1}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          title: _stops[i].name,
                          subtitle:
                              '${_stops[i].lat.toStringAsFixed(5)}, ${_stops[i].lng.toStringAsFixed(5)}',
                          eta: _stops[i].etaTime,
                          etaMinutes: _stops[i].etaMinutes,
                          trailing: IconButton(
                            icon: const Icon(Icons.close,
                                size: 16, color: Colors.redAccent),
                            onPressed: () => _removeStop(i),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                    ],
                  ),

                // ── Save ETAs button ───────────────────────────────────
                if (hasEtas) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _savingEtas ? null : _saveEtas,
                      icon: _savingEtas
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.cloud_upload_outlined, size: 16),
                      label: Text(_savingEtas ? 'Saving...' : 'Save ETAs'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(fontSize: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],

                // ── Auto-update toggle ─────────────────────────────────
                if (_stops.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _autoUpdate
                          ? Colors.teal.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _autoUpdate
                            ? Colors.teal.shade300
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _autoUpdate ? Icons.sync : Icons.sync_disabled,
                          size: 14,
                          color:
                              _autoUpdate ? Colors.teal.shade700 : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _autoUpdate
                                ? 'Auto-updating ETAs as rider moves'
                                : 'Auto-update ETAs when rider moves',
                            style: TextStyle(
                              fontSize: 11,
                              color: _autoUpdate
                                  ? Colors.teal.shade800
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Switch(
                          value: _autoUpdate,
                          onChanged: (v) => setState(() => _autoUpdate = v),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          activeColor: Colors.teal.shade700,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stopTile({
    Key? key,
    required Widget leading,
    required String title,
    required String subtitle,
    required DateTime? eta,
    int? etaMinutes,
    required Widget? trailing,
  }) {
    final etaLabel = eta != null ? DateFormat('h:mm a').format(eta) : null;
    final etaMinsLabel = etaMinutes != null ? '~${etaMinutes}min' : null;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                if (etaLabel != null)
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 10, color: Colors.teal.shade600),
                      const SizedBox(width: 3),
                      Text(
                        '$etaLabel  ($etaMinsLabel)',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _warningBox(String msg) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, size: 14, color: Colors.orange.shade700),
          const SizedBox(width: 6),
          Expanded(
            child: Text(msg,
                style: TextStyle(fontSize: 11, color: Colors.orange.shade800)),
          ),
        ],
      ),
    );
  }

  // ── Map HTML ────────────────────────────────────────────────────────────────
  static String _buildMapHtml(double lat, double lng) {
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
var map = L.map('map',{zoomControl:true,attributionControl:false}).setView([$lat,$lng],14);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);

var markers = [];
var routeLayer = null;

function clearMap(){
  markers.forEach(function(m){ map.removeLayer(m); });
  markers = [];
  if(routeLayer){ map.removeLayer(routeLayer); routeLayer=null; }
}

function makeNumberedIcon(label, isRider){
  if(isRider){
    return L.divIcon({
      html:'<div style="font-size:22px;line-height:1;">🛵</div>',
      iconSize:[28,28],iconAnchor:[14,14],className:''
    });
  }
  return L.divIcon({
    html:'<div style="background:#00897b;color:white;border-radius:50%;width:24px;height:24px;display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:bold;border:2px solid white;box-shadow:0 2px 6px rgba(0,0,0,0.4);">'+label+'</div>',
    iconSize:[24,24],iconAnchor:[12,12],className:''
  });
}

async function drawRoute(stops){
  clearMap();
  if(stops.length === 0) return;

  stops.forEach(function(s,i){
    var isRider = (i===0 && s.label==='🛵');
    var m = L.marker([s.lat,s.lng],{icon:makeNumberedIcon(s.label,isRider)}).addTo(map);
    if(s.name) m.bindTooltip(s.name,{permanent:false,direction:'top'});
    markers.push(m);
  });

  if(stops.length > 1){
    var bounds = L.latLngBounds(stops.map(function(s){return[s.lat,s.lng];}));
    map.fitBounds(bounds,{padding:[40,40]});
  } else {
    map.setView([stops[0].lat,stops[0].lng],15);
  }

  if(stops.length < 2) return;

  try {
    var coords = stops.map(function(s){return s.lng+','+s.lat;}).join(';');
    var url = 'https://router.project-osrm.org/route/v1/driving/'+coords+'?overview=full&geometries=geojson&steps=false';
    var resp = await fetch(url);
    var data = await resp.json();
    if(data.routes && data.routes.length > 0){
      var route = data.routes[0];
      // Draw road geometry
      routeLayer = L.geoJSON(route.geometry,{
        style:{color:'#00897b',weight:4,opacity:0.85,dashArray:'8,6'}
      }).addTo(map);
      // Send leg durations back to Flutter
      var legDurations = route.legs.map(function(l){return l.duration;});
      window.parent.postMessage({type:'legs',legs:Array.from(legDurations)},'*');
    }
  } catch(e){
    // fallback straight line
    var latlngs = stops.map(function(s){return[s.lat,s.lng];});
    routeLayer = L.polyline(latlngs,{color:'#00897b',weight:3,dashArray:'8,6',opacity:0.7}).addTo(map);
  }
}

window.addEventListener('message',function(e){
  var d = e.data;
  if(d && d.type === 'route') drawRoute(d.stops);
});

window.parent.postMessage('route-map-ready','*');
</script>
</body>
</html>''';
  }
}
