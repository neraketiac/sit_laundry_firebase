import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/services/database_jobs.dart';

class RemovePromoCounterWidget extends StatefulWidget {
  const RemovePromoCounterWidget({super.key});

  @override
  State<RemovePromoCounterWidget> createState() =>
      _RemovePromoCounterWidgetState();
}

class _RemovePromoCounterWidgetState extends State<RemovePromoCounterWidget> {
  bool isProcessing = false;
  String status = "";

  final List<String> collections = [
    JOBS_DONE_REF,
    JOBS_COMPLETED_REF,
  ];

  Future<void> removePromoCounterField() async {
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
          'Z01_IsPromoCounter': FieldValue.delete(),
        });

        count++;

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
    removePromoCounterField();
  }

  void onNo() {
    setState(() {
      status = "Cancelled";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Remove Z01_IsPromoCounter from collections?",
          style: TextStyle(fontSize: 16),
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
