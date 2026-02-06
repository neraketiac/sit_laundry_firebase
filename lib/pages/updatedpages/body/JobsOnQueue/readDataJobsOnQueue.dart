import 'package:flutter/material.dart';

Widget readDataJobsOnQueue() {
  final sample = [
    {
      'id': '1',
      'name': 'Wash & Fold',
      'price': '₱120',
      'status': 'Ready',
      'progress': 1.0
    },
    {
      'id': '2',
      'name': 'Dry Clean',
      'price': '₱200',
      'status': 'In Progress',
      'progress': 0.45
    },
    {
      'id': '3',
      'name': 'Iron Only',
      'price': '₱50',
      'status': 'Queued',
      'progress': 0.0
    },
  ];

  int? selectedIndex;

  IconData statusIcon(double p) {
    if (p == 1) return Icons.check;
    if (p > 0) return Icons.sync;
    return Icons.pause;
  }

  return StatefulBuilder(
    builder: (context, setState) {
      return ReorderableListView(
        shrinkWrap: true,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex -= 1;
            final item = sample.removeAt(oldIndex);
            sample.insert(newIndex, item);

            if (selectedIndex == oldIndex) {
              selectedIndex = newIndex;
            }
          });
        },
        children: List.generate(sample.length, (index) {
          final r = sample[index];
          final progress = r['progress'] as double;
          final isRunning = progress > 0 && progress < 1;
          final isSelected = selectedIndex == index;

          return TweenAnimationBuilder<double>(
            key: ValueKey(r['id']),
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.deepPurple.shade100
                        : Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 🔘 Drag handle (web-friendly)
                      ReorderableDragStartListener(
                        index: index,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: const Icon(Icons.drag_handle),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Progress badge
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 6,
                              backgroundColor: Colors.red,
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.deepPurple.shade300,
                            ),
                          ),
                          AnimatedRotation(
                            turns: isRunning ? 1 : 0,
                            duration: const Duration(seconds: 2),
                            curve: Curves.linear,
                            child: Icon(
                              statusIcon(progress),
                              color: Colors.deepPurple,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Content (clickable)
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r['name'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                r['status'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.deepPurple.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Text(
                        r['price'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.deepPurple : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      );
    },
  );
}
