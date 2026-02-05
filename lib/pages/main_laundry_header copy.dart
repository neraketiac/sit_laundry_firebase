import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/updatedpages/main_laundry_body.dart';
import 'package:laundry_firebase/pages/updatedpagesmethods/showCashFundsInput.dart';
import 'package:laundry_firebase/pages/updatedpagesmethods/showFundCheck.dart';
import 'package:laundry_firebase/pages/updatedpagesmethods/showJobsOnQueue.dart';
import 'package:laundry_firebase/pages/updatedpagesmethods/showSalaryMaintenance.dart';
import 'package:laundry_firebase/variables/updatedvariables/jobsmodel_repository.dart';
import 'package:laundry_firebase/variables/updatedvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_supplies.dart';

class MyMainLaundryHeader extends StatefulWidget {
  final String empid;

  const MyMainLaundryHeader(this.empid, {super.key});

  @override
  State<MyMainLaundryHeader> createState() => _MyMainLaundryHeaderState();
}

class _MyMainLaundryHeaderState extends State<MyMainLaundryHeader> {
  late String _sEmpId;

  @override
  void initState() {
    super.initState();

    _sEmpId = widget.empid;
    empIdGlobal = _sEmpId;
    if (empIdGlobal == 'Ket' || empIdGlobal == 'DonF') {
      isAdmin = true;
    } else {
      isAdmin = false;
    }
    SuppliesHistRepository.instance.reset();
    JobsModelRepository.instance.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyMainLaundryBody(_sEmpId),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "JobsOnQueuex",
            onPressed: () {
              remarksControllerVar.text = "";
              showJobsOnQueue(context);
            },
            child: const Icon(Icons.local_laundry_service_sharp),
          ),
          SizedBox(
            height: 5,
          ),
          FloatingActionButton(
            backgroundColor: Colors.lightBlue.shade100,
            hoverColor: Colors.lightBlue,
            heroTag: "Enter New Record...",
            onPressed: () {
              showCashFundsInput(context);
            },
            child: const Text(
              "₱",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: cFundsEOD,
            hoverColor: cFundsEOD,
            heroTag: "Out",
            onPressed: () {
              showFundCheck(context);
            },
            child: const Icon(Icons.timer_off_outlined),
          ),
          Visibility(
            visible: (isAdmin ? true : allowPayment),
            child: FloatingActionButton(
              backgroundColor: cSalaryIn,
              hoverColor: cSalaryIn,
              heroTag: "Admin",
              onPressed: () {
                showSalaryMaintenance(context);
              },
              child: const Icon(Icons.add_moderator_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
