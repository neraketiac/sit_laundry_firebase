import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/global/app_version.dart';

/// Manages project version synchronization with Firestore
/// Ensures the running project version matches the Firestore version
class ProjectVersionManager {
  ProjectVersionManager._();
  static final ProjectVersionManager instance = ProjectVersionManager._();

  static const String _versionCollection = 'project_version';
  static const String _versionDoc = 'current';
  static const String _versionField = 'version';

  bool _isVersionValid = false;
  bool _versionChecked = false;

  bool get isVersionValid => _isVersionValid;
  bool get versionChecked => _versionChecked;

  /// Returns true if version is valid (local >= firestore)
  /// This can be called after checkAndSyncVersion() has been called
  bool isVersionCurrentlyValid() => _isVersionValid;

  /// Checks if the running project version matches Firestore version
  /// Returns true if versions match or if local version is higher (will update Firestore)
  /// Returns false if local version is lower (requires browser refresh)
  Future<bool> checkAndSyncVersion() async {
    try {
      final primaryDb = FirebaseFirestore.instance;

      // Get Firestore version
      final versionDoc =
          await primaryDb.collection(_versionCollection).doc(_versionDoc).get();

      final firestoreVersion =
          versionDoc.data()?[_versionField] as String? ?? '0.0';

      print('📦 Project Version Check:');
      print('   Local: $appVersion');
      print('   Firestore: $firestoreVersion');

      // Compare versions
      final comparison = _compareVersions(appVersion, firestoreVersion);

      if (comparison > 0) {
        // Local version is higher — update Firestore
        print('   ✅ Local version is newer, updating Firestore...');
        await primaryDb
            .collection(_versionCollection)
            .doc(_versionDoc)
            .set({_versionField: appVersion}, SetOptions(merge: true));
        _isVersionValid = true;
      } else if (comparison == 0) {
        // Versions match
        print('   ✅ Versions match');
        _isVersionValid = true;
      } else {
        // Local version is lower — require refresh
        print('   ❌ Local version is outdated, refresh required');
        _isVersionValid = false;
      }

      _versionChecked = true;
      return _isVersionValid;
    } catch (e) {
      print('❌ Version check error: $e');
      // On error, allow access (fail open)
      _isVersionValid = true;
      _versionChecked = true;
      return true;
    }
  }

  /// Compares two version strings in format "major.minor"
  /// Returns: 1 if v1 > v2, -1 if v1 < v2, 0 if equal
  int _compareVersions(String v1, String v2) {
    try {
      final parts1 = v1.split('.').map(int.parse).toList();
      final parts2 = v2.split('.').map(int.parse).toList();

      // Pad with zeros if needed
      while (parts1.length < parts2.length) parts1.add(0);
      while (parts2.length < parts1.length) parts2.add(0);

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
