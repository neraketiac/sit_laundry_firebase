import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/employeemodel.dart';
import 'package:laundry_firebase/models/newmodels/gcashmodel.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/models/newmodels/suppliesmodelhist.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedConstantsFinal.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/services/newservices/database_employee_current.dart';
import 'package:laundry_firebase/services/newservices/database_gcash.dart';
import 'package:laundry_firebase/services/newservices/database_jobs.dart';
import 'package:laundry_firebase/services/newservices/database_loyalty.dart';
import 'package:laundry_firebase/services/newservices/database_supplies_current.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:laundry_firebase/variables/newvariables/variables_oth.dart';

//insert new Supplies
Future<bool> callDatabaseSuppliesCurrentAdd(SuppliesModelHist sMH) async {
  //if cashout or funds out, make current counter negative
  if (ifMenuUniqueIsCashOut(sMH) ||
      ifMenuUniqueIsFundsOut(sMH) ||
      (isGcashCredit && sMH.itemUniqueId == menuOthUniqIdCashIn)) {
    sMH.currentCounter = sMH.currentCounter * -1;
  }

  // add funds in name to regular staff
  // funds in is called paluwal, i-add sa sahod

  // ##### insert to Employee Current if Funds Out and name exists in nameMap ######
  // checking
  // 1. name exists in nameMap
  //    * itemUniqueId is Funds Out
  //    * exclude Ket and DonF employee record for admin
  //    * isGcashCredit and itemUniqueId is Cash In
  //    * isAdmin and itemUniqueId is Salary Payment
  if (sMH.customerName != "") {
    if (nameMap[sMH.customerName.toLowerCase()] !=
                null //check if employee exists
            &&
            (sMH.itemUniqueId == menuOthUniqIdFundsOut //funds out employee
                ||
                (isGcashCredit &&
                    sMH.itemUniqueId == menuOthUniqIdCashIn) //gcash credit
                ||
                ((isAdmin || allowPayment) &&
                    sMH.itemUniqueId ==
                        menuOthSalaryPayment) //salary payment access by admin only, or allowPayment
                ||
                (sMH.itemUniqueId == menuOthUniqIdFundsIn) //paluwal
            ) &&
            (sMH.customerName != 'Ket' &&
                sMH.customerName !=
                    'DonF') //funds out admin, no need to record in employee table
        ) {
      //############### start insert to Employee Current #################
      //get empId from nameMap
      final tempEmpId = empNameToId[sMH.customerName];

      DatabaseEmployeeCurrent databaseEmployeeCurrent =
          DatabaseEmployeeCurrent();

      //insert to Employee Current
      if (await databaseEmployeeCurrent.addEmployeeCurr(EmployeeModel(
        empId: tempEmpId!,
        docId: "",
        countId: 0,
        currentCounter: sMH.currentCounter,
        currentStocks: 0,
        itemId: sMH.itemId,
        itemUniqueId: sMH.itemUniqueId,
        itemName: sMH.itemName,
        logDate: sMH.logDate,
        logBy: empIdGlobal,
        empName: sMH.customerName,
        remarks: sMH.remarks,
      ))) {
        debugPrint("Employee Current updated...");
        //prevent generating another record in Supplies Current
        if (isGcashCredit ||
            ((isAdmin || allowPayment) &&
                sMH.itemUniqueId == menuOthSalaryPayment)) {
          isGcashCredit = false;
          return true;
        }
      } else {
        debugPrint("Employee Current failed to update...");
        //prevent generating another record in Supplies Current
        if (isGcashCredit ||
            ((isAdmin || allowPayment) &&
                sMH.itemUniqueId == menuOthSalaryPayment)) {
          isGcashCredit = false;
          return false;
        }
      }
      //############### end insert to Employee Current #################
    }
  }

  //this will insert to Supplies History first then Supplies Current
  //if exists in Supplies Current, it will update
  //if not exists, it will add new record in Supplies Current
  DatabaseSuppliesCurrent databaseSuppliesCurrent = DatabaseSuppliesCurrent();
  return await databaseSuppliesCurrent.addSuppliesCurr(sMH);
  // return false;
}

Future<void> callDatabaseJobsQueueAdd(
    BuildContext context, JobModelRepository jobRepo) async {
  DatabaseJobsQueue databaseJobsQueue = DatabaseJobsQueue();

  if (await databaseJobsQueue.add(jobRepo.jobModel)) {
    successInsertFB = true;
    DatabaseLoyalty loyalty = DatabaseLoyalty();
    loyalty.addCountByCardNumber(jobRepo.customerId, -10);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Insert on Queue done.')),
    );
  } else {
    successInsertFB = false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error insert Jobs On Queue.')),
    );
  }
}

Future<void> callDatabaseGCashPendingAdd(
    BuildContext context, GCashModel gM) async {
  DatabaseGCashPending databaseGCashPending = DatabaseGCashPending();

  if (await databaseGCashPending.addBool(gM)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Insert on GCash Pending done.')),
    );

    notifyAllUsers(
      title: gM.itemName,
      body: "${gM.customerName} ₱${gM.customerAmount}",
      url: "https://wash-ko-lang-sit.web.app/#/scan?empId=${gM.logBy}",
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error insert GCash Pending.')),
    );
  }
}

