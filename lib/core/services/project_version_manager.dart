import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/global/app_version.dart';
import 'package:laundry_firebase/features/fund_check/services/fund_check_service.dart';
import 'package:laundry_firebase/features/fund_check/models/fund_check_model.dart';
import 'dart:html' as html;
import 'dart:async';

/// Global variable that captures the app version when page loads
/// This won't change during the session, ensuring consistent version checking
late String sessionAppVersion;

/// Manages project version checking against Firestore
/// Checks version only once on login (cached for entire session)
class ProjectVersionManager {
  ProjectVersionManager._();
  static final ProjectVersionManager instance = ProjectVersionManager._();

  // Cache the remote version with date
  static String? _cachedRemoteVersion;
  static DateTime? _lastVersionCheckDate;

  // Cache fund check for 2 hours to reduce Firestore calls
  static FundCheckModel? _cachedFundCheck;
  static DateTime? _lastFundCheckTime;
  static const Duration _fundCheckCacheDuration = Duration(hours: 2);

  /// Initialize session version on app startup
  /// Call this once when the app first loads
  static void initializeSessionVersion() {
    sessionAppVersion = appVersion;
    debugPrint('Session version initialized: $sessionAppVersion');
  }

  /// Check version when entering laundry (after login)
  /// Fetches from Firestore and caches with today's date
  /// Will re-check only if it's a new day
  Future<void> checkVersionOnLogin(BuildContext context) async {
    try {
      final remoteVersion = await _fetchVersionFromFirestore();

      // Cache the version and today's date
      _cachedRemoteVersion = remoteVersion;
      _lastVersionCheckDate = DateTime.now();

      if (remoteVersion != null) {
        debugPrint(
            '✅ Version checked at login: $remoteVersion (will re-check tomorrow)');
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
  /// Only fetches if:
  /// 1. No version cached yet, OR
  /// 2. Current date is different from cached date (new day)
  /// This ensures users get critical updates daily while avoiding unnecessary checks
  Future<bool> checkVersionOnMainButton(BuildContext context) async {
    try {
      // Check if we should re-fetch version (new day check)
      if (_shouldCheckVersionAgain()) {
        debugPrint('📅 New day detected, re-checking version from Firestore');
        final remoteVersion = await _fetchVersionFromFirestore();

        if (remoteVersion != null) {
          // Update cache and date
          _cachedRemoteVersion = remoteVersion;
          _lastVersionCheckDate = DateTime.now();
          debugPrint('✅ Version checked today: $remoteVersion');

          if (_isOutdated(remoteVersion)) {
            _showVersionMessage(context, remoteVersion);
            return false; // Block action if outdated
          }
        }
      } else if (_cachedRemoteVersion != null &&
          _isOutdated(_cachedRemoteVersion!)) {
        // Version was outdated, still show message
        debugPrint('⚠️ Version still outdated, blocking action');
        _showVersionMessage(context, _cachedRemoteVersion!);
        return false;
      } else if (_cachedRemoteVersion != null) {
        debugPrint('✅ Using cached version: $_cachedRemoteVersion (same day)');
      }

      // Version is good, proceed to fund check validation
      return await _validateFundCheck(context);
    } catch (e) {
      // Fail silently - allow action to proceed
      debugPrint('Version check failed: $e');
      return true;
    }
  }

  /// Determine if version should be re-checked
  /// Returns true if today's date is different from cached date
  static bool _shouldCheckVersionAgain() {
    if (_lastVersionCheckDate == null) {
      return true; // Never checked, do it now
    }

    final today = DateTime.now();
    final cachedDate = _lastVersionCheckDate!;

    // Compare only year, month, day (ignore time)
    return today.year != cachedDate.year ||
        today.month != cachedDate.month ||
        today.day != cachedDate.day;
  }

  /// Determine if fund check should be re-fetched
  /// Returns true if more than 2 hours have passed since last check
  static bool _shouldCheckFundAgain() {
    if (_lastFundCheckTime == null) {
      return true; // Never checked, do it now
    }

    final now = DateTime.now();
    final timeSinceLastCheck = now.difference(_lastFundCheckTime!);
    return timeSinceLastCheck > _fundCheckCacheDuration;
  }

  /// Check if it's a new day and reset fund checks if needed
  /// Called after version check passes
  Future<void> _checkAndResetDailyFundChecks() async {
    try {
      final fundCheck = await _fetchFundCheck();
      if (fundCheck == null) {
        // No record exists yet, create a new one for today
        await FirebaseFirestore.instance
            .collection('fund_checks')
            .add(FundCheckModel(
              id: '',
              logDate: Timestamp.now(),
              morningEnable: true,
              lunchEnable: true,
              dinnerEnable: true,
              morningCheck: false,
              lunchCheck: false,
              dinnerCheck: false,
            ).toJson());
        debugPrint('✅ New fund check record created for today');
        return;
      }

      // Check if it's a new day
      if (FundCheckService.isNewDay(fundCheck.logDate)) {
        // Reset for new day
        await FirebaseFirestore.instance
            .collection('fund_checks')
            .doc(fundCheck.id)
            .update(FundCheckService.resetChecksForNewDay(fundCheck).toJson());
        debugPrint('✅ Fund checks reset for new day');
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
      // Check and reset daily fund checks if needed
      await _checkAndResetDailyFundChecks();

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

  /// Fetch today's fund check record from Firestore with timeout
  /// Uses efficient timestamp-based query
  /// Caches result for 2 hours to reduce Firestore calls
  Future<FundCheckModel?> _fetchFundCheck() async {
    try {
      // Check if we should use cached fund check (2 hour cache)
      if (!_shouldCheckFundAgain() && _cachedFundCheck != null) {
        final timeSinceCache =
            DateTime.now().difference(_lastFundCheckTime!).inMinutes;
        debugPrint(
            '✅ Using cached fund check (${timeSinceCache} min old, cache valid for 120 min)');
        return _cachedFundCheck;
      }

      debugPrint('📡 Fetching fund check from Firestore...');
      final today = DateTime.now();

      // Query using a single efficient timestamp range
      final querySnapshot = await FirebaseFirestore.instance
          .collection('fund_checks')
          .where('logDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                DateTime(today.year, today.month, today.day, 0, 0, 0),
              ))
          .where('logDate',
              isLessThan: Timestamp.fromDate(
                DateTime(today.year, today.month, today.day + 1, 0, 0, 0),
              ))
          .limit(1)
          .get(const GetOptions(source: Source.server))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('Fund check fetch timeout'),
          );

      if (querySnapshot.docs.isEmpty) {
        // Cache the null result too
        _cachedFundCheck = null;
        _lastFundCheckTime = DateTime.now();
        debugPrint('✅ Fund check: No record found (cached for 2 hours)');
        return null;
      }

      final doc = querySnapshot.docs.first;
      final fundCheck = FundCheckModel.fromJson(doc.data(), doc.id);

      // Cache the result
      _cachedFundCheck = fundCheck;
      _lastFundCheckTime = DateTime.now();
      debugPrint('✅ Fund check fetched and cached for 2 hours');

      return fundCheck;
    } catch (e) {
      debugPrint('Failed to fetch fund check: $e');
      // Return cached version if available, even if query failed
      if (_cachedFundCheck != null) {
        debugPrint('⚠️ Using stale cached fund check due to network error');
        return _cachedFundCheck;
      }
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
