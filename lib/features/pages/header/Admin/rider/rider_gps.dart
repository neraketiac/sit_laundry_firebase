import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'package:laundry_firebase/core/services/firebase_service.dart';

const _kWatchers = 'rider_watchers';
const _kCollection = 'rider_location';
const _kDoc = 'current';
const _kSubCollection = 'push_subscriptions';
const _kPushServer = 'https://rider-push-server.onrender.com/send';

// Watcher is considered stale if lastSeen is older than this
const _kStaleThreshold = Duration(minutes: 2);

class AdminRiderPanel extends StatefulWidget {
  const AdminRiderPanel({super.key});

  @override
  State<AdminRiderPanel> createState() => _AdminRiderPanelState();
}

class _AdminRiderPanelState extends State<AdminRiderPanel> {
  bool _sharing = false;
  bool _locating = false;
  bool _notified = false;
  String? _error;
  Timer? _locationTimer;
  Timer? _cleanupTimer;
  int _watcherCount = 0;
  int _staleCount = 0;
  StreamSubscription? _watcherSub;

  @override
  void dispose() {
    _locationTimer?.cancel();
    _cleanupTimer?.cancel();
    _watcherSub?.cancel();
    super.dispose();
  }

  void _startWatcherStream() {
    _watcherSub?.cancel();
    _watcherSub = FirebaseService.secondaryFirestore
        .collection(_kWatchers)
        .snapshots()
        .listen((snap) {
      if (!mounted) return;
      final now = DateTime.now();
      int stale = 0;
      for (final doc in snap.docs) {
        final ts = doc.data()['lastSeen'];
        // Only mark stale if lastSeen exists AND is old
        // If no lastSeen field, assume customer app doesn't write it — treat as active
        if (ts is Timestamp) {
          final age = now.difference(ts.toDate());
          if (age > _kStaleThreshold) stale++;
        }
      }
      setState(() {
        _watcherCount = snap.docs.length;
        _staleCount = stale;
      });
    });
  }

  void _stopWatcherStream() {
    _watcherSub?.cancel();
    _watcherSub = null;
    if (mounted)
      setState(() {
        _watcherCount = 0;
        _staleCount = 0;
      });
  }

  /// Deletes watcher docs with missing or stale lastSeen
  Future<int> _cleanStaleWatchers() async {
    final snap =
        await FirebaseService.secondaryFirestore.collection(_kWatchers).get();
    final now = DateTime.now();
    final batch = FirebaseService.secondaryFirestore.batch();
    int removed = 0;
    for (final doc in snap.docs) {
      final ts = doc.data()['lastSeen'];
      // Only remove if lastSeen exists AND is old
      if (ts is Timestamp) {
        if (now.difference(ts.toDate()) > _kStaleThreshold) {
          batch.delete(doc.reference);
          removed++;
        }
      }
    }
    if (removed > 0) await batch.commit();
    return removed;
  }

  void _toggleSharing(bool val) {
    setState(() {
      _sharing = val;
      _notified = false;
    });
    if (val) {
      _pushLocation(notify: true);
      _startWatcherStream();
      _locationTimer = Timer.periodic(
        const Duration(seconds: 15),
        (_) => _pushLocation(notify: false),
      );
      // Auto-clean stale watchers every 60 seconds
      _cleanupTimer = Timer.periodic(
        const Duration(seconds: 60),
        (_) => _cleanStaleWatchers(),
      );
    } else {
      _locationTimer?.cancel();
      _cleanupTimer?.cancel();
      _stopWatcherStream();
      FirebaseService.secondaryFirestore
          .collection(_kCollection)
          .doc(_kDoc)
          .delete();
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
      await FirebaseService.secondaryFirestore
          .collection(_kCollection)
          .doc(_kDoc)
          .set({
        'lat': lat,
        'lng': lng,
        'updatedAt': Timestamp.now(),
      });

      if (notify && !_notified) {
        await _notifyAllSubscribers();
        if (mounted) setState(() => _notified = true);
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Location error: $e');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '🛵 Rider Location Sharing',
        style: TextStyle(fontSize: 15),
      ),
      content: _buildPanel(),
      actions: [
        TextButton(
          onPressed: () {
            _locationTimer?.cancel();
            _cleanupTimer?.cancel();
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Switch(value: _sharing, onChanged: _toggleSharing),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _sharing ? 'Sharing location...' : 'Location sharing OFF',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _sharing ? Colors.green : Colors.blueGrey,
                ),
              ),
            ),
            if (_locating)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        if (_sharing) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GPS updates every 15 seconds.\nCustomers can now see your location.',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye,
                        size: 15, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text(
                      '$_watcherCount ${_watcherCount == 1 ? 'customer' : 'customers'} watching',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_staleCount > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '($_staleCount stale)',
                        style:
                            const TextStyle(fontSize: 11, color: Colors.orange),
                      ),
                    ],
                  ],
                ),
                if (_staleCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: TextButton.icon(
                      onPressed: () async {
                        final removed = await _cleanStaleWatchers();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Removed $removed stale watcher(s).')),
                          );
                        }
                      },
                      icon: const Icon(Icons.cleaning_services, size: 14),
                      label: const Text('Clean stale watchers',
                          style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                if (_notified)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      '✅ Subscribers notified.',
                      style: TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 6),
          Text(
            _error!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

Future<void> _notifyAllSubscribers() async {
  final snap = await FirebaseService.secondaryFirestore
      .collection(_kSubCollection)
      .get();
  final tokens =
      snap.docs.map((d) => d.data()['token']).whereType<String>().toList();

  if (tokens.isEmpty) return;

  await http.post(
    Uri.parse(_kPushServer),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'tokens': tokens,
      'title': '🛵 Rider is Available!',
      'body': 'Your rider is now online and sharing location.',
      'url': 'https://washkolang.online',
    }),
  );
}
