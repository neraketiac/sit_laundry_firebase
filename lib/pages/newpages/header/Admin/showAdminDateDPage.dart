import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text("Admin DateD Control")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              value: useAdminTimestampDateD,
              title: const Text("Use admin timestamp for DateO DateD DateC"),
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
            const SizedBox(height: 30),
            Text(
              "Timestamp Value:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(adminTimestampDateD.toDate().toString()),
          ],
        ),
      ),
    );
  }
}
