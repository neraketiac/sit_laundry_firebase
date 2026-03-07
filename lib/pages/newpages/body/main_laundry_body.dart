import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/main.dart';
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
import 'package:laundry_firebase/pages/newpages/header/Admin/submigration/runMigration.dart';
import 'package:laundry_firebase/pages/newpages/header/Admin/submigration/showAdminDateDPage.dart';
import 'package:laundry_firebase/pages/newpages/header/Admin/submigration/showBatchPromo.dart';
import 'package:laundry_firebase/pages/newpages/header/Admin/showAdminMainPage.dart';
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

// import 'dart:convert';
// import 'dart:html' as html;

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
              child: const Text("Tool"),
            ),
            // if (isAdmin)
            //   MenuItemButton(
            //     style: MenuItemButton.styleFrom(
            //       backgroundColor: Colors.white70,
            //       foregroundColor: Colors.black,
            //     ),
            //     leadingIcon: const Icon(Icons.calendar_month, size: 18),
            //     onPressed: () {
            //       showBatchTwoWeeksChecking(context);
            //     },
            //     child: const Text("Batch for Promo"),
            //   ),
            // if (isAdmin)
            //   MenuItemButton(
            //     style: MenuItemButton.styleFrom(
            //       backgroundColor: Colors.white70,
            //       foregroundColor: Colors.black,
            //     ),
            //     leadingIcon: const Icon(Icons.calendar_month, size: 18),
            //     onPressed: () {
            //       runMigration(context);
            //     },
            //     child: const Text("Transfer To Secondary"),
            //   ),
            // if (isAdmin)
            //   MenuItemButton(
            //     style: MenuItemButton.styleFrom(
            //       backgroundColor: Colors.white70,
            //       foregroundColor: Colors.black,
            //     ),
            //     leadingIcon: const Icon(Icons.edit, size: 18),
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => const AdminDateDPage(),
            //         ),
            //       );
            //     },
            //     child: const Text("Set DateD"),
            //   ),
            // if (isAdmin)
            //   MenuItemButton(
            //     style: MenuItemButton.styleFrom(
            //       backgroundColor: Colors.white70,
            //       foregroundColor: Colors.black,
            //     ),
            //     leadingIcon: const Icon(Icons.calendar_month, size: 18),
            //     onPressed: () async {
            //       //******************************************************* START ADMIN  */
            //       //******************************************************* update all status to 1 */
            //       // final firestore = FirebaseFirestore.instance;

            //       // print("🔄 Starting update of 001_AllStatus...");

            //       // final collections = [
            //       //   JOBS_DONE_REF,
            //       //   // JOBS_COMPLETED_REF,
            //       // ];

            //       // final batch = firestore.batch();
            //       // int totalUpdated = 0;

            //       // for (String col in collections) {
            //       //   print("📂 Reading collection: $col");

            //       //   final snapshot = await firestore.collection(col).get();
            //       //   print("📄 Found ${snapshot.docs.length} documents");

            //       //   for (var doc in snapshot.docs) {
            //       //     batch.update(doc.reference, {
            //       //       'O01_AllStatus': 0.7,
            //       //     });

            //       //     totalUpdated++;
            //       //   }
            //       // }

            //       // print("🚀 Committing batch update...");
            //       // await batch.commit();

            //       // print(
            //       //     "✅ Update finished! Total documents updated: $totalUpdated");
            //       //******************************************************* delete jobs field in loyalty */
            //       //final firestore = FirebaseFirestore.instance;
            //       // final firestore = secondaryFirestore;

            //       // debugPrint("===== START CLEANING LOYALTY =====");

            //       // final snapshot = await firestore.collection('loyalty').get();

            //       // int updatedCount = 0;

            //       // for (final doc in snapshot.docs) {
            //       //   final data = doc.data();

            //       //   if (data.containsKey('jobs')) {
            //       //     await doc.reference.update({
            //       //       'jobs': FieldValue.delete(),
            //       //     });

            //       //     updatedCount++;
            //       //     debugPrint(
            //       //         "Removed jobs field from cardNumber: ${doc.id}");
            //       //   } else {
            //       //     debugPrint("No jobs field in cardNumber: ${doc.id}");
            //       //   }
            //       // }

            //       // debugPrint("===== CLEANING COMPLETED =====");
            //       // debugPrint("Total updated: $updatedCount");
            //       //******************************************************* backup to file */
            //       // try {
            //       //   final snapshot = await FirebaseFirestore.instance
            //       //       .collection('loyalty')
            //       //       .get();

            //       //   StringBuffer buffer = StringBuffer();

            //       //   buffer.writeln("LOYALTY COLLECTION EXPORT");
            //       //   buffer.writeln("Generated at: ${DateTime.now()}");
            //       //   buffer.writeln("====================================\n");

            //       //   for (var doc in snapshot.docs) {
            //       //     buffer.writeln("Document ID: ${doc.id}");
            //       //     buffer.writeln("------------------------------------");

            //       //     doc.data().forEach((key, value) {
            //       //       buffer.writeln("$key: $value");
            //       //     });

            //       //     buffer
            //       //         .writeln("\n====================================\n");
            //       //   }

            //       //   // Convert string to bytes
            //       //   final bytes = utf8.encode(buffer.toString());
            //       //   final blob = html.Blob([bytes]);
            //       //   final url = html.Url.createObjectUrlFromBlob(blob);

            //       //   final anchor = html.AnchorElement(href: url)
            //       //     ..setAttribute("download", "loyalty_export.txt")
            //       //     ..click();

            //       //   html.Url.revokeObjectUrl(url);

            //       //   print("Download triggered!");
            //       // } catch (e) {
            //       //   print("Export failed: $e");
            //       // }

            //       //******************************************************* delete non-numeric loyalty ids */
            //       // final collection =
            //       //     FirebaseFirestore.instance.collection('loyalty');

            //       // final snapshot = await collection.get();

            //       // WriteBatch batch = FirebaseFirestore.instance.batch();

            //       // for (var doc in snapshot.docs) {
            //       //   final docId = doc.id;

            //       //   // Check if docId is NOT purely numeric
            //       //   final isNumeric = RegExp(r'^[0-9]+$').hasMatch(docId);

            //       //   if (!isNumeric) {
            //       //     batch.delete(doc.reference);
            //       //     print("Deleting: $docId");
            //       //   }
            //       // }

            //       // await batch.commit();

            //       // print("Non-numeric document IDs deleted successfully.");
            //       //******************************************************* delete secondary non-numeric */
            //       // final collection = secondaryFirestore.collection('loyalty');

            //       // final snapshot = await collection.get();

            //       // WriteBatch batch = secondaryFirestore.batch();

            //       // for (var doc in snapshot.docs) {
            //       //   final docId = doc.id;

            //       //   final isNumeric = RegExp(r'^[0-9]+$').hasMatch(docId);

            //       //   if (!isNumeric) {
            //       //     batch.delete(doc.reference);
            //       //     print("Deleting: $docId");
            //       //   }
            //       // }

            //       // await batch.commit();

            //       // print(
            //       //     "Non-numeric document IDs deleted successfully from SECONDARY DB.");

            //       //******************************************************* update loyalty to current jobs (queue, ongoing, done, completed) */
            //       // final firestore = FirebaseFirestore.instance;
            //       // // final firestore = secondaryFirestore;

            //       // const jobCollections = [
            //       //   JOBS_QUEUE_REF,
            //       //   JOBS_ONGOING_REF,
            //       //   JOBS_DONE_REF,
            //       //   JOBS_COMPLETED_REF,
            //       // ];

            //       // int insertedCount = 0;
            //       // const int limit = 2; // 🔥 ONLY PROCESS 2 RECORDS

            //       // debugPrint("===== START TEST SYNC =====");

            //       // for (final jobCollection in jobCollections) {
            //       //   if (insertedCount >= limit) break;

            //       //   debugPrint("Checking collection: $jobCollection");

            //       //   final jobSnapshot = await firestore
            //       //       .collection(jobCollection)
            //       //       .limit(2)
            //       //       .get();

            //       //   for (final jobDoc in jobSnapshot.docs) {
            //       //     if (insertedCount >= limit) break;

            //       //     final jobData = jobDoc.data();
            //       //     final String jobId = jobDoc.id;
            //       //     final dynamic rawCustomerId = jobData['C00_CustomerId'];

            //       //     if (rawCustomerId == null) {
            //       //       debugPrint("❌ Skipped: CustomerId is null");
            //       //       continue;
            //       //     }

            //       //     final String customerId = rawCustomerId.toString();

            //       //     debugPrint("-----------------------------------");
            //       //     debugPrint("Found Job:");
            //       //     debugPrint("Collection : $jobCollection");
            //       //     debugPrint("Job ID     : $jobId");
            //       //     debugPrint("CustomerID : $customerId");

            //       //     if (customerId == null || customerId.isEmpty) {
            //       //       debugPrint("❌ Skipped: CustomerId is null/empty");
            //       //       continue;
            //       //     }

            //       //     final loyaltyRef =
            //       //         firestore.collection('loyalty').doc(customerId);

            //       //     final loyaltySnap = await loyaltyRef.get();

            //       //     if (!loyaltySnap.exists) {
            //       //       debugPrint("❌ Loyalty NOT FOUND for card: $customerId");
            //       //       continue;
            //       //     }

            //       //     // 🔥 SAFE INSERT (NO DUPLICATES)
            //       //     await loyaltyRef.set({
            //       //       'jobs': {jobId: "$jobCollection/$jobId"}
            //       //     }, SetOptions(merge: true));

            //       //     insertedCount++;

            //       //     debugPrint("✅ Linked Job $jobId to Loyalty $customerId");
            //       //     debugPrint("Progress: $insertedCount / $limit");
            //       //   }
            //       // }

            //       // debugPrint("===== TEST SYNC COMPLETED =====");
            //       // debugPrint("Total Inserted: $insertedCount");

            //       //******************************************************* duplicate jobs to secondary */
            //       final main = FirebaseFirestore.instance;
            //       final secondary = secondaryFirestore;

            //       const collectionsToMigrate = [
            //         'loyalty',
            //         JOBS_DONE_REF,
            //         JOBS_COMPLETED_REF,
            //       ];

            //       debugPrint("========== START MIGRATION ==========");

            //       try {
            //         for (final collectionName in collectionsToMigrate) {
            //           debugPrint("🔄 Migrating collection: $collectionName");

            //           final snapshot =
            //               await main.collection(collectionName).get();

            //           WriteBatch batch = secondary.batch();
            //           int operationCount = 0;
            //           int totalDocs = 0;

            //           for (final doc in snapshot.docs) {
            //             final secondaryRef =
            //                 secondary.collection(collectionName).doc(doc.id);

            //             // 🔥 SAFE: deterministic docId (no duplicates)
            //             batch.set(
            //               secondaryRef,
            //               doc.data(),
            //               SetOptions(merge: false), // full overwrite
            //             );

            //             operationCount++;
            //             totalDocs++;

            //             // Firestore batch limit = 500
            //             if (operationCount == 500) {
            //               await batch.commit();
            //               batch = secondary.batch();
            //               operationCount = 0;
            //             }
            //           }

            //           // Commit remaining operations
            //           if (operationCount > 0) {
            //             await batch.commit();
            //           }

            //           debugPrint(
            //               "✅ Finished $collectionName | Documents: $totalDocs");
            //         }

            //         debugPrint("🎉 MIGRATION COMPLETED SUCCESSFULLY");
            //       } catch (e) {
            //         debugPrint("❌ MIGRATION FAILED: $e");
            //       }

            //       debugPrint("========== END MIGRATION ==========");

            //       // //******************************************************* duplicate loyalty to secondary */
            //       // final mainFirestore = FirebaseFirestore.instance;

            //       // try {
            //       //   // 1️⃣ Get all loyalty documents from MAIN
            //       //   final snapshot =
            //       //       await mainFirestore.collection('loyalty').get();

            //       //   WriteBatch batch = secondaryFirestore.batch();
            //       //   int counter = 0;

            //       //   for (var doc in snapshot.docs) {
            //       //     final secondaryRef =
            //       //         secondaryFirestore.collection('loyalty').doc(doc.id);

            //       //     // 2️⃣ Copy full document data
            //       //     batch.set(secondaryRef, doc.data());

            //       //     counter++;

            //       //     // Firestore batch limit = 500 operations
            //       //     if (counter == 500) {
            //       //       await batch.commit();
            //       //       batch = secondaryFirestore.batch();
            //       //       counter = 0;
            //       //     }
            //       //   }

            //       //   // Commit remaining
            //       //   if (counter > 0) {
            //       //     await batch.commit();
            //       //   }

            //       //   debugPrint("✅ Loyalty collection copied to secondary DB");
            //       // } catch (e) {
            //       //   debugPrint("❌ Copy failed: $e");
            //       // }
            //       //******************************************************* END ADMIN  */
            //     },
            //     child: const Text("Refresh Secondary"),
            //   ),
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
                    child: readDataJobsDone(setState),
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
