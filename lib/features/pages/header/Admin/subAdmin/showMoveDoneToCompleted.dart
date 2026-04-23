import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/services/database_jobs.dart';
import 'package:laundry_firebase/core/global/variables.dart';

class ShowMoveDoneToCompleted extends StatefulWidget {
  const ShowMoveDoneToCompleted({super.key});

  @override
  State<ShowMoveDoneToCompleted> createState() =>
      _ShowMoveDoneToCompletedState();
}

class _ShowMoveDoneToCompletedState extends State<ShowMoveDoneToCompleted> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 20),

        const Text(
          "Move Jobs Done(only Status 100%) to Jobs Completed",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),
        const SizedBox(height: 20),

        /// Delete button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          onPressed: () async {
            if (isProcessing) return;

            final bool? confirm = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Confirm Action"),
                  content: const Text(
                    "Move ALL Done jobs to Completed?\n\nThis action cannot be undone.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("No"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Yes"),
                    ),
                  ],
                );
              },
            );

            if (confirm != true) return;

            setState(() => isProcessing = true);

            try {
              await moveAllDoneToCompleted();
            } finally {
              if (mounted) {
                setState(() => isProcessing = false);
              }
            }
          },
          child: const Text("Move Done to Completed."),
        ),
      ],
    );
  }
}
