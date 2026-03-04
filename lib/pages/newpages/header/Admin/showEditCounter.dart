import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCounter extends StatefulWidget {
  const EditCounter({super.key});

  @override
  State<EditCounter> createState() => _EditCounterState();
}

class _EditCounterState extends State<EditCounter> {
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
    );
  }
}