Future<void> callPickImageUniversal(
    BuildContext context, GCashModel gM, bool bCashIn) async {
  final bytes = await pickImageUniversal();

  if (bytes == null) return;

  DatabaseGCashPending databaseGCashPending = DatabaseGCashPending();
  await databaseGCashPending.saveImageUrl(gM, bytes);
}

Future<String?> uploadToCloudinaryBytes(Uint8List bytes) async {
  const cloudName = 'dxdskr55w';
  const uploadPreset = 'gcash_unsigned';

  final dio = Dio();

  final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  FormData formData = FormData.fromMap({
    "file": MultipartFile.fromBytes(
      bytes,
      filename: "upload.jpg",
    ),
    "upload_preset": uploadPreset,
  });

  final response = await dio.post(url, data: formData);

  if (response.statusCode == 200) {
    return response.data['secure_url'];
  }

  return null;
}

// TOKENS //

Future<void> registerWebToken(String empId) async {
  try {
    if (!kIsWeb) return; // Only needed for Web

    // Ask permission
    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print("Notification permission not granted");
      return;
    }

    print("Notification permission granted");

    // Get token
    final token = await messaging.getToken(
      vapidKey:
          "BA9ojQB79PiK84UardJeRfsk_okHsBHG763k_TgqbdF7cMkh_qnxKwrv84byD2XjU3sGLF4PHgaR-yjb_gfn4Zs",
    );

    if (token == null) return;

    // Prevent duplicate saves
    if (cachedToken == token) {
      print("Token unchanged. Skipping update.");
      return;
    }

    cachedToken = token;

    print("FCM TOKEN: $token");

    saveTokenToFirestore(empId, token);
  } catch (e) {
    print("FCM INIT ERROR: $e");
  }
}

Future<void> saveTokenToFirestore(String empId, String token) async {
  await FirebaseFirestore.instance.collection("users").doc(empId).set({
    "fcmToken": token,
    "updatedAt": FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  print("Token saved to Firestore");
}

// NOTIFICATIONS //
Future<void> notifyAllUsers({
  required String title,
  required String body,
  required String url,
}) async {
  final snap = await FirebaseFirestore.instance.collection('users').get();

  List<String> tokens = [];

  for (var user in snap.docs) {
    final data = user.data();
    final token = data['fcmToken'];

    if (token != null && token is String) {
      tokens.add(token);
    }
  }

  if (tokens.isEmpty) {
    print("No tokens found. Skipping notification.");
    return;
  }

  final response = await http.post(
    Uri.parse("https://laundry-push-server.onrender.com/send"),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'tokens': tokens,
      'title': title,
      'body': body,
      'url': url,
    }),
  );

  if (response.statusCode == 200) {
    print("Push sent successfully");
  } else {
    print("Push failed: ${response.body}");
  }
}

Future<void> callDatabaseUpdateJob(BuildContext context, JobModel jM) async {
  if (jM.processStep == 'completed') {
    DatabaseJobsCompleted dbJ = DatabaseJobsCompleted();

    if (await dbJ.update(jM)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update on job completed.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error update Jobs Done.')),
      );
    }
  } else if (jM.processStep == 'done') {
    DatabaseJobsDone dbJ = DatabaseJobsDone();

    if (await dbJ.update(jM)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update on job done.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error update Jobs Done.')),
      );
    }
  } else if (jM.processStep == 'waiting' ||
      jM.processStep == 'washing' ||
      jM.processStep == 'drying' ||
      jM.processStep == 'folding') {
    DatabaseJobsOngoing dbJ = DatabaseJobsOngoing();

    if (await dbJ.update(jM)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update on-going done.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error update Jobs On-Going.')),
      );
    }
  } else {
    DatabaseJobsQueue dbJ = DatabaseJobsQueue();

    if (await dbJ.update(jM)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update on Queue done.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error update Jobs On Queue.')),
      );
    }
  }
}

Future<void> callDeleteJobAdminOnly(BuildContext context, JobModel jM) async {
  if (jM.processStep == 'completed') {
    DatabaseJobsCompleted dbJ = DatabaseJobsCompleted();

    if (await dbJ.update(jM)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update on job completed.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error update Jobs Done.')),
      );
    }
  } else if (jM.processStep == 'done') {
    DatabaseJobsDone dbJ = DatabaseJobsDone();

    if (await dbJ.update(jM)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update on job done.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error update Jobs Done.')),
      );
    }
  } else if (jM.processStep == 'waiting' ||
      jM.processStep == 'washing' ||
      jM.processStep == 'drying' ||
      jM.processStep == 'folding') {
    DatabaseJobsOngoing dbJ = DatabaseJobsOngoing();

    if (await dbJ.update(jM)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update on-going done.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error update Jobs On-Going.')),
      );
    }
  } else {
    DatabaseJobsQueue dbJ = DatabaseJobsQueue();

    if (await dbJ.update(jM)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update on Queue done.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error update Jobs On Queue.')),
      );
    }
  }
}
