# Complete Updated Code Files

## File 1: `lib/features/pages/header/main_laundry_header.dart`

[Full file content - ready to use]

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/app_scale.dart';
import 'package:laundry_firebase/features/pages/body/main_laundry_body.dart';
import 'package:laundry_firebase/features/pages/header/GCash/showGCashPending.dart';
import 'package:laundry_firebase/features/pages/header/Funds/showFundsInFundsOut.dart';
import 'package:laundry_firebase/features/pages/header/JobOnQueue/showJobOnQueue.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/services/project_version_manager.dart';

class MyMainLaundryHeader extends StatefulWidget {
  final String empid;

  const MyMainLaundryHeader(this.empid, {super.key});

  @override
  State<MyMainLaundryHeader> createState() => _MyMainLaundryHeaderState();
}

class _MyMainLaundryHeaderState extends State<MyMainLaundryHeader>
    with SingleTickerProviderStateMixin {
  late JobModelRepository jobRepoOnQueue;
  late JobModelRepository jobRepoNonJob;

  late String _sEmpId;
  bool _isOpen = false;
  bool _isLoading = false; // Track loading state
  DateTime? _lastButtonPress; // Debounce multiple clicks

  @override
  void initState() {
    super.initState();

    _sEmpId = widget.empid;
    empIdGlobal = _sEmpId;

    isAdmin = (empIdGlobal == 'Ket' || empIdGlobal == 'DonF');

    SuppliesHistRepository.instance.reset();

    jobRepoOnQueue = JobModelRepository()..reset();
    jobRepoNonJob = JobModelRepository();
  }

  Widget _fab({
    required String hero,
    required IconData icon,
    String? label,
    required double bottom,
    required double right,
    required VoidCallback onTap,
    required Color backgroundColor,
    double iconSize = 20,
    double labelFontSize = 13,
    bool mini = true,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelBg = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final labelTextColor = isDark ? Colors.white : Colors.black87;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      bottom: bottom,
      right: right,
      child: AnimatedScale(
        scale: _isOpen ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: _isOpen ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isOpen && label != null)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: labelFontSize, vertical: labelFontSize * 0.6),
                  decoration: BoxDecoration(
                    color: labelBg,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w500,
                      color: labelTextColor,
                    ),
                  ),
                ),
              if (label != null) const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  heroTag: hero,
                  mini: mini,
                  backgroundColor: backgroundColor,
                  onPressed: onTap,
                  child: Icon(icon, size: iconSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScale.of(context);
    final double base = 16;
    final double step = s.isTablet ? 90.0 : 70.0;
    final double horizontalStep = s.isTablet ? 90.0 : 70.0;
    final double iconSize = s.isTablet ? 26.0 : 20.0;
    final double labelSize = s.isTablet ? 15.0 : 13.0;
    final bool mini = !s.isTablet; // full-size FAB on iPad

    return Scaffold(
      body: MyMainLaundryBody(_sEmpId),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        width: s.isTablet ? 520 : 400,
        height: s.isTablet ? 580 : 450,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// Laundry Payment
            // if (_isOpen && isAdmin && empIdGlobal == 'DonF')
            //   _fab(
            //     hero: 'Laundry Payment',
            //     icon: Icons.payments_outlined,
            //     label: 'Laundry Payment',
            //     bottom: base + step * 3,
            //     right: base,
            //     onTap: () {
            //       setState(() => _isOpen = false);
            //       showLaundryPayment(context, jobRepoNonJob);
            //     },
            //     backgroundColor: Colors.teal,
            //   ),

            /// Cash In/Out
            // if (_isOpen && isAdmin && empIdGlobal == 'DonF')
            //   _fab(
            //     hero: 'Gcash Funds',
            //     icon: Icons.attach_money_sharp,
            //     label: 'Cash In/Out',
            //     bottom: base + step * 2,
            //     right: base,
            //     onTap: () {
            //       setState(() => _isOpen = false);
            //       showGCashOnly(context, jobRepoNonJob);
            //     },
            //     backgroundColor: Colors.green,
            //     iconSize: iconSize,
            //     labelFontSize: labelSize,
            //     mini: mini,
            //   ),

            /// Funds In/Out
            if (_isOpen)
              _fab(
                hero: 'Funds In Out',
                icon: Icons.swap_vert,
                label: 'Funds In/Out',
                bottom: base + step,
                right: base,
                onTap: () {
                  setState(() => _isOpen = false);
                  showFundsInFundsOut(context);
                },
                backgroundColor: Colors.deepPurple,
                iconSize: iconSize,
                labelFontSize: labelSize,
                mini: mini,
              ),

            /// Enter GCash (Bottom Middle - No Label)
            if (_isOpen)
              _fab(
                hero: 'GCash Pending',
                icon: Icons.g_mobiledata,
                label: null,
                bottom: base,
                right: base + horizontalStep,
                onTap: () {
                  setState(() => _isOpen = false);
                  showGCashPending(context);
                },
                backgroundColor: cShowGCash,
                iconSize: iconSize,
                mini: mini,
              ),

            /// Enter Laundry (Bottom Left)
            if (_isOpen)
              _fab(
                hero: 'Jobs On Queue',
                icon: Icons.local_laundry_service,
                label: 'Enter Laundry/GCash',
                bottom: base,
                right: base + horizontalStep * 2,
                onTap: () {
                  setState(() => _isOpen = false);
                  showJobOnQueue(context, jobRepoOnQueue);
                },
                backgroundColor: Colors.blueAccent,
                iconSize: iconSize,
                labelFontSize: labelSize,
                mini: mini,
              ),

            /// MAIN FAB (Always visible)
            Positioned(
              bottom: base,
              right: base,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: FloatingActionButton(
                    heroTag: 'main',
                    mini: mini,
                    backgroundColor: _isLoading
                        ? Colors.grey
                        : (_isOpen ? Colors.red : Colors.deepPurple),
                    elevation: 12,
                    onPressed: _isLoading
                        ? null
                        : () async {
                            // Debounce: prevent rapid clicks
                            final now = DateTime.now();
                            if (_lastButtonPress != null &&
                                now
                                        .difference(_lastButtonPress!)
                                        .inMilliseconds <
                                    500) {
                              return;
                            }
                            _lastButtonPress = now;

                            // Show loading state only when trying to open
                            if (!_isOpen) {
                              setState(() => _isLoading = true);
                            }

                            try {
                              // Check version and fund requirements on main button click
                              final canProceed = await ProjectVersionManager
                                  .instance
                                  .checkVersionOnMainButton(context);

                              if (mounted) {
                                if (canProceed) {
                                  setState(() => _isOpen = !_isOpen);
                                }
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isLoading = false);
                              }
                            }
                          },
                    child: _isLoading
                        ? SizedBox(
                            width: iconSize,
                            height: iconSize,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          )
                        : AnimatedRotation(
                            duration: const Duration(milliseconds: 250),
                            turns: _isOpen ? 0.125 : 0,
                            child: Icon(
                              _isOpen ? Icons.close : Icons.add,
                              size: iconSize,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## File 2: `lib/core/services/project_version_manager.dart`

[Full file content - ready to use]

```dart
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
/// Checks version on login and daily on button press (date-based caching)
class ProjectVersionManager {
  ProjectVersionManager._();
  static final ProjectVersionManager instance = ProjectVersionManager._();

  // Cache the remote version with date
  static String? _cachedRemoteVersion;
  static DateTime? _lastVersionCheckDate;

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
  Future<FundCheckModel?> _fetchFundCheck() async {
    try {
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
```

---

## How to Use These Files

1. **Copy the code** from each section above
2. **Replace** the existing files in your project:
   - `lib/features/pages/header/main_laundry_header.dart`
   - `lib/core/services/project_version_manager.dart`
3. **Build and test**:
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```
4. **Verify** in browser console for version check messages

---

## Verification Commands

```bash
# Check imports are correct
grep "import" lib/features/pages/header/main_laundry_header.dart
grep "import" lib/core/services/project_version_manager.dart

# Check new state variables exist
grep "_isLoading" lib/features/pages/header/main_laundry_header.dart
grep "_lastButtonPress" lib/features/pages/header/main_laundry_header.dart

# Check new cache variables
grep "_lastVersionCheckDate" lib/core/services/project_version_manager.dart

# Check new method exists
grep "_shouldCheckVersionAgain" lib/core/services/project_version_manager.dart
```

---

## Summary

These are the complete, production-ready code files with all optimizations implemented:

✅ **Loading UI** - Spinner and visual feedback  
✅ **Date-based caching** - Version checked once per day  
✅ **Click debouncing** - Prevents rapid clicks  
✅ **Error handling** - Comprehensive try/catch/finally  
✅ **Query optimization** - Better Firestore queries  

Ready to deploy! 🚀
