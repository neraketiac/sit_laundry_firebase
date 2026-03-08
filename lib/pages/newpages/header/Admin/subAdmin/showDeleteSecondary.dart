import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/main.dart';

/// Replace these if they exist elsewhere in your project
const String JOBS_DONE_REF = "jobs_done";
const String JOBS_COMPLETED_REF = "jobs_completed";

/// Your secondary firestore instance

class ShowDeleteSecondaryData extends StatefulWidget {
  const ShowDeleteSecondaryData({super.key});

  @override
  State<ShowDeleteSecondaryData> createState() =>
      _ShowDeleteSecondaryDataState();
}

class _ShowDeleteSecondaryDataState extends State<ShowDeleteSecondaryData> {
  final List<String> collections = [
    'loyalty',
    JOBS_DONE_REF,
    JOBS_COMPLETED_REF,
  ];

  String? selectedCollection;

  @override
  void initState() {
    super.initState();
    selectedCollection = collections.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 20),

        const Text(
          "Delete Secondary Data",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        /// Dropdown
        DropdownButtonFormField<String>(
          value: selectedCollection,
          decoration: const InputDecoration(
            labelText: "Select Collection",
            border: OutlineInputBorder(),
          ),
          items: collections.map((collection) {
            return DropdownMenuItem(
              value: collection,
              child: Text(collection),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedCollection = value;
            });
          },
        ),

        const SizedBox(height: 20),

        /// Delete button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () {
            if (selectedCollection != null) {
              deleteSecondaryCollection(context, selectedCollection!);
            }
          },
          child: const Text("Delete Collection"),
        ),
      ],
    );
  }
}

Future<void> deleteSecondaryCollection(
  BuildContext context,
  String collectionName,
) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Confirm Delete"),
      content: Text(
        "Delete ALL documents in '$collectionName' from secondary database?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Delete"),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  final secondary = secondaryFirestore;

  /// Loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  int deleted = 0;

  try {
    final snapshot = await secondary.collection(collectionName).get();

    WriteBatch batch = secondary.batch();
    int operationCount = 0;

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);

      operationCount++;
      deleted++;

      if (operationCount == 500) {
        await batch.commit();
        batch = secondary.batch();
        operationCount = 0;
      }
    }

    if (operationCount > 0) {
      await batch.commit();
    }

    Navigator.pop(context);

    /// Result dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Complete"),
        content: Text(
          "$deleted documents deleted from $collectionName",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  } catch (e) {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(e.toString()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
