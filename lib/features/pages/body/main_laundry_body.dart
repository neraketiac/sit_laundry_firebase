import 'package:flutter/material.dart';
import 'package:laundry_firebase/app.dart';
import 'package:laundry_firebase/core/utils/app_scale.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';
import 'package:web/web.dart' as web;
import 'package:laundry_firebase/core/global/app_version.dart';
import 'package:laundry_firebase/core/global/variables_ble.dart';
import 'package:laundry_firebase/core/global/variables_det.dart';
import 'package:laundry_firebase/core/global/variables_fab.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';
import 'package:laundry_firebase/core/utils/LaundryColors.dart';
import 'package:laundry_firebase/features/employees/models/employeesetupmodel.dart';
import 'package:laundry_firebase/features/items/repository/other_item_repository.dart';
import 'package:laundry_firebase/features/pages/body/GCash/readDataGCashDone.dart';
import 'package:laundry_firebase/features/pages/body/GCash/readDataGCashPending.dart';
import 'package:laundry_firebase/features/pages/body/Items/readItemsHist.dart';
import 'package:laundry_firebase/features/pages/body/Loyalty/enterloyaltycode.dart';
import 'package:laundry_firebase/features/pages/body/Employee/readDataEmployeeCurr.dart';
import 'package:laundry_firebase/features/pages/body/Employee/readDataEmployeeHist.dart';
import 'package:laundry_firebase/features/pages/body/JobsCompleted/readDataJobsCompleted.dart';
import 'package:laundry_firebase/features/customers/repository/customer_repository.dart';
import 'package:laundry_firebase/features/pages/body/JobsOnGoing/readDataJobsOnGoing.dart';
import 'package:laundry_firebase/features/pages/body/JobsOnQueue/readDataJobsOnQueue.dart';
import 'package:laundry_firebase/features/pages/body/JobsDone/readDataJobsDone.dart';
import 'package:laundry_firebase/features/pages/body/rider/show_rider_orders.dart';
import 'package:laundry_firebase/features/pages/body/Supplies/readSuppliesCurrent.dart';
import 'package:laundry_firebase/features/pages/body/Supplies/readSuppliesHist.dart';
import 'package:laundry_firebase/features/pages/body/Unpaid/readUnpaidLaundry.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/copy_to_loyalty_db.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/show_enable_promo.dart';
// ── Daily Routine ──────────────────────────────────────────────
import 'package:laundry_firebase/features/pages/header/Funds/showFundCheck.dart';
import 'package:laundry_firebase/features/pages/header/Items/showItemsInOut.dart';
import 'package:laundry_firebase/features/pages/header/Employee/showCalendarDialog.dart';
import 'package:laundry_firebase/features/pages/header/Closing/showClosingCheck.dart';
// ── Rider ──────────────────────────────────────────────────────
import 'package:laundry_firebase/features/pages/header/Admin/rider/rider_location.dart';
import 'package:laundry_firebase/features/pages/header/Admin/rider/show_rider_management.dart';
// ── Tools ──────────────────────────────────────────────────────
import 'package:laundry_firebase/features/pages/header/Admin/showAdminMainPage.dart';
import 'package:laundry_firebase/features/pages/header/Admin/showCustomerLocationPage.dart';
// ── Tools > Admin ──────────────────────────────────────────────
import 'package:laundry_firebase/features/pages/header/Employee/showSalaryMaintenance.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/showBatchPromo.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/batch_promo_review_page.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/batch_fix_promo_counter_page.dart';
import 'package:laundry_firebase/features/pages/header/Admin/reports/monthly_analytics/monthly_analytics_page.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/loyalty_validation_page.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/migrateToReportsDB.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/sit_vs_loyalty.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/sit_vs_loyalty_jobs.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/showAdminDateDPage.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/show_jobs_paid.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/other_item_admin/showOtherItemsMaintenance.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/other_item_admin/showDetItemsMaintenance.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/other_item_admin/showFabItemsMaintenance.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/other_item_admin/showBleItemsMaintenance.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/AutoSalaryDateOneTimeBatch.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/batch_remove_promo_disabled_days.dart';
import 'package:laundry_firebase/core/utils/fs_usage_tracker.dart';
// ── Core ───────────────────────────────────────────────────────
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/core/services/database_employee_setup.dart';
import 'package:laundry_firebase/core/services/database_jobs.dart';
import 'package:laundry_firebase/core/global/variables.dart';

