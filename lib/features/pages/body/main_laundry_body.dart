import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import 'package:laundry_firebase/features/pages/header/Admin/rider/rider_gps.dart';
import 'package:laundry_firebase/features/pages/header/Admin/showAdminMainPage.dart';
import 'package:laundry_firebase/features/pages/header/Employee/showSalaryMaintenance.dart';
import 'package:laundry_firebase/features/pages/header/Employee/showCalendarDialog.dart';
import 'package:laundry_firebase/features/pages/header/Funds/showFundCheck.dart';
import 'package:laundry_firebase/features/pages/header/Funds/showFundsInFundsOut.dart';
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

    // Add local items to stocksTypeLookup
    for (var item in listSuppItemsAll) {
      stocksTypeLookup[(item.itemId, item.itemUniqueId)] = item.stocksType;
      // if (item.itemId == 422 || item.itemUniqueId == 429) {
      //   debugPrint(
      //       'Local: id=${item.itemId}, uniqueId=${item.itemUniqueId}, name=${item.itemName}, stocksType=${item.stocksType}');
      // }
    }

    // debugPrint('stocksTypeLookup size: ${stocksTypeLookup.length}');
    // debugPrint('listAllItemsFB size: ${listAllItemsFB.length}');
    // debugPrint('Lookup key (422, 429): ${stocksTypeLookup[(422, 429)]}');
    // debugPrint('422 429=${getItemNameStocksType(422, 429)}');

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
            "Hello $empIdGlobal",
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
            //done to completed
            if (isAdmin)
              MenuItemButton(
                onPressed: () async {
                  if (isProcessing) return;

                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirm Action"),
                      content: const Text(
                        "Move ALL Done jobs to Completed?\n\nThis action cannot be undone.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("No"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Yes"),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  setState(() => isProcessing = true);

                  try {
                    await moveAllDoneToCompleted();
                  } finally {
                    if (mounted) {
                      setState(() => isProcessing = false);
                    }
                  }
                },
                child: const Text("🧺 Done → Completed"),
              ),
            MenuItemButton(
              onPressed: () => showFundsInFundsOut(context),
              child: const Text("💰 Funds In/Out"),
            ),
            MenuItemButton(
              onPressed: () => showFundCheck(context),
              child: const Text("💵 Funds Check"),
            ),
            MenuItemButton(
              onPressed: () => showSalaryMaintenance(context),
              child: const Text("💸 Salary"),
            ),
            MenuItemButton(
              onPressed: () => showCalendarDialog(context),
              child: const Text("📅 Calendar"),
            ),
            MenuItemButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShowAdminMainPage(),
                  ),
                );
              },
              child: const Text("🔧 Tools"),
            ),
            //share gps
            MenuItemButton(
              onPressed: () => showDialog(
                  context: context, builder: (_) => const ShareRiderGps()),
              child: const Text("Rider GPS"),
            ),
            MenuItemButton(
              leadingIcon: const Icon(Icons.logout, size: 18),
              onPressed: () {
                web.window.localStorage.removeItem(storageKey);

                setState(() {
                  loggedIn = false;
                  rememberMe = true;
                });

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EnterLoyaltyCode(),
                  ),
                  (route) => false,
                );
              },
              child: const Text("🚪 Logout"),
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
                      showFundsHistory: !empSetup.showFundsHistory,
                    ),
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
                    empSetup.copyWith(
                      showLaundry: !empSetup.showLaundry,
                    ),
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
                    empSetup.copyWith(
                      showFunds: !empSetup.showFunds,
                    ),
                  );
                },
              ),
              MenuItemButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    empSetup.showEmployee ? Colors.grey[300] : null,
                  ),
                ),
                child: const Text("🪪 Id"),
                onPressed: () {
                  updateEmployeeSetup(
                    empSetup.copyWith(
                      showEmployee: !empSetup.showEmployee,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      /// BODY
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isProcessing,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.hardEdge,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  animatedPanel(
                    visible: empSetup.showFundsHistory,
                    width: 350,
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
                    width: 320,
                    child: readDataJobsDone(() => setState(() {})),
                    color: LaundryColors.done,
                  ),
                  animatedPanel(
                    visible: empSetup.showLaundry,
                    width: 320,
                    child: readDataJobsCompleted(
                      context,
                      () => setState(() {}),
                    ),
                    color: LaundryColors.completed,
                  ),
                  animatedPanel(
                    visible: empSetup.showLaundry,
                    width: 360,
                    child: const ShowRiderOrders(),
                    color: Colors.teal.shade100,
                  ),
                  animatedPanel(
                      visible: empSetup.showFunds,
                      width: 400,
                      child: readDataSuppliesCurrent(),
                      color: cFundsInFundsOut),
                  animatedPanel(
                      visible: empSetup.showFunds,
                      width: 550,
                      child: readDataSuppliesHistory(),
                      color: cFundsInFundsOut),
                  animatedPanel(
                      visible: empSetup.showFunds,
                      width: 400,
                      child: readDataItemsHistory(),
                      color: cFundsInFundsOut),
                  animatedPanel(
                      visible: empSetup.showEmployee,
                      width: 600,
                      child: Column(
                        children: [
                          const SizedBox(height: 1),
                          readDataEmployeeCurr(),
                          readDataEmployeeHist(),
                        ],
                      ),
                      color: cEmployeeMaintenance),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
