import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
  bool isLoading = true;

  String? _cachedToken;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

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
    _messaging.onTokenRefresh.listen((newToken) async {
      print("Token refreshed: $newToken");
      await saveTokenToFirestore(empIdGlobal, newToken);
    });

    databaseEmployeeSetup = DatabaseEmployeeSetup();
    _loadEmployeeSetup();
  }

  Future<void> registerWebToken(String empId) async {
    try {
      if (!kIsWeb) return; // Only needed for Web

      // Ask permission
      NotificationSettings settings = await _messaging.requestPermission();

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print("Notification permission not granted");
        return;
      }

      print("Notification permission granted");

      // Get token
      final token = await _messaging.getToken(
        vapidKey:
            "BA9ojQB79PiK84UardJeRfsk_okHsBHG763k_TgqbdF7cMkh_qnxKwrv84byD2XjU3sGLF4PHgaR-yjb_gfn4Zs",
      );

      if (token == null) return;

      // Prevent duplicate saves
      if (_cachedToken == token) {
        print("Token unchanged. Skipping update.");
        return;
      }

      _cachedToken = token;

      print("FCM TOKEN: $token");

      saveTokenToFirestore(empId, token);
    } catch (e) {
      print("FCM INIT ERROR: $e");
    }
  }

  Future<void> saveTokenToFirestore(String empId, String token) async {
    await FirebaseFirestore.instance.collection("employees").doc(empId).set({
      "fcmToken": token,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print("Token saved to Firestore");
  }

  // @override
  // Future<void> initState() async {
  //   super.initState();
  //   empIdGlobal = widget.empidClass;
  //   putEntries(); // only to use getItemNameOnly()

  //   // final cleanUrl = Uri.base.toString().split('#').last;
  //   // final uri = Uri.parse(cleanUrl);
  //   // final empId = uri.queryParameters['empId'];

  //   // if (empId != null && empId.isNotEmpty) {
  //   registerWebToken(empIdGlobal);

  //   // }

  //   databaseEmployeeSetup = DatabaseEmployeeSetup();
  //   _loadEmployeeSetup();
  // }

  Widget _checkBox({
    required String title,
    required bool selectedBool,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 1,
        ),
        Transform.scale(
          scale: 0.9, // shrink the checkbox itself
          child: Checkbox(
            value: selectedBool,
            onChanged: onChanged,
            visualDensity:
                VisualDensity(horizontal: -4, vertical: -4), // tighter
            materialTapTargetSize:
                MaterialTapTargetSize.shrinkWrap, // no extra padding
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 5),
      ],
    );
  }

  Widget _animatedPanel({
    required bool visible,
    required double width,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: visible ? width : 0,
      child: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            constraints: BoxConstraints(
              minWidth: 0,
              maxWidth: width,
            ),
            color: Colors.blue,
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ),
      ),
    );
  }

// helper method
  Widget _buildCheckBoxContainer({
    required Color color,
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: _checkBox(
        title: title,
        selectedBool: value,
        onChanged: onChanged,
      ),
    );
  }

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
      final newSetup = EmployeeSetupModel(
          docId: '',
          empId: empNameToId[empIdGlobal]!,
          empName: empIdGlobal,
          logDate: Timestamp.now(),
          logBy: empIdGlobal,
          remarks: '',
          showLaundry: false,
          showFunds: false,
          showFundsHistory: false,
          showEmployee: false,
          showIncome: false);

      // Save to Firestore
      await databaseEmployeeSetup.add(newSetup);
      empSetup = newSetup;

      // Update UI
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateSetup(EmployeeSetupModel updated) {
    setState(() {
      empSetup = updated;
    });
    databaseEmployeeSetup.update(updated);
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
        title: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    "$dateText. Hello ${empSetup.empName}",
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  IconButton(
                    tooltip: 'Logout',
                    icon: const Icon(Icons.logout, size: 14),
                    onPressed: () {
                      web.window.localStorage.removeItem(storageKey);

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
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCheckBoxContainer(
                    color: Colors.grey,
                    title: 'Gcash',
                    value: empSetup.showFundsHistory,
                    onChanged: (v) => _updateSetup(
                      empSetup.copyWith(showFundsHistory: v ?? false),
                    ),
                  ),
                  _buildCheckBoxContainer(
                    color: Colors.lightBlueAccent[700]!,
                    title: 'Ldy',
                    value: empSetup.showLaundry,
                    onChanged: (v) => _updateSetup(
                      empSetup.copyWith(showLaundry: v ?? false),
                    ),
                  ),
                  _buildCheckBoxContainer(
                    color: Colors.lightBlueAccent,
                    title: 'Funds',
                    value: empSetup.showFunds,
                    onChanged: (v) => _updateSetup(
                      empSetup.copyWith(showFunds: v ?? false),
                    ),
                  ),
                  _buildCheckBoxContainer(
                    color: Colors.amber,
                    title: 'Emp',
                    value: empSetup.showEmployee,
                    onChanged: (v) => _updateSetup(
                      empSetup.copyWith(showEmployee: v ?? false),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _animatedPanel(
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
            _animatedPanel(
              visible: empSetup.showLaundry,
              width: 320,
              child: readDataJobsOnQueue(),
            ),
            _animatedPanel(
              visible: empSetup.showFunds,
              width: 250,
              child: readDataSuppliesCurrent(),
            ),
            _animatedPanel(
              visible: empSetup.showFunds,
              width: 600,
              child: readDataSuppliesHistory(),
            ),
            _animatedPanel(
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
