import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/pages/newpages/header/Admin/submigration/runMigration.dart';
import 'package:laundry_firebase/pages/newpages/header/Admin/submigration/showAdminDateDPage.dart';
import 'package:laundry_firebase/pages/newpages/header/Admin/submigration/showBatchPromo.dart';
import 'package:laundry_firebase/pages/newpages/header/Admin/submigration/showDeleteSecondary.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

class ShowAdminMainPage extends StatefulWidget {
  const ShowAdminMainPage({super.key});

  @override
  State<ShowAdminMainPage> createState() => _ShowAdminMainPageState();
}

class _ShowAdminMainPageState extends State<ShowAdminMainPage> {
  final TextEditingController controller = TextEditingController();
  bool loading = true;

  final docRef =
      FirebaseFirestore.instance.collection('counters').doc('jobQueue');

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final doc = await docRef.get();
    controller.text = (doc.data()?['nextavailable'] ?? 0).toString();
    setState(() {
      loading = false;
    });
  }

  Future<void> save() async {
    final value = int.tryParse(controller.text) ?? 0;

    await docRef.update({
      'nextavailable': value,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Counter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Edit Counter
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "nextavailable",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: save,
                    child: const Text("Save"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const BatchPromo(),
              ),

            const SizedBox(height: 30),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const ShowDeleteSecondaryData(),
              ),

            const SizedBox(height: 40),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const RunMigration(),
              ),

            const SizedBox(height: 30),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const AdminDateDPage(),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
