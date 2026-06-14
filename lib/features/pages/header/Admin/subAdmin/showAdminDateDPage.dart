import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/global/variables.dart';

class AdminDateDPage extends StatefulWidget {
  const AdminDateDPage({super.key});

  @override
  State<AdminDateDPage> createState() => _AdminDateDPageState();
}

class _AdminDateDPageState extends State<AdminDateDPage> {
  DateTime selectedDate = adminTimestampDateD.toDate();

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        adminTimestampDateD = Timestamp.fromDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Admin DateD Control",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: useAdminTimestampDateD,
            title: const Text(
              "Use admin timestamp for DateD(moveToDone) and PaidD in showPaidUnpaid",
            ),
            onChanged: (v) {
              setState(() {
                useAdminTimestampDateD = v ?? false;
              });
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: pickDate,
                child: const Text("Select Date"),
              ),
              const SizedBox(width: 15),
              Text(
                "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Timestamp Value:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(adminTimestampDateD.toDate().toString()),
        ],
      ),
    );
  }
}
