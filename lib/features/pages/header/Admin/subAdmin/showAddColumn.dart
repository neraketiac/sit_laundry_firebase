import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/services/database_jobs.dart';

class AddPromoErrorCodeWidget extends StatefulWidget {
  const AddPromoErrorCodeWidget({super.key});

  @override
  State<AddPromoErrorCodeWidget> createState() =>
      _AddPromoErrorCodeWidgetState();
}

class _AddPromoErrorCodeWidgetState extends State<AddPromoErrorCodeWidget> {
  bool isProcessing = false;
  String status = "";

  final List<String> collections = [
    JOBS_DONE_REF,
    JOBS_COMPLETED_REF,
  ];

  Future<void> addPromoErrorCode() async {
    setState(() {
      isProcessing = true;
      status = "Starting...";
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    for (String collectionName in collections) {
      setState(() {
        status = "Processing $collectionName...";
      });

      final snapshot = await firestore.collection(collectionName).get();

      WriteBatch batch = firestore.batch();
      int count = 0;

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'Z01_PromoErrorCode': 0,
        });

        count++;

        // Firestore batch limit = 500
        if (count == 500) {
          await batch.commit();
          batch = firestore.batch();
          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit();
      }
    }

    setState(() {
      isProcessing = false;
      status = "Completed!";
    });
  }

  void onYes() {
    addPromoErrorCode();
  }

  void onNo() {
    setState(() {
      status = "Cancelled";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Add field Z01_PromoErrorCode = 0 to all documents?",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (isProcessing) const CircularProgressIndicator(),
        if (!isProcessing)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onYes,
                child: const Text("Yes"),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: onNo,
                child: const Text("No"),
              ),
            ],
          ),
        const SizedBox(height: 20),
        Text(status),
      ],
    );
  }
}