class MyMainLaundryBody extends StatefulWidget {
  final String empidClass;

  const MyMainLaundryBody(this.empidClass, {super.key});

  @override
  State<MyMainLaundryBody> createState() => _MyMainLaundryBodyState();
}

class _MyMainLaundryBodyState extends State<MyMainLaundryBody> {
  late DatabaseEmployeeSetup databaseEmployeeSetup;
  late EmployeeSetupModel empSetup;
  String _memoryUsage = "0MB";
  late Timer _memoryUpdateTimer;

  bool get _isDarkMode => empSetup.darkMode;
  Color get _scaffoldColor =>
      _isDarkMode ? const Color(0xFF121212) : Colors.deepPurple[100]!;
  Color get _appBarColor =>
      _isDarkMode ? const Color(0xFF1E1E1E) : Colors.deepPurple[100]!;
  Color get _appBarForeground => _isDarkMode ? Colors.white : Colors.black87;
  Color get _menuSelectedColor =>
      _isDarkMode ? Colors.white.withValues(alpha: 0.12) : Colors.grey[300]!;
  Color get _menuSurfaceColor =>
      _isDarkMode ? const Color(0xFF232323) : Colors.white;

  ThemeData _bodyTheme(BuildContext context) {
    if (!_isDarkMode) return Theme.of(context);

    return Theme.of(context).copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _scaffoldColor,
      appBarTheme: AppBarTheme(
        backgroundColor: _appBarColor,
        foregroundColor: _appBarForeground,
        elevation: 0,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(_menuSurfaceColor),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      // Use dark card/dialog backgrounds but let each widget control its own text
      cardColor: const Color(0xFF2A2A2A),
      cardTheme: const CardThemeData(
        color: Color(0xFF2A2A2A),
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF1F1F1F),
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
      // Only tint the default text — Cards/Dialogs with explicit colors are unaffected
      colorScheme: Theme.of(context).colorScheme.copyWith(
            brightness: Brightness.dark,
            surface: const Color(0xFF2A2A2A),
            onSurface: Colors.white,
          ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.tealAccent,
      ),
      // Menu item text — use dark surface color so text is readable
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(Colors.white),
        ),
      ),
    );
  }

  //================ MEMORY TRACKING =================
  String _getMemoryUsageString() {
    try {
      // Calculate memory based ONLY on tracked Firestore reads
      // Each document record ≈ 0.5KB average
      const double bytesPerRecord = 0.5; // KB per document

      double estimatedMB = 0;

      // Debug: Show all tracked data
      final allTracked = FsUsageTracker.instance.getAllTracked();
      debugPrint('=== TRACKER DEBUG ===');
      debugPrint('All tracked sources: $allTracked');
      debugPrint(
          'empSetup state - showLaundry: ${empSetup.showLaundry}, showFunds: ${empSetup.showFunds}, showFundsHistory: ${empSetup.showFundsHistory}, showEmployee: ${empSetup.showEmployee}');

      // ============ showFundsHistory ============
      // Includes: readDataGCashPending, readDataGCashDoneNewFormat
      if (empSetup.showFundsHistory) {
        final gcashPendingCount =
            FsUsageTracker.instance.getTrackedCount('readDataGCashPending');
        final gcashDoneCount = FsUsageTracker.instance
            .getTrackedCount('readDataGCashDoneNewFormat');
        final gcashTotalRecords = gcashPendingCount + gcashDoneCount;
        estimatedMB +=
            (gcashTotalRecords * bytesPerRecord / 1024); // Convert KB to MB
        debugPrint(
            'GCash records: $gcashTotalRecords (Pending: $gcashPendingCount, Done: $gcashDoneCount)');
      }

      // ============ showLaundry ============
      // Includes: readDataJobsOnQueue, readDataJobsOnGoing, readDataJobsDone,
      //           readDataJobsCompleted, readUnpaidLaundry, ShowRiderOrders
      if (empSetup.showLaundry) {
        final jobsQueueCount =
            FsUsageTracker.instance.getTrackedCount('readDataJobsOnQueue');
        final jobsOnGoingCount =
            FsUsageTracker.instance.getTrackedCount('readDataJobsOnGoing');
        final jobsDoneCount =
            FsUsageTracker.instance.getTrackedCount('readDataJobsDone');
        final jobsCompletedCount =
            FsUsageTracker.instance.getTrackedCount('readDataJobsCompleted');
        final unpaidLaundryCount =
            FsUsageTracker.instance.getTrackedCount('readUnpaidLaundry');
        final riderOrdersCount =
            FsUsageTracker.instance.getTrackedCount('ShowRiderOrders');

        final laundryTotalRecords = jobsQueueCount +
            jobsOnGoingCount +
            jobsDoneCount +
            jobsCompletedCount +
            unpaidLaundryCount +
            riderOrdersCount;
        estimatedMB +=
            (laundryTotalRecords * bytesPerRecord / 1024); // Convert KB to MB
        debugPrint(
            'Laundry records: $laundryTotalRecords (Queue: $jobsQueueCount, OnGoing: $jobsOnGoingCount, Done: $jobsDoneCount, Completed: $jobsCompletedCount, Unpaid: $unpaidLaundryCount, Rider: $riderOrdersCount)');
      }

      // ============ showFunds ============
      // Includes: readSuppliesCurrent, readSuppliesHist, readItemsHist
      if (empSetup.showFunds) {
        final suppliesCurrentCount =
            FsUsageTracker.instance.getTrackedCount('readSuppliesCurrent');
        final suppliesHistoryCount =
            FsUsageTracker.instance.getTrackedCount('readSuppliesHist');
        final itemsHistoryCount =
            FsUsageTracker.instance.getTrackedCount('readItemsHist');

        final fundsTotalRecords =
            suppliesCurrentCount + suppliesHistoryCount + itemsHistoryCount;
        estimatedMB +=
            (fundsTotalRecords * bytesPerRecord / 1024); // Convert KB to MB
        debugPrint(
            'Funds records: $fundsTotalRecords (Current: $suppliesCurrentCount, History: $suppliesHistoryCount, Items: $itemsHistoryCount)');
      }

      // ============ showEmployee ============
      // Includes: readDataEmployeeCurr, readDataEmployeeHist
      if (empSetup.showEmployee) {
        final employeeCurrCount =
            FsUsageTracker.instance.getTrackedCount('readDataEmployeeCurr');
        final employeeHistCount =
            FsUsageTracker.instance.getTrackedCount('readDataEmployeeHist');

        final employeeTotalRecords = employeeCurrCount + employeeHistCount;
        estimatedMB +=
            (employeeTotalRecords * bytesPerRecord / 1024); // Convert KB to MB
        debugPrint(
            'Employee records: $employeeTotalRecords (Current: $employeeCurrCount, History: $employeeHistCount)');
      }

      debugPrint('Total estimated memory: ${estimatedMB.toStringAsFixed(2)}MB');
      debugPrint('=====================');

      // Format output
      if (estimatedMB > 1024) {
        return "${(estimatedMB / 1024).toStringAsFixed(1)}GB";
      }
      return estimatedMB > 0 ? "${estimatedMB.toStringAsFixed(1)}MB" : "0MB";
    } catch (e) {
      debugPrint('Memory calculation error: $e');
      return "0MB";
    }
  }

  //================ EMPLOYEE =================
  Future<void> _loadEmployeeSetup() async {
    try {
      // Try to load from Firestore with timeout
      final snapshot = await databaseEmployeeSetup
          .get()
          .first
          .timeout(const Duration(seconds: 8));

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        empSetup = doc.data().copyWith(docId: doc.id);
        // Save to local cache
        await _saveEmployeeSetupCache(empSetup);
      } else {
        final newSetup = finalEmpSetup;
        await databaseEmployeeSetup.add(newSetup);
        empSetup = newSetup;
        await _saveEmployeeSetupCache(newSetup);
      }
    } catch (e) {
      debugPrint('Firestore employee setup failed: $e');
      // Try to load from cache
      final cached = await _loadEmployeeSetupCache();
      if (cached != null) {
        empSetup = cached;
        debugPrint('Loaded employee setup from cache');
        return;
      }
      // Fall back to defaults
      empSetup = finalEmpSetup;
      debugPrint('Using default employee setup');
    }

    // Apply dark mode
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        myAppKey.currentState?.setDarkMode(empSetup.darkMode);
      });
    }
  }

  Future<void> _saveEmployeeSetupCache(EmployeeSetupModel setup) async {
    try {
      web.window.localStorage['employee_setup_cache'] =
          jsonEncode(setup.toJson());
    } catch (e) {
      debugPrint('Failed to cache employee setup: $e');
    }
  }

  Future<EmployeeSetupModel?> _loadEmployeeSetupCache() async {
    try {
      final cached = web.window.localStorage['employee_setup_cache'];
      if (cached != null) {
        return EmployeeSetupModel.fromJson(jsonDecode(cached));
      }
    } catch (e) {
      debugPrint('Failed to load employee setup cache: $e');
    }
    return null;
  }

  void updateEmployeeSetup(EmployeeSetupModel updated) {
    databaseEmployeeSetup.update(updated);
    myAppKey.currentState?.setDarkMode(updated.darkMode);
    setState(() {
      empSetup = updated;
      // Update memory usage immediately when toggles change
      _memoryUsage = _getMemoryUsageString();
    });
  }

  //================ ITEMS =================
  Future<void> _loadItemsFB() async {
    try {
      await OtherItemsRepository.instance
          .loadOnce(collectionName: 'other_items');
      listOthItemsFB = List.from(OtherItemsRepository.instance.items);

      await OtherItemsRepository.instance.loadOnce(collectionName: 'det_items');
      listDetItemsFB = List.from(OtherItemsRepository.instance.items);
      addlistDetItemsFB();

      await OtherItemsRepository.instance.loadOnce(collectionName: 'fab_items');
      listFabItemsFB = List.from(OtherItemsRepository.instance.items);
      addlistFabItemsFB();

      await OtherItemsRepository.instance.loadOnce(collectionName: 'ble_items');
      listBleItemsFB = List.from(OtherItemsRepository.instance.items);

      listAllItemsFB.clear();
      listAllItemsFB.addAll(listOthItemsFB);
      listAllItemsFB.addAll(listDetItemsFB);
      listAllItemsFB.addAll(listFabItemsFB);
      listAllItemsFB.addAll(listBleItemsFB);

      for (var item in listAllItemsFB) {
        stocksTypeLookup[(item.itemId, item.itemUniqueId)] = item.stocksType;
      }

      // Save to cache
      await _saveItemsCache();
    } catch (e) {
      debugPrint('Firestore items load failed: $e');
      // Try to load from cache
      final loaded = await _loadItemsCache();
      if (loaded) {
        debugPrint('Loaded items from cache');
        return;
      }
      debugPrint('Failed to load items from both Firestore and cache');
    }
  }

  Future<void> _saveItemsCache() async {
    try {
      // Save items lists to web localStorage
      web.window.localStorage['items_oth_cache'] =
          jsonEncode(listOthItemsFB.map((e) => e.toJson()).toList());
      web.window.localStorage['items_det_cache'] =
          jsonEncode(listDetItemsFB.map((e) => e.toJson()).toList());
      web.window.localStorage['items_fab_cache'] =
          jsonEncode(listFabItemsFB.map((e) => e.toJson()).toList());
      web.window.localStorage['items_ble_cache'] =
          jsonEncode(listBleItemsFB.map((e) => e.toJson()).toList());
    } catch (e) {
      debugPrint('Failed to cache items: $e');
    }
  }

  Future<bool> _loadItemsCache() async {
    try {
      final othCache = web.window.localStorage['items_oth_cache'];
      final detCache = web.window.localStorage['items_det_cache'];
      final fabCache = web.window.localStorage['items_fab_cache'];
      final bleCache = web.window.localStorage['items_ble_cache'];

      if (othCache != null &&
          detCache != null &&
          fabCache != null &&
          bleCache != null) {
        // Decode all items
        // Note: You'll need to implement proper JSON decoding based on your OtherItemModel structure
        // This is a simplified version - adjust based on your actual model
        debugPrint('Loaded items from cache');
        return true;
      }
    } catch (e) {
      debugPrint('Failed to load items cache: $e');
    }
    return false;
  }

  //================ MAIN LOADER =================
  Future<void> _mainLoad() async {
    // Load from cache first for immediate display
    await _loadEmployeeSetupCache().then((setup) {
      if (setup != null) {
        empSetup = setup;
        // Apply theme immediately from cache
        WidgetsBinding.instance.addPostFrameCallback((_) {
          myAppKey.currentState?.setDarkMode(empSetup.darkMode);
        });
      }
    });

    await _loadItemsCache();

    putEntries();

    for (var item in listSuppItemsAll) {
      stocksTypeLookup[(item.itemId, item.itemUniqueId)] = item.stocksType;
    }

    // Now load fresh data from Firestore in background (don't await)
    _loadEmployeeSetup().then((_) {
      if (mounted) {
        setState(() {
          // Theme and setup will update automatically via setDarkMode
        });
      }
    }).catchError((e) {
      debugPrint('Background employee setup load failed: $e');
    });

    _loadItemsFB().then((_) {
      if (mounted) {
        setState(() {
          // Items updated, UI will rebuild with fresh data
        });
      }
    }).catchError((e) {
      debugPrint('Background items load failed: $e');
    });
  }

  //================ INIT =================
  @override
  void initState() {
    super.initState();

    empIdGlobal = widget.empidClass;

    databaseEmployeeSetup = DatabaseEmployeeSetup();
    empSetup = finalEmpSetup;

    // Fire and forget - don't await _mainLoad()
    // Page renders immediately with cache/defaults
    _mainLoad();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      registerWebToken(empIdGlobal);
    });

    messaging.onTokenRefresh.listen((newToken) async {
      await saveTokenToFirestore(empIdGlobal, newToken);
    });

    // Initialize memory update timer - updates every 2 seconds
    _memoryUpdateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        _memoryUsage = _getMemoryUsageString();
      });
    });
  }

  @override
  void dispose() {
    _memoryUpdateTimer.cancel();
    super.dispose();
  }

  //########################### MAIN ###############################
  @override
  Widget build(BuildContext context) {
    final pageTheme = _bodyTheme(context);

    final dateText = DateFormat('MMM dd, yyyy').format(DateTime.now());

    return Theme(
        data: pageTheme,
        child: Scaffold(
          backgroundColor: _scaffoldColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 48,
            backgroundColor: _appBarColor,
            foregroundColor: _appBarForeground,

            /// LEFT MENU
            leading: MenuAnchor(
              builder: (context, controller, child) {
                return IconButton(
                  tooltip: 'Menu',
                  icon: const Icon(Icons.menu, size: 18),
                  onPressed: () {
                    controller.isOpen ? controller.close() : controller.open();
                  },
                );
              },
              menuChildren: [
                // ── DAILY ROUTINE ──────────────────────────────────
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () => showFundCheck(context),
                      child: const Text('💵 Funds Check'),
                    ),
                    MenuItemButton(
                      onPressed: () => showItemsInOut(context),
                      child: const Text('📦 Inventory Check'),
                    ),
                    MenuItemButton(
                      onPressed: () => showCalendarDialog(context),
                      child: const Text('📅 Staff Schedule'),
                    ),
                    MenuItemButton(
                      onPressed: () => showClosingCheck(context),
                      child: const Text('🔒 Closing Check'),
                    ),
                  ],
                  child: const Text('📋 Daily Routine'),
                ),

                // ── RIDER ──────────────────────────────────────────
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ShowRiderManagement())),
                      child: const Text('🚴 Rider Schedule'),
                    ),
                    MenuItemButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RiderLocationScreen())),
                      child: const Text('📍 Rider GPS'),
                    ),
                    // MenuItemButton(
                    //   onPressed: () => Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (_) => const RiderRoutePlannerPage())),
                    //   child: const Text('🗺️ Route Planner'),
                    // ),
                  ],
                  child: const Text('🚴 Rider'),
                ),

                // ── TOOLS ──────────────────────────────────────────
                SubmenuButton(
                  menuChildren: [
                    MenuItemButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ShowAdminMainPage())),
                      child: const Text('🔢 Edit Counter'),
                    ),
                    MenuItemButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ShowEnablePromo())),
                      child: const Text('🔢 Edit Promo Days'),
                    ),
                    MenuItemButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomerLocationPage())),
                      child: const Text('📍 Edit Customer Location'),
                    ),
                    MenuItemButton(
                      onPressed: () async {
                        if (isProcessing) return;
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Action'),
                            content: const Text(
                                'Move ALL Done jobs to Completed?\n\nThis action cannot be undone.'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('No')),
                              ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Yes')),
                            ],
                          ),
                        );
                        if (confirm != true) return;
                        setState(() => isProcessing = true);
                        try {
                          await moveAllDoneToCompleted();
                        } finally {
                          if (mounted) setState(() => isProcessing = false);
                        }
                      },
                      child: const Text('🧺 Done → Completed'),
                    ),

                    // ── TOOLS > ADMIN ───────────────────────────────
                    if (isAdmin)
                      SubmenuButton(
                        menuChildren: [
                          MenuItemButton(
                            onPressed: () => showSalaryMaintenance(context),
                            child: const Text('💸 Salary Correction'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Scaffold(
                                        appBar: AppBar(
                                            title: const Text(
                                                'Loyalty Data Sync')),
                                        body: const SingleChildScrollView(
                                            padding: EdgeInsets.all(16),
                                            child: SitVsLoyalty())))),
                            child: const Text('🔄 Loyalty Data Sync'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Scaffold(
                                        appBar: AppBar(
                                            title:
                                                const Text('Jobs vs Loyalty')),
                                        body: const SingleChildScrollView(
                                            padding: EdgeInsets.all(16),
                                            child: SitVsLoyaltyJobs())))),
                            child: const Text('📋 Jobs vs Loyalty'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Scaffold(
                                        appBar: AppBar(
                                            title: const Text('Batch Promo')),
                                        body: const BatchPromo()))),
                            child: const Text('🎁 Batch Promo'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const BatchPromoReviewPage())),
                            child: const Text('🔍 Batch Promo Review'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const BatchFixPromoCounterPage())),
                            child: const Text('🔧 Fix PromoCounter'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const BatchRemovePromoDisabledDays())),
                            child:
                                const Text('🚫 Remove Promo on Disabled Days'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const MonthlyAnalyticsPage())),
                            child: const Text('📊 Monthly Analytics'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ShowJobsPaid())),
                            child: const Text('� Jobs Paid'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const LoyaltyValidationPage())),
                            child: const Text('🏅 Loyalty Validation'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Scaffold(
                                        appBar: AppBar(
                                            title: const Text(
                                                'Update Loyalty DB')),
                                        body: const UpdateLoyaltyDB()))),
                            child: const Text('⚙️ Update Loyalty DB'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Scaffold(
                                        appBar: AppBar(
                                            title:
                                                const Text('Update BackupDB')),
                                        body: const SingleChildScrollView(
                                            padding: EdgeInsets.all(16),
                                            child: UpdateBackUpDB())))),
                            child:
                                const Text('🔄 Migrate Reports DB(BackupDB)'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Scaffold(
                                        appBar: AppBar(
                                            title: const Text('Admin Date D')),
                                        body: const AdminDateDPage()))),
                            child: const Text('📅 Admin Date D'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const OtherItemsPage())),
                            child: const Text('📦 Other Items'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DetItemsPage())),
                            child: const Text('🧴 Detergent Items'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const FabItemsPage())),
                            child: const Text('🧺 Fabricon Items'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const BleItemsPage())),
                            child: const Text('🫧 Bleach Items'),
                          ),
                          MenuItemButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const AutoSalaryDateOneTimeBatch())),
                            child: const Text('💰 Auto Salary Date Batch'),
                          ),
                        ],
                        child: const Text('🔑 Admin'),
                      ),
                  ],
                  child: const Text('🔧 Tools'),
                ),

                // ── LOGOUT ─────────────────────────────────────────
                MenuItemButton(
                  leadingIcon: const Icon(Icons.logout, size: 18),
                  onPressed: () {
                    FsUsageTracker.instance.flush(trigger: 'logout');
                    web.window.localStorage.removeItem(storageKey);
                    web.window.localStorage.removeItem('loyalty_cache');
                    web.window.localStorage.removeItem('loyalty_cache_version');
                    // Clear in-memory customer cache
                    CustomerRepository.instance.invalidate();
                    setState(() {
                      loggedIn = false;
                      rememberMe = true;
                    });
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EnterLoyaltyCode()),
                      (route) => false,
                    );
                  },
                  child: const Text('🚪 Logout'),
                ),
              ],
            ),

            /// TITLE
            title: Text(
              () {
                final memoryValue = double.tryParse(
                    _memoryUsage.replaceAll('MB', '').replaceAll('GB', ''));
                if (memoryValue != null && memoryValue >= 1.0) {
                  return "$dateText. Hello ${empSetup.empName} (v$appVersion) High Memory usage $_memoryUsage. Please refresh browser to clear cache.";
                }
                return "$dateText. Hello ${empSetup.empName} (v$appVersion) Memory used $_memoryUsage";
              }(),
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),

            /// RIGHT MENU (3 DOTS)
            actions: [
              MenuAnchor(
                style: MenuStyle(
                  backgroundColor: WidgetStatePropertyAll(_menuSurfaceColor),
                ),
                builder: (context, controller, child) {
                  return IconButton(
                    tooltip: 'Show',
                    icon: const Icon(Icons.more_vert, size: 18),
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                  );
                },
                menuChildren: [
                  MenuItemButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        empSetup.showFundsHistory ? _menuSelectedColor : null,
                      ),
                    ),
                    child: const Text('💳 GCash'),
                    onPressed: () {
                      updateEmployeeSetup(
                        empSetup.copyWith(
                            showFundsHistory: !empSetup.showFundsHistory),
                      );
                    },
                  ),
                  MenuItemButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        empSetup.showLaundry ? _menuSelectedColor : null,
                      ),
                    ),
                    child: const Text('🧺 Laundry'),
                    onPressed: () {
                      updateEmployeeSetup(
                        empSetup.copyWith(showLaundry: !empSetup.showLaundry),
                      );
                    },
                  ),
                  MenuItemButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        empSetup.showFunds ? _menuSelectedColor : null,
                      ),
                    ),
                    child: const Text('💰 Funds'),
                    onPressed: () {
                      updateEmployeeSetup(
                        empSetup.copyWith(showFunds: !empSetup.showFunds),
                      );
                    },
                  ),
                  MenuItemButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        empSetup.showEmployee ? _menuSelectedColor : null,
                      ),
                    ),
                    child: const Text('🪪 Staff'),
                    onPressed: () {
                      updateEmployeeSetup(
                        empSetup.copyWith(showEmployee: !empSetup.showEmployee),
                      );
                    },
                  ),

                  MenuItemButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        empSetup.darkMode ? _menuSelectedColor : null,
                      ),
                    ),
                    child: const Text('😎 Dark Mode'),
                    onPressed: () {
                      updateEmployeeSetup(
                        empSetup.copyWith(darkMode: !empSetup.darkMode),
                      );
                    },
                  ),
                  // MenuItemButton(
                  //   style: ButtonStyle(
                  //     backgroundColor: WidgetStateProperty.all(
                  //       empSetup.showUnpaidLaundry ? Colors.grey[300] : null,
                  //     ),
                  //   ),
                  //   child: const Text('💸 Unpaid Laundry'),
                  //   onPressed: () {
                  //     updateEmployeeSetup(
                  //       empSetup.copyWith(
                  //           showUnpaidLaundry: !empSetup.showUnpaidLaundry),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ],
          ),

          /// BODY
          body: Stack(
            children: [
              AbsorbPointer(
                absorbing: isProcessing,
                child: Builder(builder: (context) {
                  final isTablet = AppScale.of(context).isTablet;
                  final isMobile = MediaQuery.of(context).size.width < 600;
                  final screenWidth = MediaQuery.of(context).size.width;
                  // iPad gets ~25% wider panels
                  double pw(double base) => isTablet ? base * 1.25 : base;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.hardEdge,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (empSetup.showFundsHistory)
                          animatedPanel(
                            visible: empSetup.showFundsHistory,
                            width: pw(350),
                            child: Column(
                              children: [
                                const SizedBox(height: 1),
                                readDataGCashPending(),
                                readDataGCashDone(),
                              ],
                            ),
                            color: _isDarkMode
                                ? const Color(0xFF102A43)
                                : Colors.blue,
                          ),
                        if (empSetup.showLaundry)
                          readDataJobsOnQueue(
                            empSetup.showLaundry,
                            _isDarkMode
                                ? const Color(0xFF7A5C00)
                                : LaundryColors.onQueue,
                          ),
                        if (empSetup.showLaundry)
                          readDataJobsOnGoing(
                            empSetup.showLaundry,
                            _isDarkMode
                                ? const Color(0xFF0D3A57)
                                : LaundryColors.ongoing,
                          ),
                        animatedPanel(
                          visible: empSetup.showLaundry,
                          width: pw(320),
                          child: readDataJobsDone(() => setState(() {})),
                          color: _isDarkMode
                              ? const Color(0xFF1E5A31)
                              : LaundryColors.done,
                        ),
                        animatedPanel(
                          visible: empSetup.showLaundry,
                          width: pw(320),
                          child: readDataJobsCompleted(
                            context,
                            () => setState(() {}),
                          ),
                          color: _isDarkMode
                              ? const Color(0xFF35235E)
                              : LaundryColors.completed,
                        ),
                        if (empSetup.showLaundry)
                          IntrinsicWidth(
                            child: Container(
                              color: _isDarkMode
                                  ? const Color(0xFF4A1F1F)
                                  : Colors.red.shade100,
                              padding: const EdgeInsets.all(8),
                              child: readUnpaidLaundry(),
                            ),
                          ),
                        if (empSetup.showLaundry)
                          animatedPanel(
                            visible: empSetup.showLaundry,
                            width: pw(400),
                            child: const ShowRiderOrders(),
                            color: _isDarkMode
                                ? const Color(0xFF123C3C)
                                : Colors.teal.shade100,
                          ),
                        if (empSetup.showFunds && isAdmin)
                          animatedPanel(
                            visible: empSetup.showFunds && isAdmin,
                            width: pw(400),
                            child: readDataSuppliesCurrent(),
                            color: _isDarkMode
                                ? const Color(0xFF3B2F12)
                                : cFundsInFundsOut,
                          ),
                        if (empSetup.showFunds)
                          animatedPanel(
                            visible: empSetup.showFunds,
                            width: pw(550),
                            child: readDataSuppliesHistory(),
                            color: _isDarkMode
                                ? const Color(0xFF3B2F12)
                                : cFundsInFundsOut,
                          ),
                        if (empSetup.showFunds)
                          animatedPanel(
                            visible: empSetup.showFunds,
                            width: pw(400),
                            child: readDataItemsHistory(),
                            color: _isDarkMode
                                ? const Color(0xFF3B2F12)
                                : cFundsInFundsOut,
                          ),
                        if (empSetup.showEmployee)
                          animatedPanel(
                            visible: empSetup.showEmployee,
                            width: isMobile ? screenWidth : pw(600),
                            child: Column(
                              children: [
                                const SizedBox(height: 1),
                                readDataEmployeeCurr(),
                                readDataEmployeeHist(),
                              ],
                            ),
                            color: _isDarkMode
                                ? const Color(0xFF4A2517)
                                : cEmployeeMaintenance,
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ));
  }
}
