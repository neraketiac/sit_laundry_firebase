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

class ShareRiderGps extends StatefulWidget {
  const ShareRiderGps({super.key});

  @override
  State<ShareRiderGps> createState() => _ShareRiderGpsState();
}

class _ShareRiderGpsState extends State<ShareRiderGps> {
  bool _sharing = false;
  bool _locating = false;
  bool _notified = false;
  String? _error;
  Timer? _timer;
  int _watcherCount = 0;
  StreamSubscription? _watcherSub;

  @override
  void dispose() {
    _timer?.cancel();
    _watcherSub?.cancel();
    super.dispose();
  }

  void _startWatcherStream() {
    _watcherSub?.cancel();
    _watcherSub = FirebaseService.secondaryFirestore
        .collection(_kWatchers)
        .snapshots()
        .listen((snap) {
      if (mounted) setState(() => _watcherCount = snap.docs.length);
    });
  }

  void _stopWatcherStream() {
    _watcherSub?.cancel();
    _watcherSub = null;
    if (mounted) setState(() => _watcherCount = 0);
  }

  void _toggleSharing(bool val) {
    setState(() {
      _sharing = val;
      _notified = false;
    });
    if (val) {
      _pushLocation(notify: true);
      _startWatcherStream();
      _timer = Timer.periodic(
        const Duration(seconds: 15),
        (_) => _pushLocation(notify: false),
      );
    } else {
      _timer?.cancel();
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
            _timer?.cancel();
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
        if (_sharing)
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
                    const Icon(
                      Icons.remove_red_eye,
                      size: 15,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_watcherCount ${_watcherCount == 1 ? 'customer' : 'customers'} watching',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
