import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/services/project_version_manager.dart';
import 'package:web/web.dart' as web;

/// Overlay widget that blocks UI if version is outdated
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
  String? _firestoreVersion;

  @override
  void initState() {
    super.initState();
    _versionCheckFuture = _checkVersionAndGetFirestoreVersion();
  }

  Future<bool> _checkVersionAndGetFirestoreVersion() async {
    try {
      final versionDoc = await FirebaseFirestore.instance
          .collection('project_version')
          .doc('current')
          .get();
      _firestoreVersion = versionDoc.data()?['version'] as String? ?? 'unknown';
    } catch (_) {
      _firestoreVersion = 'unknown';
    }
    return ProjectVersionManager.instance.checkAndSyncVersion();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _versionCheckFuture,
      builder: (context, snapshot) {
        // Still checking
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

        // Version check failed or outdated
        if (snapshot.data == false) {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Cannot use this page using old version. Please refresh page to use version $_firestoreVersion',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
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
