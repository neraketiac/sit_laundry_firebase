import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/models/newmodels/gcashmodel.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/services/newservices/database_gcash.dart';
import 'package:laundry_firebase/variables/newvariables/gcash_repository.dart';

Widget readDataGCashDone() {
  DatabaseGCashDone dbGCashDone = DatabaseGCashDone();
  int? selectedIndex;

  return StreamBuilder<List<GCashModel>>(
    stream: dbGCashDone.streamAll(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(child: Text('Error loading GCash done'));
      }

      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final snapshotDatas = snapshot.data!;

      return StatefulBuilder(
        builder: (context, setState) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
                      if (gRepo.imageUrl != null) {
                        showImagePreview(context, gRepo.imageUrl!);
                      }
                    });
                    //showJobOnQueueComplete(context, jobRepo);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.shade50
                          : Colors.green.shade100,
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
                                  value: double.tryParse(
                                          gRepo.currentStocks.toString()) ??
                                      0.0, // removed Tween animation value
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
                                  Icons.check_circle_outline,
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
                                ],
                              ),
                              const SizedBox(width: 3),
                              //Date and Time
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      DateFormat('MM/dd hh:mm a')
                                          .format(gRepo.logDate.toDate()),
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
