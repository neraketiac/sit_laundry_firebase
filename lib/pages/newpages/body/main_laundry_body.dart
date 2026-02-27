import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/oldmodels/employeesetupmodel.dart';
import 'package:laundry_firebase/pages/enterloyaltycode.dart';
import 'package:laundry_firebase/pages/newpages/body/Employee/readDataEmployeeCurr.dart';
import 'package:laundry_firebase/pages/newpages/body/Employee/readDataEmployeeHist.dart';
import 'package:laundry_firebase/pages/newpages/body/Gcash/readDataGCashDone.dart';
import 'package:laundry_firebase/pages/newpages/body/Gcash/readDataGCashPending.dart';
import 'package:laundry_firebase/pages/newpages/body/JobsCompleted/readDataJobsCompleted.dart';
import 'package:laundry_firebase/pages/newpages/body/JobsOnGoing/readDataJobsOnGoing.dart';
import 'package:laundry_firebase/pages/newpages/body/JobsOnQueue/readDataJobsOnQueue.dart';
import 'package:laundry_firebase/pages/newpages/body/JobsDone/readDataJobsDone.dart';
import 'package:laundry_firebase/pages/newpages/body/Supplies/readSuppliesCurrent.dart';
import 'package:laundry_firebase/pages/newpages/body/Supplies/readSuppliesHist.dart';
import 'package:laundry_firebase/pages/newpages/header/Employee/showSalaryMaintenance.dart';
import 'package:laundry_firebase/pages/newpages/header/Funds/showCalendarDialog.dart';
import 'package:laundry_firebase/pages/newpages/header/Funds/showFundCheck.dart';
import 'package:laundry_firebase/pages/newpages/header/Funds/showFundsInFundsOut.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/services/newservices/database_employee_setup.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:web/web.dart' as web;

class LaundryColors {
  static const Color onQueue = Color(0xFFF4B400); // Amber
  static const Color ongoing = Color(0xFF2196F3); // Blue
  static const Color done = Color(0xFF4CAF50); // Green
  static const Color completed = Color(0xFF673AB7); // Deep Purple
}

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
                backgroundColor: const Color(0xFF673AB7), // Deep Purple
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (isProcessing) return;

                final bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF673AB7),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Yes"),
                        ),
                      ],
                    );
                  },
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
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (empSetup.showFundsHistory) {
                        return Colors.green.shade200; // your active color
                      }
                      return null; // default color
                    },
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
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (empSetup.showLaundry) {
                        return Colors.green.shade200; // your active color
                      }
                      return null; // default color
                    },
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
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (empSetup.showFunds) {
                        return Colors.green.shade200; // your active color
                      }
                      return null; // default color
                    },
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
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                    (states) {
                      if (empSetup.showEmployee) {
                        return Colors.green.shade200; // your active color
                      }
                      return null; // default color
                    },
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
                  animatedPanel(
                    visible: empSetup.showLaundry,
                    width: 320,
                    child: readDataJobsOnQueue(),
                    color: LaundryColors.onQueue,
                  ),
                  animatedPanel(
                    visible: empSetup.showLaundry,
                    width: 320,
                    child: readDataJobsOnGoing(),
                    color: LaundryColors.ongoing,
                  ),
                  animatedPanel(
                    visible: empSetup.showLaundry,
                    width: 320,
                    child: readDataJobsDone(),
                    color: LaundryColors.done,
                  ),
                  animatedPanel(
                    visible: empSetup.showLaundry,
                    width: 320,
                    child: readDataJobsCompleted(setState),
                    color: LaundryColors.completed,
                  ),
                  animatedPanel(
                      visible: empSetup.showFunds,
                      width: 250,
                      child: readDataSuppliesCurrent(),
                      color: cFundsInFundsOut),
                  animatedPanel(
                      visible: empSetup.showFunds,
                      width: 600,
                      child: readDataSuppliesHistory(),
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
