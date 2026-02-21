import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/oldmodels/employeesetupmodel.dart';
import 'package:laundry_firebase/pages/enterloyaltycode.dart';
import 'package:laundry_firebase/pages/newpages/body/Employee/readDataEmployeeCurr.dart';
import 'package:laundry_firebase/pages/newpages/body/Employee/readDataEmployeeHist.dart';
import 'package:laundry_firebase/pages/newpages/body/Gcash/readDataGCashDone.dart';
import 'package:laundry_firebase/pages/newpages/body/Gcash/readDataGCashPending.dart';
import 'package:laundry_firebase/pages/newpages/body/JobOnQueue/readDataJobsOnQueue.dart';
import 'package:laundry_firebase/pages/newpages/body/Supplies/readSuppliesCurrent.dart';
import 'package:laundry_firebase/pages/newpages/body/Supplies/readSuppliesHist.dart';
import 'package:laundry_firebase/pages/newpages/header/Employee/showSalaryMaintenance.dart';
import 'package:laundry_firebase/pages/newpages/header/Funds/showCalendarDialog.dart';
import 'package:laundry_firebase/pages/newpages/header/Funds/showFundCheck.dart';
import 'package:laundry_firebase/pages/newpages/header/Funds/showFundsInFundsOut.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/services/newservices/database_employee_setup.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
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

// EMPLOYEE
  Future<void> _loadEmployeeSetup() async {
    final snapshot = await databaseEmployeeSetup.get().first;

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;

      setState(() {
        empSetup = doc.data().copyWith(docId: doc.id);
        isLoading = false;
      });
    } else {
      // Create default employee setup

      //final docRef = databaseEmployeeSetup.docId();
      final newSetup = finalEmpSetup;

      // Save to Firestore
      await databaseEmployeeSetup.add(newSetup);
      empSetup = newSetup;

      // Update UI
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateEmployeeSetup(EmployeeSetupModel updated) {
    setState(() {
      empSetup = updated;
    });
    databaseEmployeeSetup.update(updated);
  }

  @override
  void initState() {
    super.initState();
    putEntries();

    empIdGlobal = widget.empidClass;

    // Register token once after widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      registerWebToken(empIdGlobal);
    });

    // Listen for token refresh (important for web)
    messaging.onTokenRefresh.listen((newToken) async {
      // print("Token refreshed: $newToken");
      await saveTokenToFirestore(empIdGlobal, newToken);
    });

    databaseEmployeeSetup = DatabaseEmployeeSetup();
    empSetup = finalEmpSetup;
    _loadEmployeeSetup();
  }

  //########################### MAIN ###############################
  @override
  Widget build(BuildContext context) {
    if (isLoading || empSetup == null) {
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

        /// 🔹 LEFT SIDE (Menu for Logout)
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
            MenuItemButton(
              style: MenuItemButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade600,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                showFundsInFundsOut(context);
              },
              child: const Text("💰 Funds In/Out"),
            ),
            MenuItemButton(
              style: MenuItemButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
              ),
              leadingIcon: const Icon(Icons.price_check_outlined, size: 18),
              onPressed: () {
                showFundCheck(context);
              },
              child: const Text("Funds Check"),
            ),
            MenuItemButton(
              style: MenuItemButton.styleFrom(
                backgroundColor: cEmployeeMaintenance,
                foregroundColor: Colors.white,
              ),
              leadingIcon: const Icon(Icons.savings, size: 18),
              onPressed: () {
                showSalaryMaintenance(context);
              },
              child: const Text("Salary"),
            ),
            MenuItemButton(
              style: MenuItemButton.styleFrom(
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black,
              ),
              leadingIcon: const Icon(Icons.calendar_month, size: 18),
              onPressed: () {
                showCalendarDialog(context);
              },
              child: const Text("Calendar"),
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
              child: const Text("Logout"),
            ),
          ],
        ),

        /// 🔹 TITLE (Greeting)
        title: Text(
          "$dateText. Hello ${empSetup.empName}",
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),

        /// 🔹 RIGHT SIDE (3-Dot Menu)
        actions: [
          MenuAnchor(
            builder: (context, controller, child) {
              return IconButton(
                tooltip: 'Show',
                icon: const Icon(Icons.more_vert, size: 18),
                onPressed: () {
                  controller.isOpen ? controller.close() : controller.open();
                },
              );
            },
            menuChildren: [
              MenuItemButton(
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
      body: SingleChildScrollView(
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
            ),
            animatedPanel(
              visible: empSetup.showLaundry,
              width: 320,
              child: readDataJobsOnQueue(),
            ),
            animatedPanel(
              visible: empSetup.showFunds,
              width: 250,
              child: readDataSuppliesCurrent(),
            ),
            animatedPanel(
              visible: empSetup.showFunds,
              width: 600,
              child: readDataSuppliesHistory(),
            ),
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
            ),
          ],
        ),
      ),
    );
  }
}
