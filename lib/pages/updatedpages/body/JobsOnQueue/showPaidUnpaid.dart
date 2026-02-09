import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_firebase/models/jobsmodel.dart';
import 'package:laundry_firebase/pages/updatedpages/sharedmethods/sharedMethodAndVariable.dart';
import 'package:laundry_firebase/services/database_jobs.dart';
import 'package:laundry_firebase/variables/updatedvariables/jobsmodel_repository.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_supplies.dart';

void showPaidUnpaid(BuildContext context, JobsModel jM) {
  Visibility visPaidUnPaid(Function setState) {
    final List<int> listPaidUnpaid = [
      unpaid,
      paidCash,
      paidGCash,
    ];

    return Visibility(
      visible: true,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(1.0),
        decoration: decoLightBlue(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 0,
          children: [
            Text(
              'Payment Status',
              style: TextStyle(fontSize: 11),
            ),
            ToggleButtons(
              isSelected: List.generate(
                listPaidUnpaid.length,
                (i) => selectedPaidUnpaid == listPaidUnpaid[i],
              ),
              onPressed: (index) {
                setState(() {
                  if (selectedPaidUnpaid == listPaidUnpaid[index]) {
                    selectedPaidUnpaid = 0;
                  } else {
                    selectedPaidUnpaid = listPaidUnpaid[index];
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.black,
              fillColor: Colors.greenAccent,
              color: Colors.black,
              borderColor: cSalaryOut,
              constraints: const BoxConstraints(
                minWidth: 60,
                minHeight: 25,
              ),
              children: const [
                Text('Unpaid', style: TextStyle(fontSize: 11)),
                Text('Paid Cash', style: TextStyle(fontSize: 11)),
                Text('Paid GCash', style: TextStyle(fontSize: 10)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Partial\ncash?',
                      style: const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2), // tiny gap
                    Transform.scale(
                      scale: 0.7, // shrink the checkbox itself
                      child: Checkbox(
                        value: selectedPaidPartialCash,
                        onChanged: (bool? value) {
                          setState(() {
                            selectedPaidPartialCash = value ?? false;
                          });
                        },
                        visualDensity: VisualDensity(
                            horizontal: -4, vertical: -4), // tighter
                        materialTapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // no extra padding
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Partial\nGCash?',
                      style: const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2), // tiny gap
                    Transform.scale(
                      scale: 0.7, // shrink the checkbox itself
                      child: Checkbox(
                        value: selectedPaidPartialGCash,
                        onChanged: (bool? value) {
                          setState(() {
                            selectedPaidPartialGCash = value ?? false;
                          });
                        },
                        visualDensity: VisualDensity(
                            horizontal: -4, vertical: -4), // tighter
                        materialTapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // no extra padding
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 2,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'GCash\nverified?',
                      style: const TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2), // tiny gap
                    Transform.scale(
                      scale: 0.7, // shrink the checkbox itself
                      child: Checkbox(
                        value: selectedPaidGCashVerified,
                        onChanged: (bool? value) {
                          setState(() {
                            selectedPaidGCashVerified = value ?? false;
                          });
                        },
                        visualDensity: VisualDensity(
                            horizontal: -4, vertical: -4), // tighter
                        materialTapTargetSize: MaterialTapTargetSize
                            .shrinkWrap, // no extra padding
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 4,
            ),
            //Partial Cash Amount
            Visibility(
              visible: selectedPaidPartialCash,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label (not indented)
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      'Partial Cash Amount',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: partialCashAmountVar,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'\d+(\.\d{0,2})?')),
                    ],
                    style: const TextStyle(fontSize: 12), // shrink text size
                    decoration: InputDecoration(
                      isDense: true, // 🔹 makes the field more compact
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      hintText: '0.00',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: const OutlineInputBorder(),
                      filled: true, // 🔹 enable background fill
                      fillColor: Colors.white, // 🔹 set background to white
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 24, // 🔹 narrower prefix space
                        minHeight: 24,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 4, right: 4),
                        child: Text(
                          '₱',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 2,
            ),
            //Partial GCash Amount
            Visibility(
              visible: selectedPaidPartialGCash,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label (not indented)
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      'Partial GCash Amount',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: partialGCashAmountVar,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'\d+(\.\d{0,2})?')),
                    ],
                    style: const TextStyle(fontSize: 12), // shrink text size
                    decoration: InputDecoration(
                      isDense: true, // 🔹 makes the field more compact
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      hintText: '0.00',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: const OutlineInputBorder(),
                      filled: true, // 🔹 enable background fill
                      fillColor: Colors.white, // 🔹 set background to white
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 24, // 🔹 narrower prefix space
                        minHeight: 24,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 4, right: 4),
                        child: Text(
                          '₱',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveButtonSetRepository() async {
    JobsModelRepository.instance.jobsModel = jM;
    //payment status
    JobsModelRepository.instance.setUnpaid = unpaid == selectedPaidUnpaid;
    JobsModelRepository.instance.setPaidCash = paidCash == selectedPaidUnpaid;
    JobsModelRepository.instance.setPaidGCash = paidGCash == selectedPaidUnpaid;
    JobsModelRepository.instance.setPartialPaidCash = selectedPaidPartialCash;
    JobsModelRepository.instance.setPartialPaidGCash = selectedPaidPartialGCash;
    JobsModelRepository.instance.setPartialPaidCashAmount =
        int.tryParse(partialCashAmountVar.text) ?? 0;
    JobsModelRepository.instance.setPartialPaidGCashAmount =
        int.tryParse(partialGCashAmountVar.text) ?? 0;

    if (unpaid != selectedPaidUnpaid) {
      JobsModelRepository.instance.setPaymentReceivedBy = empIdGlobal;
    }

    //verified gcash
    JobsModelRepository.instance.setPaidGCashVerified =
        selectedPaidGCashVerified;
    // DatabaseJobsQueue databaseJobsQueue = DatabaseJobsQueue();
    // databaseJobsQueue
    //     .updatePaidUnpaid(JobsModelRepository.instance.getJobsModel()!);
    await updateJobsModel(
        context, JobsModelRepository.instance.getJobsModel()!);
    //await insertLaundryPaymentSuppliesHistory(context, 'Show Jobs OnQueue');
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.lightBlue,
          contentPadding: const EdgeInsets.all(0),
          titlePadding: const EdgeInsets.only(
            top: 0,
            left: 5,
            right: 5,
            bottom: 0,
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 5,
          ),
          title: Text(
            "Enter Laundry",
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: EdgeInsets.all(1.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                //key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    visPaidUnPaid(setState),
                  ],
                ),
              ),
            ),
          ),
          // 👇 Bottom buttons
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close popup
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await saveButtonSetRepository();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      });
    },
  );
}
