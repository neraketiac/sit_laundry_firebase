import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_firebase/models/newmodels/suppliesmodelhist.dart';
import 'package:laundry_firebase/services/newservices/database_gcash.dart';
import 'package:laundry_firebase/variables/newvariables/gcash_repository.dart';

Widget readDataGCashPending() {
  DatabaseGCashPending dbGCashPending = DatabaseGCashPending();
  int? selectedIndex;

  return StreamBuilder<List<SuppliesModelHist>>(
    stream: dbGCashPending.streamAll(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Error loading GCash pending'));
      }

      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final snapshotDatas = snapshot.data!;

      return StatefulBuilder(
        builder: (context, setState) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshotDatas.length,
            itemBuilder: (context, index) {
              final snapshotData = snapshotDatas[index];
              GCashRepository gRepo = GCashRepository();

              gRepo.setModel(snapshotData);

              final progress = 0;
              final isRunning = progress > 0 && progress < 1;
              final isSelected = selectedIndex == index;

              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    //showJobOnQueueComplete(context, jobRepo);
                  },
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
                            color: Colors.deepPurple,
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () {},
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 38,
                                height: 38,
                                child: CircularProgressIndicator(
                                  value: (double.tryParse(
                                              gRepo.currentStocks.toString()) ??
                                          0.0) +
                                      0.5, // removed Tween animation value
                                  strokeWidth: 6,
                                  // backgroundColor:
                                  //     backGroundStatusColor(job),
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
                                  // statusIcon(job),
                                  Icons.hourglass_bottom_outlined,
                                  color: Colors.deepPurple,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Customer Name (actually a number)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      gRepo.customerName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.deepPurple
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 16),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    color: isSelected
                                        ? Colors.deepPurple
                                        : Colors.grey,
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(
                                            text: gRepo.customerName.replaceAll(
                                                    RegExp(r'[^0-9]'), '') ??
                                                ''),
                                      );

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Customer number copied'),
                                          duration: Duration(milliseconds: 800),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(width: 3),
                              //Customer Name + Remarks
                              Text(
                                'Dtl: ${gRepo.remarks}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.deepPurple
                                        : Colors.black,
                                    fontSize: 10),
                              ),
                              const SizedBox(width: 3),
                              //Item Name
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      (gRepo.itemName),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.deepPurple
                                            : Colors.black,
                                        fontSize: 10,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever_outlined,
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    splashRadius: 18,
                                    color: isSelected
                                        ? Colors.deepPurple
                                        : Colors.grey,
                                    onPressed: () async {
                                      final result = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Confirmation'),
                                            content: const Text('Delete?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context, false); // NO
                                                },
                                                child: const Text('No'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  await dbGCashPending
                                                      .deleteVoid(
                                                          gRepo.getModel()!);
                                                  Navigator.pop(
                                                      context, true); // YES
                                                },
                                                child: const Text('Yes'),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (result == true) {
                                        // USER PRESSED YES
                                        print('User selected YES');
                                      } else {
                                        // USER PRESSED NO or dismissed
                                        print('User selected NO');
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.indeterminate_check_box,
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    splashRadius: 18,
                                    color: isSelected
                                        ? Colors.deepPurple
                                        : Colors.grey,
                                    onPressed: () async {
                                      final result = await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Confirmation'),
                                            content: const Text('Complete?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context, false); // NO
                                                },
                                                child: const Text('No'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  await moveToNext(gRepo.docId);
                                                  Navigator.pop(
                                                      context, true); // YES
                                                },
                                                child: const Text('Yes'),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (result == true) {
                                        // USER PRESSED YES
                                        print('User selected YES');
                                      } else {
                                        // USER PRESSED NO or dismissed
                                        print('User selected NO');
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        InkWell(
                          onTap: (() {
                            //showPaidUnpaid(context, jobRepo);
                          }),
                          child: Column(
                            children: [
                              Text(
                                '₱ ${gRepo.currentCounter}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}
