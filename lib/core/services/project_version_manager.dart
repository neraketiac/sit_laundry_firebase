import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/app_version.dart';
import 'dart:html' as html;
import 'dart:convert';

/// Manages project version checking against web/version.json
/// Checks version only on login and main button click (no periodic checking)
class ProjectVersionManager {
  ProjectVersionManager._();
  static final ProjectVersionManager instance = ProjectVersionManager._();

  /// Check version when entering laundry (after login)
  /// Fetches from web/version.json and compares with app version
  /// Shows message if outdated
  Future<void> checkVersionOnLogin(BuildContext context) async {
    try {
      final remoteVersion = await _fetchVersionFromWeb();
      if (remoteVersion != null) {
        if (_isOutdated(remoteVersion)) {
          _showVersionMessage(context, remoteVersion);
        }
      }
    } catch (e) {
      // Fail silently - don't block login
      debugPrint('Version check failed: $e');
    }
  }

  /// Check version when main button is clicked
  /// Fetches fresh version from web/version.json every time
  /// Shows message if outdated
  Future<void> checkVersionOnMainButton(BuildContext context) async {
    try {
      final remoteVersion = await _fetchVersionFromWeb();
      if (remoteVersion != null) {
        if (_isOutdated(remoteVersion)) {
          _showVersionMessage(context, remoteVersion);
        }
      }
    } catch (e) {
      // Fail silently - don't block main button
      debugPrint('Version check failed: $e');
    }
  }

  /// Fetch version from web/version.json hosted on Firebase Hosting
  Future<String?> _fetchVersionFromWeb() async {
    try {
      final response =
          await html.HttpRequest.request('/version.json', method: 'GET');

      if (response.status == 200) {
        final jsonData = jsonDecode(response.responseText ?? '{}');
        final version = jsonData['version'] as String?;
        return version;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to fetch version from web/version.json: $e');
      return null;
    }
  }

  /// Compare versions: returns true if remote > local
  bool _isOutdated(String remoteVersion) {
    return _compareVersions(appVersion, remoteVersion) < 0;
  }

  /// Compare two version strings in format "major.minor"
  /// Returns: 1 if v1 > v2, -1 if v1 < v2, 0 if equal
  int _compareVersions(String v1, String v2) {
    try {
      final parts1 = v1.split('.').map(int.parse).toList();
      final parts2 = v2.split('.').map(int.parse).toList();

      // Pad with zeros if needed
      while (parts1.length < parts2.length) {
        parts1.add(0);
      }
      while (parts2.length < parts1.length) {
        parts2.add(0);
      }

      for (int i = 0; i < parts1.length; i++) {
        if (parts1[i] > parts2[i]) return 1;
        if (parts1[i] < parts2[i]) return -1;
      }
      return 0;
    } catch (_) {
      return 0; // Treat parse errors as equal
    }
  }

  /// Show version outdated message
  void _showVersionMessage(BuildContext context, String remoteVersion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Version Available'),
          content: Text(
            'You are using the old version, new version $remoteVersion is available.\n\n'
            'Please refresh the page to load it.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () {
                // Refresh the page
                _refreshPage();
              },
              child: const Text('Refresh Now'),
            ),
          ],
        );
      },
    );
  }

  /// Refresh the browser page
  void _refreshPage() {
    html.window.location.reload();
  }
}
