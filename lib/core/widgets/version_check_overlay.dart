import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/services/project_version_manager.dart';
import 'package:web/web.dart' as web;

/// Overlay widget that blocks UI if version is outdated
/// Performs periodic version checks every 15 minutes (per session)
class VersionCheckOverlay extends StatefulWidget {
  final Widget child;

  const VersionCheckOverlay({
    super.key,
    required this.child,
  });

  @override
  State<VersionCheckOverlay> createState() => _VersionCheckOverlayState();
}

class _VersionCheckOverlayState extends State<VersionCheckOverlay> {
  late Future<bool> _versionCheckFuture;
  bool _isVersionValid = true;
  static const String _sessionIdKey = 'version_check_session_id';
  static const Duration _checkInterval = Duration(minutes: 15);

  @override
  void initState() {
    super.initState();
    _versionCheckFuture = _checkVersionAndGetFirestoreVersion();
    // Start periodic check (1 hour interval, per session)
    _startPeriodicVersionCheck();
  }

  /// Generates a unique session ID to prevent duplicate checks across tabs
  String _getOrCreateSessionId() {
    String? sessionId = web.window.localStorage.getItem(_sessionIdKey);
    if (sessionId == null) {
      sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      web.window.localStorage.setItem(_sessionIdKey, sessionId);
    }
    return sessionId;
  }

  void _startPeriodicVersionCheck() {
    final sessionId = _getOrCreateSessionId();

    Future.delayed(_checkInterval, () {
      if (mounted) {
        // Only check if this is still the same session
        final currentSessionId = web.window.localStorage.getItem(_sessionIdKey);
        if (currentSessionId == sessionId) {
          _checkVersionAndGetFirestoreVersion().then((isValid) {
            if (mounted) {
              setState(() {
                _isVersionValid = isValid;
              });
            }
          });
          _startPeriodicVersionCheck(); // Schedule next check
        }
      }
    });
  }

  Future<bool> _checkVersionAndGetFirestoreVersion() async {
    return ProjectVersionManager.instance.checkAndSyncVersion();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _versionCheckFuture,
      builder: (context, snapshot) {
        // Still checking on initial load
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Checking version...'),
                ],
              ),
            ),
          );
        }

        // Version check failed or outdated (from initial or periodic check)
        if (snapshot.data == false || !_isVersionValid) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_rounded,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Version Outdated',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Cannot use this page using old version. Please refresh the browser to download the latest version.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Refresh the page
                      web.window.location.reload();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Browser'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Version is valid or check passed
        return widget.child;
      },
    );
  }
}
