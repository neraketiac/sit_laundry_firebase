import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';
import 'package:laundry_firebase/features/employees/models/employeemodel.dart';
import 'package:laundry_firebase/features/payments/models/gcashmodel.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/items/models/suppliesmodelhist.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/core/services/database_employee_current.dart';
import 'package:laundry_firebase/core/services/database_gcash.dart';
import 'package:laundry_firebase/core/services/database_jobs.dart';
import 'package:laundry_firebase/core/services/database_loyalty.dart';
import 'package:laundry_firebase/core/services/database_supplies_current.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/utils/firestore_handler.dart';

import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:laundry_firebase/core/global/variables_oth.dart';

//insert new Supplies — throws on failure, caller uses FsHandler
Future<void> callDatabaseSuppliesCurrentAdd(SuppliesModelHist sMH,
    {Timestamp? autoSalaryDate}) async {
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
                ((isAdmin) &&
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
        logDate: Timestamp.now(),
        logBy: empIdGlobal,
        empName: sMH.customerName,
        remarks: sMH.remarks,
        autoSalaryDate: autoSalaryDate,
      ))) {
        debugPrint("Employee Current updated...");
        if (isGcashCredit ||
            ((isAdmin) && sMH.itemUniqueId == menuOthSalaryPayment)) {
          isGcashCredit = false;
          return;
        }
      } else {
        debugPrint("Employee Current failed to update...");
        if (isGcashCredit ||
            ((isAdmin) && sMH.itemUniqueId == menuOthSalaryPayment)) {
          isGcashCredit = false;
          throw Exception('Failed to update employee record.');
        }
      }
      //############### end insert to Employee Current #################
    }
  }

  //this will insert to Supplies History first then Supplies Current
  //if exists in Supplies Current, it will update
  //if not exists, it will add new record in Supplies Current
  DatabaseSuppliesCurrent databaseSuppliesCurrent = DatabaseSuppliesCurrent();
  await databaseSuppliesCurrent.addSuppliesCurr(sMH);
}

Future<void> callDatabaseJobsQueueAdd(
    BuildContext context, JobModelRepository jobRepo) async {
  DatabaseJobsQueue databaseJobsQueue = DatabaseJobsQueue();

  if (await databaseJobsQueue.add(jobRepo.jobModel)) {
    successInsertFB = true;
    //filter only when has free
    if (autocompleteSelected.loyaltyCount >= 0) {
      DatabaseLoyalty loyalty = DatabaseLoyalty();
      await loyalty.addCountByCardNumber(jobRepo.customerId, -10);
    }
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
    BuildContext context, GCashModel gM, bool bCashIn,
    {VoidCallback? onImageUploaded}) async {
  final bytes = await pickImageUniversal();

  if (bytes == null) return;

  // Compress and upload to Cloudinary
  Uint8List compressedBytes = await compressImage(bytes);
  String? imageUrl = await uploadToCloudinaryBytes(compressedBytes);

  if (imageUrl == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed')),
      );
    }
    return;
  }

  // If docId exists, save to Firestore immediately
  if (gM.docId.isNotEmpty) {
    DatabaseGCashPending databaseGCashPending = DatabaseGCashPending();
    await databaseGCashPending.saveImageUrl(gM, bytes);
  } else {
    // If no docId yet (new record), just update the model locally
    if (bCashIn) {
      gM.cashInImageUrl = imageUrl;
    } else {
      gM.cashOutImageUrl = imageUrl;
    }
  }

  // Notify caller that image was uploaded
  onImageUploaded?.call();
}

/// Upload a GCash receipt image for a job and save the URL to Firestore.
/// Works for any job collection (queue, ongoing, done, completed).
Future<void> callPickGCashReceiptForJob(BuildContext context,
    JobModelRepository jobRepo, VoidCallback onDone) async {
  final bytes = await pickImageUniversal();
  if (bytes == null) return;

  // Show loading indicator
  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Uploading receipt...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  try {
    final compressed = await compressImage(bytes);
    final url = await uploadToCloudinaryBytes(compressed);
    if (url == null) throw Exception('Upload failed');

    // Determine collection from the actual saved processStep
    final step = jobRepo.jobModel.processStep;
    final collection = step == 'completed'
        ? JOBS_COMPLETED_REF
        : step == 'done'
            ? JOBS_DONE_REF
            : (step == 'waiting' ||
                    step == 'washing' ||
                    step == 'drying' ||
                    step == 'folding')
                ? JOBS_ONGOING_REF
                : JOBS_QUEUE_REF;

    final firestore = collection == JOBS_DONE_REF
        ? FirebaseService.jobsDoneFirestore
        : FirebaseFirestore.instance;

    await firestore.collection(collection).doc(jobRepo.docId).update({
      'P09_GCashReceiptUrl': url,
      if (collection == JOBS_DONE_REF || collection == JOBS_COMPLETED_REF)
        SYNC_TO_DB2_FIELD: false,
    });

    jobRepo.gcashReceiptUrl = url;

    // Dismiss loading
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

    onDone();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt uploaded successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  } catch (e) {
    // Dismiss loading
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
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

    //print("FCM TOKEN: $token");

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
  Future<void> doUpdate() async {
    if (jM.processStep == 'completed') {
      await DatabaseJobsCompleted().update(jM);
    } else if (jM.processStep == 'done') {
      await DatabaseJobsDone().update(jM);
    } else if (jM.processStep == 'waiting' ||
        jM.processStep == 'washing' ||
        jM.processStep == 'drying' ||
        jM.processStep == 'folding') {
      await DatabaseJobsOngoing().update(jM);
    } else {
      await DatabaseJobsQueue().update(jM);
    }
  }

  await FsHandler.run(
    context: context,
    operation: doUpdate,
    successMessage: 'Job updated',
    onRetry: () => callDatabaseUpdateJob(context, jM),
  );
}

Future<void> callDeleteJobAdminOnly(BuildContext context, JobModel jM) async {
  await callDatabaseUpdateJob(context, jM);
}
