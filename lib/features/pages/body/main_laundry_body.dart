import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/utils/LaundryColors.dart';
import 'package:laundry_firebase/features/employees/models/employeesetupmodel.dart';
import 'package:laundry_firebase/features/pages/body/GCash/readDataGCashDone.dart';
import 'package:laundry_firebase/features/pages/body/GCash/readDataGCashPending.dart';
import 'package:laundry_firebase/features/pages/body/Loyalty/enterloyaltycode.dart';
import 'package:laundry_firebase/features/pages/body/Employee/readDataEmployeeCurr.dart';
import 'package:laundry_firebase/features/pages/body/Employee/readDataEmployeeHist.dart';
import 'package:laundry_firebase/features/pages/body/JobsCompleted/readDataJobsCompleted.dart';
import 'package:laundry_firebase/features/pages/body/JobsOnGoing/readDataJobsOnGoing.dart';
import 'package:laundry_firebase/features/pages/body/JobsOnQueue/readDataJobsOnQueue.dart';
import 'package:laundry_firebase/features/pages/body/JobsDone/readDataJobsDone.dart';
import 'package:laundry_firebase/features/pages/body/Supplies/readSuppliesCurrent.dart';
import 'package:laundry_firebase/features/pages/body/Supplies/readSuppliesHist.dart';
import 'package:laundry_firebase/features/pages/header/Admin/showAdminMainPage.dart';
import 'package:laundry_firebase/features/pages/header/Employee/showSalaryMaintenance.dart';
import 'package:laundry_firebase/features/pages/header/Funds/showCalendarDialog.dart';
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
            if (isAdmin)
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
              style: MenuItemButton.styleFrom(
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black,
              ),
              leadingIcon: const Icon(Icons.edit, size: 18),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShowAdminMainPage(),
                  ),
                );
              },
              child: const Text("Tools"),
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
                    child: readDataJobsDone(() => setState(() {})),
                    color: LaundryColors.done,
                  ),
                  animatedPanel(
                    visible: empSetup.showLaundry,
                    width: 320,
                    child:
                        readDataJobsCompleted(context, () => setState(() {})),
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
