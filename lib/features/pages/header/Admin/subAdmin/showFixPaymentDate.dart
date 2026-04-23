import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FixUnpaidJobsWidget extends StatefulWidget {
  const FixUnpaidJobsWidget({super.key});

  @override
  State<FixUnpaidJobsWidget> createState() => _FixUnpaidJobsWidgetState();
}

class _FixUnpaidJobsWidgetState extends State<FixUnpaidJobsWidget> {
  bool running = false;
  String status = "";

  Future<void> fixUnpaidJobs() async {
    const String jobsDoneRef = "Jobs_done";
    const String jobsCompletedRef = "Jobs_completed";

    setState(() {
      running = true;
      status = "Starting...";
    });

    await _processCollection(jobsDoneRef);
    await _processCollection(jobsCompletedRef);

    setState(() {
      running = false;
      status = "Finished";
    });
  }

  Future<void> _processCollection(String collectionName) async {
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot snapshot = await firestore.collection(collectionName).get();

    WriteBatch batch = firestore.batch();
    int count = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      if (data['P00_Unpaid'] == false) {
        batch.update(doc.reference, {
          'A03_PaidD': data['A05_DateD'],
        });

        count++;

        /// Firestore batch limit safety
        if (count == 450) {
          await batch.commit();
          batch = firestore.batch();
          count = 0;
        }
      }
    }

    if (count > 0) {
      await batch.commit();
    }

    setState(() {
      status = "$collectionName processed";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: running ? null : fixUnpaidJobs,
          child: const Text("Run Fix Unpaid Jobs Batch"),
        ),
        const SizedBox(height: 10),
        Text(status),
      ],
    );
  }
}
