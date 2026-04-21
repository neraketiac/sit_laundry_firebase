import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/app_scale.dart';
import 'package:intl/intl.dart';
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
import 'package:laundry_firebase/features/pages/body/JobsOnGoing/readDataJobsOnGoing.dart';
import 'package:laundry_firebase/features/pages/body/JobsOnQueue/readDataJobsOnQueue.dart';
import 'package:laundry_firebase/features/pages/body/JobsDone/readDataJobsDone.dart';
import 'package:laundry_firebase/features/pages/body/rider/show_rider_orders.dart';
import 'package:laundry_firebase/features/pages/body/Supplies/readSuppliesCurrent.dart';
import 'package:laundry_firebase/features/pages/body/Supplies/readSuppliesHist.dart';
import 'package:laundry_firebase/features/pages/body/Unpaid/readUnpaidLaundry.dart';
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
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/runMigration.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/migrateToThird.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/showAdminDateDPage.dart';
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
import 'package:web/web.dart' as web;

class MyMainLaundryBody extends StatefulWidget {
  final String empidClass;

  const MyMainLaundryBody(this.empidClass, {super.key});

  @override
  State<MyMainLaundryBody> createState() => _MyMainLaundryBodyState();
}

class _MyMainLaundryBodyState extends State<MyMainLaundryBody> {
  late DatabaseEmployeeSetup databaseEmployeeSetup;
  late EmployeeSetupModel empSetup;

  bool isLoading = true;

  //================ EMPLOYEE =================
  Future<void> _loadEmployeeSetup() async {
    final snapshot = await databaseEmployeeSetup.get().first;

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      empSetup = doc.data().copyWith(docId: doc.id);
    } else {
      final newSetup = finalEmpSetup;
      await databaseEmployeeSetup.add(newSetup);
      empSetup = newSetup;
    }
  }

  void updateEmployeeSetup(EmployeeSetupModel updated) {
    databaseEmployeeSetup.update(updated);
    setState(() {
      empSetup = updated;
    });
  }

  //================ ITEMS =================
  Future<void> _loadItemsFB() async {
    await OtherItemsRepository.instance.loadOnce(collectionName: 'other_items');
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
  }

  //================ MAIN LOADER =================
  Future<void> _mainLoad() async {
    setState(() => isLoading = true);

    await Future.wait([
      _loadItemsFB(),
      _loadEmployeeSetup(),
    ]);

    putEntries();

    for (var item in listSuppItemsAll) {
      stocksTypeLookup[(item.itemId, item.itemUniqueId)] = item.stocksType;
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  //================ INIT =================
  @override
  void initState() {
    super.initState();

    empIdGlobal = widget.empidClass;

    databaseEmployeeSetup = DatabaseEmployeeSetup();
    empSetup = finalEmpSetup;

    _mainLoad();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      registerWebToken(empIdGlobal);
    });

    messaging.onTokenRefresh.listen((newToken) async {
      await saveTokenToFirestore(empIdGlobal, newToken);
    });
  }

  //########################### MAIN ###############################
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.deepPurple[100],
        appBar: AppBar(
          toolbarHeight: 48,
          title: Text(
            "Hello $empIdGlobal v$appVersion",
            style: const TextStyle(fontSize: 14),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final dateText = DateFormat('MMM dd, yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 48,

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
                              onPressed: () => Navigator.pop(context, false),
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
                                        title: const Text('Batch Promo')),
                                    body: const BatchPromo()))),
                        child: const Text('🎁 Batch Promo'),
                      ),
                      MenuItemButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BatchPromoReviewPage())),
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
                        child: const Text('🚫 Remove Promo on Disabled Days'),
                      ),
                      MenuItemButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MonthlyAnalyticsPage())),
                        child: const Text('📊 Monthly Analytics'),
                      ),
                      MenuItemButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoyaltyValidationPage())),
                        child: const Text('🏅 Loyalty Validation'),
                      ),
                      MenuItemButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => Scaffold(
                                    appBar: AppBar(
                                        title: const Text('Run Migration')),
                                    body: const RunMigration()))),
                        child: const Text('⚙️ Run Migration'),
                      ),
                      MenuItemButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => Scaffold(
                                    appBar: AppBar(
                                        title:
                                            const Text('Migrate to ThirdWeb')),
                                    body: const SingleChildScrollView(
                                        padding: EdgeInsets.all(16),
                                        child: MigrateToThird())))),
                        child: const Text('🔄 Migrate Reports DB'),
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
                setState(() {
                  loggedIn = false;
                  rememberMe = true;
                });
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const EnterLoyaltyCode()),
                  (route) => false,
                );
              },
              child: const Text('🚪 Logout'),
            ),
          ],
        ),

        /// TITLE
        title: Text(
          "$dateText. Hello ${empSetup.empName}",
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),

        /// RIGHT MENU (3 DOTS)
        actions: [
          MenuAnchor(
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
                    empSetup.showFundsHistory ? Colors.grey[300] : null,
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
                    empSetup.showLaundry ? Colors.grey[300] : null,
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
                    empSetup.showFunds ? Colors.grey[300] : null,
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
                    empSetup.showEmployee ? Colors.grey[300] : null,
                  ),
                ),
                child: const Text('🪪 Staff'),
                onPressed: () {
                  updateEmployeeSetup(
                    empSetup.copyWith(showEmployee: !empSetup.showEmployee),
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
              // iPad gets ~25% wider panels
              double pw(double base) => isTablet ? base * 1.25 : base;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.hardEdge,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      color: Colors.blue,
                    ),
                    readDataJobsOnQueue(
                      empSetup.showLaundry,
                      LaundryColors.onQueue,
                    ),
                    readDataJobsOnGoing(
                      empSetup.showLaundry,
                      LaundryColors.ongoing,
                    ),
                    animatedPanel(
                      visible: empSetup.showLaundry,
                      width: pw(320),
                      child: readDataJobsDone(() => setState(() {})),
                      color: LaundryColors.done,
                    ),
                    animatedPanel(
                      visible: empSetup.showLaundry,
                      width: pw(320),
                      child: readDataJobsCompleted(
                        context,
                        () => setState(() {}),
                      ),
                      color: LaundryColors.completed,
                    ),
                    animatedPanel(
                      visible: empSetup.showLaundry,
                      width: pw(400),
                      child: const ShowRiderOrders(),
                      color: Colors.teal.shade100,
                    ),
                    animatedPanel(
                      visible: empSetup.showFunds,
                      width: pw(400),
                      child: readDataSuppliesCurrent(),
                      color: cFundsInFundsOut,
                    ),
                    animatedPanel(
                      visible: empSetup.showFunds,
                      width: pw(550),
                      child: readDataSuppliesHistory(),
                      color: cFundsInFundsOut,
                    ),
                    animatedPanel(
                      visible: empSetup.showFunds,
                      width: pw(400),
                      child: readDataItemsHistory(),
                      color: cFundsInFundsOut,
                    ),
                    animatedPanel(
                      visible: empSetup.showEmployee,
                      width: pw(600),
                      child: Column(
                        children: [
                          const SizedBox(height: 1),
                          readDataEmployeeCurr(),
                          readDataEmployeeHist(),
                        ],
                      ),
                      color: cEmployeeMaintenance,
                    ),
                    if (empSetup.showLaundry)
                      IntrinsicWidth(
                        child: Container(
                          color: Colors.red.shade100,
                          padding: const EdgeInsets.all(8),
                          child: readUnpaidLaundry(),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
