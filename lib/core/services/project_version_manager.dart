import 'dart:async';

import 'package:laundry_firebase/core/global/app_version.dart';
import 'package:web/web.dart' as web;

/// Manages project version synchronization with version.json
/// Fetches version from Firebase Hosting (no Firestore reads)
/// Caches version check results for 15 minutes to avoid excessive HTTP requests
class ProjectVersionManager {
  ProjectVersionManager._();
  static final ProjectVersionManager instance = ProjectVersionManager._();

  static const Duration _cacheDuration = Duration(minutes: 15);

  bool _isVersionValid = true;
  bool _versionChecked = false;
  DateTime? _lastCheckTime;

  bool get isVersionValid => _isVersionValid;
  bool get versionChecked => _versionChecked;

  /// Returns true if version is valid (local >= remote)
  bool isVersionCurrentlyValid() => _isVersionValid;

  /// Checks if the running project version matches remote version
  /// Fetches from /version.json (no Firestore reads)
  /// Returns cached result if checked within last 15 minutes
  /// Returns true if versions match or if local version is higher
  /// Returns false if local version is lower (requires browser refresh)
  Future<bool> checkAndSyncVersion() async {
    // Skip check if done within last 15 minutes
    if (_lastCheckTime != null) {
      final timeSinceLastCheck = DateTime.now().difference(_lastCheckTime!);
      if (timeSinceLastCheck < _cacheDuration) {
        return _isVersionValid;
      }
    }

    try {
      // Fetch version.json from Firebase Hosting using XMLHttpRequest
      final completer = Completer<String>();
      final xhr = web.XMLHttpRequest();

      // Use absolute URL to ensure proper CORS and caching behavior
      final versionUrl = '${web.window.location.origin}/version.json';

      xhr.open('GET', versionUrl);

      xhr.addEventListener(
          'load',
          (web.Event _) {
            if (xhr.status == 200) {
              completer.complete(xhr.responseText);
            } else {
              completer.completeError(
                  Exception('Failed to fetch version.json: ${xhr.status}'));
            }
          } as web.EventListener?);

      xhr.addEventListener(
          'error',
          (web.Event _) {
            completer
                .completeError(Exception('Network error fetching version'));
          } as web.EventListener?);

      xhr.send();

      final jsonText = await completer.future;
      final jsonData = _parseJson(jsonText);
      final remoteVersion = jsonData['version'] as String? ?? '0.0';

      // Compare versions
      final comparison = _compareVersions(appVersion, remoteVersion);

      if (comparison < 0) {
        // Local version is lower — require refresh
        _isVersionValid = false;
      } else {
        // Versions match or local is higher
        _isVersionValid = true;
      }

      _versionChecked = true;
      _lastCheckTime = DateTime.now();
      return _isVersionValid;
    } catch (e) {
      // On error, allow access (fail open)
      _isVersionValid = true;
      _versionChecked = true;
      _lastCheckTime = DateTime.now();
      return true;
    }
  }

  /// Simple JSON parser for version.json
  Map<String, dynamic> _parseJson(String jsonText) {
    try {
      // Simple regex-based parsing for {"version": "1.191"}
      final versionMatch =
          RegExp(r'"version"\s*:\s*"([^"]+)"').firstMatch(jsonText);
      if (versionMatch != null) {
        return {'version': versionMatch.group(1)};
      }
      return {'version': '0.0'};
    } catch (_) {
      return {'version': '0.0'};
    }
  }

  /// Compares two version strings in format "major.minor"
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

  /// Gets a user-friendly message about the version status
  String getVersionMessage() {
    if (!_versionChecked) {
      return 'Checking version...';
    }
    if (_isVersionValid) {
      return 'Version OK';
    }
    return 'Version outdated - please refresh the browser';
  }
}
