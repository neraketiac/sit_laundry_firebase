import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laundry_firebase/models/newmodels/jobmodel.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedConstantsFinal.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/newvariables/variables_supplies.dart';

//reuse showJobsOnQueue removed dont needed.

void showPaidUnpaid(BuildContext context, JobModelRepository jobRepo) {
  void syncThisShowToSelected() {
    jobRepo.customerNameVar.text = jobRepo.customerName;
    //payment status
    if (jobRepo.unpaid) jobRepo.selectedPaidUnpaid = unpaid;
    if (jobRepo.paidCash) jobRepo.selectedPaidUnpaid = paidCash;
    if (jobRepo.paidGCash) jobRepo.selectedPaidUnpaid = paidGCash;
    jobRepo.selectedPaidPartialCash = jobRepo.partialPaidCash;
    jobRepo.selectedPaidPartialGCash = jobRepo.partialPaidGCash;
    jobRepo.partialCashAmountVar.text =
        jobRepo.partialPaidCashAmount.toString();
    jobRepo.partialGCashAmountVar.text =
        jobRepo.partialPaidGCashAmount.toString();
    jobRepo.selectedPaidGCashVerified = jobRepo.paidGCashVerified;
  }

  Visibility visCustomerName(Function setState) {
    return Visibility(
      visible: true,
      child: Container(
        padding: const EdgeInsets.all(1.0),
        decoration: decoAmber(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Label + Checkbox on same row
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Row(
                children: [],
              ),
            ),
            TextFormField(
              controller: jobRepo.customerNameVar,
              readOnly: true, // 👈 prevents editing
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Customer Name',
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
                hintText: 'Search Name',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              onFieldSubmitted: (_) {}, // optional / can remove
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

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
                (i) => jobRepo.selectedPaidUnpaid == listPaidUnpaid[i],
              ),
              onPressed: (index) {
                setState(() {
                  if (jobRepo.selectedPaidUnpaid == listPaidUnpaid[index]) {
                    jobRepo.selectedPaidUnpaid = 0;
                  } else {
                    jobRepo.selectedPaidUnpaid = listPaidUnpaid[index];
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
                        value: jobRepo.selectedPaidPartialCash,
                        onChanged: (bool? value) {
                          setState(() {
                            jobRepo.selectedPaidPartialCash = value ?? false;
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
                        value: jobRepo.selectedPaidPartialGCash,
                        onChanged: (bool? value) {
                          setState(() {
                            jobRepo.selectedPaidPartialGCash = value ?? false;
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
                        value: jobRepo.selectedPaidGCashVerified,
                        onChanged: (bool? value) {
                          setState(() {
                            jobRepo.selectedPaidGCashVerified = value ?? false;
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
              visible: jobRepo.selectedPaidPartialCash,
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
                    controller: jobRepo.partialCashAmountVar,
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
              visible: jobRepo.selectedPaidPartialGCash,
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
                    controller: jobRepo.partialGCashAmountVar,
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
    //reuse the repository.
    //payment status
    jobRepo.unpaid = unpaid == jobRepo.selectedPaidUnpaid;
    jobRepo.paidCash = paidCash == jobRepo.selectedPaidUnpaid;
    jobRepo.paidGCash = paidGCash == jobRepo.selectedPaidUnpaid;
    jobRepo.partialPaidCash = jobRepo.selectedPaidPartialCash;
    jobRepo.partialPaidGCash = jobRepo.selectedPaidPartialGCash;
    jobRepo.partialPaidCashAmount =
        int.tryParse(jobRepo.partialCashAmountVar.text) ?? 0;
    jobRepo.partialPaidGCashAmount =
        int.tryParse(jobRepo.partialGCashAmountVar.text) ?? 0;

    if (unpaid != jobRepo.selectedPaidUnpaid) {
      jobRepo.paymentReceivedBy = empIdGlobal;
    }
    jobRepo.paidGCashVerified = jobRepo.selectedPaidGCashVerified;

    await callDatabaseJobQueueUpdate(context, jobRepo.getJobsModel()!);
    //await setRepositoryLaundryPayment(context, 'Show Jobs OnQueue');
  }

  syncThisShowToSelected();

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
            "Change Payment\nStatus",
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    visCustomerName(setState),
                    SizedBox(
                      height: 8,
                    ),
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
