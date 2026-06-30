import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/global/app_version.dart';
import 'package:laundry_firebase/features/fund_check/services/fund_check_service.dart';
import 'package:laundry_firebase/features/fund_check/models/fund_check_model.dart';
import 'dart:html' as html;

/// Global variable that captures the app version when page loads
/// This won't change during the session, ensuring consistent version checking
late String sessionAppVersion;

/// Manages project version checking against Firestore
/// Checks version only on login and main button click (no periodic checking)
class ProjectVersionManager {
  ProjectVersionManager._();
  static final ProjectVersionManager instance = ProjectVersionManager._();

  /// Initialize session version on app startup
  /// Call this once when the app first loads
  static void initializeSessionVersion() {
    sessionAppVersion = appVersion;
    debugPrint('Session version initialized: $sessionAppVersion');
  }

  /// Check version when entering laundry (after login)
  /// Fetches from Firestore and compares with session version
  /// Shows message if outdated
  Future<void> checkVersionOnLogin(BuildContext context) async {
    try {
      final remoteVersion = await _fetchVersionFromFirestore();
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
  /// Fetches fresh version from Firestore every time
  /// Shows message if outdated
  /// If version is updated, checks fund requirements before allowing action
  Future<bool> checkVersionOnMainButton(BuildContext context) async {
    try {
      final remoteVersion = await _fetchVersionFromFirestore();
      if (remoteVersion != null) {
        if (_isOutdated(remoteVersion)) {
          _showVersionMessage(context, remoteVersion);
          return false; // Block action if version outdated
        }
      }

      // Version is good, check if it's a new day and reset checks if needed
      await _checkAndResetDailyFundChecks();

      // Now check fund check requirements
      final fundCheckPassed = await _validateFundCheck(context);
      return fundCheckPassed;
    } catch (e) {
      // Fail silently - allow action to proceed
      debugPrint('Version check failed: $e');
      return true;
    }
  }

  /// Check if it's a new day and reset fund checks if needed
  /// Called after version check passes
  Future<void> _checkAndResetDailyFundChecks() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayStart = Timestamp.fromDate(today);
      final todayEnd = Timestamp.fromDate(today.add(const Duration(days: 1)));

      // Check if today's fund check record exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection('fund_checks')
          .where('logDate', isGreaterThanOrEqualTo: todayStart)
          .where('logDate', isLessThan: todayEnd)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final fundCheckDoc = querySnapshot.docs.first;
        final logDate = fundCheckDoc['logDate'] as Timestamp;

        // Check if logDate is from a previous day
        final logDateTime = logDate.toDate();
        if (logDateTime.year != now.year ||
            logDateTime.month != now.month ||
            logDateTime.day != now.day) {
          // New day detected - reset all checks to false
          await FirebaseFirestore.instance
              .collection('fund_checks')
              .doc(fundCheckDoc.id)
              .update({
            'morningCheck': false,
            'lunchCheck': false,
            'dinnerCheck': false,
            'logDate': Timestamp.now(),
          });

          debugPrint('🔄 New day detected - Fund checks reset to false');
        }
      }
    } catch (e) {
      debugPrint('Error checking/resetting daily fund checks: $e');
      // Fail silently - don't block main button
    }
  }

  /// Validate fund check requirements
  /// Returns true if all requirements are met
  /// Returns false if fund check is required but not completed
  Future<bool> _validateFundCheck(BuildContext context) async {
    try {
      // Fetch current fund check from Firestore
      final fundCheck = await _fetchFundCheck();

      if (fundCheck == null) {
        // No fund check record found, allow to proceed
        return true;
      }

      // Validate time-based fund check
      final errorMessage =
          FundCheckService.validateTimeBasedFundCheck(fundCheck);

      if (errorMessage != null) {
        // Show validation failure dialog
        if (context.mounted) {
          final result = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Fund Check Required'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.orange.shade700,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Period: ${FundCheckService.getCurrentTimePeriod().toUpperCase()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Go to Fund Check'),
                  ),
                ],
              );
            },
          );

          return result == null ? false : !result;
        }
        return false;
      }

      // All checks passed
      return true;
    } catch (e) {
      debugPrint('Fund check validation failed: $e');
      // Fail silently - allow action to proceed
      return true;
    }
  }

  /// Fetch today's fund check record from Firestore
  Future<FundCheckModel?> _fetchFundCheck() async {
    try {
      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final querySnapshot = await FirebaseFirestore.instance
          .collection('fund_checks')
          .where('logDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                DateTime(today.year, today.month, today.day, 0, 0, 0),
              ))
          .where('logDate',
              isLessThan: Timestamp.fromDate(
                DateTime(today.year, today.month, today.day, 23, 59, 59),
              ))
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      return FundCheckModel.fromJson(doc.data(), doc.id);
    } catch (e) {
      debugPrint('Failed to fetch fund check: $e');
      return null;
    }
  }

  /// Fetch version from Firestore project_version/current
  Future<String?> _fetchVersionFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('project_version')
          .doc('current')
          .get();

      final version = doc.data()?['version'] as String?;
      return version;
    } catch (e) {
      debugPrint('Failed to fetch version from Firestore: $e');
      return null;
    }
  }

  /// Compare versions: returns true if remote > local (session version)
  bool _isOutdated(String remoteVersion) {
    return _compareVersions(sessionAppVersion, remoteVersion) < 0;
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

  /// Show version outdated message - user must logout to continue
  void _showVersionMessage(BuildContext context, String remoteVersion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Version Available'),
          content: Text(
            'You are using the old version, new version $remoteVersion is available.\n\n'
            'Please logout and login again to load the latest version.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Force logout
                _forceLogout(context);
              },
              child: const Text('Logout Now'),
            ),
          ],
        );
      },
    );
  }

  /// Force logout by clearing local storage and reloading
  void _forceLogout(BuildContext context) {
    // Clear saved login details from localStorage
    html.window.localStorage.remove('customer_code');

    // Close the dialog
    Navigator.of(context).pop();

    // Reload page to return to login screen
    html.window.location.reload();
  }
}
