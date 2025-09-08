//alterjobsonqueue
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/services/database_jobsonqueue.dart';
import 'package:laundry_firebase/services/database_other_items.dart';
import 'package:laundry_firebase/variables/variables.dart';
import 'package:laundry_firebase/variables/variables_jobsongoing.dart';

void showAlterJobsOnQueueVar(
  BuildContext context,
  String docId,
  JobsOnQueueModel jOQM,
  List<OtherItemModel> lOIM,
  JobsOnQueueModel jOQMNoChange,
  List<OtherItemModel> lOIMNoChange,
) async {
  dNeedOnVar = jOQM.needOn.toDate();
  bViewMoreOptions = false;
  if (lOIM.isNotEmpty) {
    bViewMoreOptions = true;
  }
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(
            "Change Jobs On Queue",
            style: TextStyle(backgroundColor: Colors.amber[300]),
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 2.0)),
              child: Form(
                //key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    conCustomerName(context, setState, jOQM),
                    conQueueStatVar(setState, jOQM),
                    conOrderModeVar(setState, jOQM, decoAmber()),
                    conTotalPriceVar(setState, jOQM),
                    conBasketVar(setState, jOQM, decoAmber()),
                    conBagVar(setState, jOQM, decoAmber()),
                    conPaymentVar(context, setState, jOQM),
                    conRemarksVar(setState, jOQM),
                    conMoreOptions(setState),
                    visAddOnVar(context, setState, jOQM, lOIM, "JobsOnQueue",
                        jOQMNoChange),
                    visExtraOnQueueVar(context, setState, jOQM, lOIM),
                    visFoldVar(setState, jOQM),
                    visMixVar(setState, jOQM),
                    visITFDWDVar(setState, jOQM),
                    visNeedOn(setState),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            //move to ongoing
            moveToJOGVar(context, docId, jOQM, lOIM),

            //cancel button
            ///cancelButtonReloginVar(context, jOQM),
            cancelButtonNoChangeVar(
                context, setState, jOQM, lOIM, jOQMNoChange, lOIMNoChange),

            //save button
            updateButtonJOQVar(context, docId, jOQM, lOIM),
          ],
        );
      });
    },
  );
}

void alterNumberMobileVar(BuildContext context, JobsOnQueueModel jOQM) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        "Swapping no. #${jOQM.jobsId}",
        style: TextStyle(backgroundColor: Colors.green[50]),
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  height: 5,
                ),
                DropdownButton<String>(
                  hint: Text("Select"),
                  value: selectedNumberVar,
                  onChanged: (val) {
                    setState(() {
                      selectedNumberVar = val!;
                    });
                  },
                  items: completeListNumbering
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text("#$value"),
                    );
                  }).toList(),
                ),
                TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(Colors.amberAccent)),
                    onPressed: () async {
                      if (await canSwapVar(selectedNumberVar)) {
                        updateSwapVar("${jOQM.jobsId}", selectedNumberVar);
                        showMessageSwapComplete(
                            context, "Success", "Swap complete.");
                      } else {
                        showMessage(context, "Failed at # $selectedNumberVar",
                            "Cannot swap to Washing/Drying/Folding. Choose other number");
                      }
                    },
                    child: Text(
                        "Click here to swap number #${jOQM.jobsId} to #$selectedNumberVar")),
              ],
            ),
          );
        }),
      ),
      actions: [
        //cancel button
        closeButtonVar(context),

        //swap jobs id
        //_swapJobsId("#$jobsId", _selectedNumber)
      ],
    ),
  );
}

void deleteJOQVar(String docId, List<OtherItemModel> lOIM) {
  DatabaseOtherItems databaseOtherItems =
      DatabaseOtherItems("JobsOnQueue", docId);
  // DatabaseOtherItemsOnQueue databaseOtherItemsOnQueue =
  //     DatabaseOtherItemsOnQueue(docId);

  lOIM.forEach((aOIG) {
    print("delete for ongoing docid=${aOIG.docId}");
    if (aOIG.docId != "") {
      databaseOtherItems.deleteOtheritems(aOIG.docId);
      // bDelAddOnsVar = true;
    } else {
      //need to relogin to delete
      // bDelAddOnsVar = false;
    }
  });

  DatabaseJobsOnQueue databaseJobsOnQueue = DatabaseJobsOnQueue();
  databaseJobsOnQueue.deleteJobsOnQueue(docId);
}

void updateJOQMVar(
    String docId, JobsOnQueueModel jOQM, List<OtherItemModel> lOIM) {
  DatabaseJobsOnQueue databaseJobsOnQueue = DatabaseJobsOnQueue();
  jOQM.needOn = Timestamp.fromDate(dNeedOnVar);
  databaseJobsOnQueue.updateJobsOnQueue(docId, jOQM, lOIM);
}

Widget updateButtonJOQVar(BuildContext context, String docId,
    JobsOnQueueModel jOQM, List<OtherItemModel> lOIM) {
  return MaterialButton(
    onPressed: () {
      if (bDelAddOnsVar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Processing Data, you may need to login again.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed delete add ons, please delete again.')),
        );
      }

      bViewMoreOptions = false;

      jOQM.remarks = remarksControllerVar.text;

      //pop box
      Navigator.pop(context);

      //insert SuppliesHist
      //another checking paidgenerated is not true
      if ((jOQM.paidcash || jOQM.paidgcash) && !jOQM.paymentLaundryGenerated) {
        insertDataSuppliesHistoryVarLaundry(context, jOQM);
        jOQM.paymentLaundryGenerated = true;
      }

      //update jobsOnQueue
      updateJOQMVar(docId, jOQM, lOIM);

      //listAddOnItemsGlobal.clear();
      //resetJOQMGlobalVar();

      if (lOIM.isNotEmpty) {
        bViewMoreOptions = true;
        Navigator.pop(context);
      }

      // Navigator.of(context).push(
      //     MaterialPageRoute(builder: (context) => MyQueue(empidGlobal)));
    },
    color: cButtons,
    child: const Text("Update"),
  );
}

Container conQueueStatVar(Function setState, JobsOnQueueModel jOQM) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.all(1.0),
    decoration: decoAmber(),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("RiderPickup"),
        Switch.adaptive(
          // value: jOQM.riderPickup,
          // onChanged: (bool value) {
          //   setState(() {
          //     jOQM.riderPickup = value;
          //     if (jOQM.riderPickup) {
          //       jOQM.forSorting = false;
          //     } else {
          //       jOQM.forSorting = true;
          //     }
          //   });
          // },
          value: jOQM.forSorting,
          onChanged: (bool value) {
            setState(() {
              jOQM.forSorting = value;
              if (jOQM.forSorting) {
              } else {
                jOQM.riderPickup = true;
              }
            });
          },
        ),
        Text("Sort"),
      ],
    ),
  );
}

Widget moveToJOGVar(BuildContext context, String docId, JobsOnQueueModel jOQM,
    List<OtherItemModel> lOIM) {
  return MaterialButton(
    onPressed: () async {
      if (await onGoingFull()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot proceed, on going is full(25).')),
        );
        // } else if (_formKey.currentState!.validate()) {
      } else if (true) {
        // If the form is valid, display a snackbar. In the real world,
        // you'd often call a server or save the information in a database.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Processing Data')),
        );

        //pop box
        Navigator.pop(context);

        //jOQM.riderPickup = false;
        jOQM.forSorting = false;
        jOQM.waiting = true;

        //insert SuppliesHist
        //another checking paidgenerated is not true
        if ((jOQM.paidcash || jOQM.paidgcash) &&
            !jOQM.paymentLaundryGenerated) {
          insertDataSuppliesHistoryVarLaundry(context, jOQM);
          jOQM.paymentLaundryGenerated = true;
        }

        print("jOQM 1= ${jOQM.jobsId}");

        insertDataJobsOnGoingVar(jOQM, lOIM);

        print("jOQM 2= ${jOQM.jobsId}");
        //get the next number
        autoNumber = await getNumberAutoVarV2();

        print("jOQM 3= ${jOQM.jobsId}");
        //update the 99 jobsid
        finalNumberAutoVarV2();

        print("jOQM 4= ${jOQM.jobsId}");
        showMessage(context, "Move to OnGoing", "Added to #$autoNumber");

        print("jOQM 5= ${jOQM.jobsId}");
      }
    },
    color: cButtons,
    child: const Text("Move To OnGoing??"),
  );
}

Widget createNewJOQVar(BuildContext context) {
  return MaterialButton(
    onPressed: () {
      if (autocompleteSelected.customerId == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Cannot save, please add name in loyalty records first.')),
        );
        // } else if (_formKey.currentState!.validate()) {
      } else if (true) {
        // If the form is valid, display a snackbar. In the real world,
        // you'd often call a server or save the information in a database.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Processing Data')),
        );

        //pop box
        Navigator.pop(context);
        jobsOnQueueModelGlobal.dateQ = Timestamp.now();
        jobsOnQueueModelGlobal.customerId = autocompleteSelected.customerId;
        jobsOnQueueModelGlobal.finalKilo = 0;
        jobsOnQueueModelGlobal.finalLoad = 0;
        jobsOnQueueModelGlobal.finalPrice = 0;
        jobsOnQueueModelGlobal.finalOthersPrice = 0;
        jobsOnQueueModelGlobal.paymentReceivedBy =
            (jobsOnQueueModelGlobal.unpaid ? "" : empIdGlobal);
        jobsOnQueueModelGlobal.paidD = (jobsOnQueueModelGlobal.unpaid
            ? Timestamp.fromDate(DateTime(2000))
            : Timestamp.now());
        jobsOnQueueModelGlobal.remarks = remarksControllerVar.text;
        jobsOnQueueModelGlobal.needOn = Timestamp.fromDate(dNeedOnVar);

        //insert SuppliesHist
        //another checking paidgenerated is not true
        if ((jobsOnQueueModelGlobal.paidcash ||
                jobsOnQueueModelGlobal.paidgcash) &&
            !jobsOnQueueModelGlobal.paymentLaundryGenerated) {
          insertDataSuppliesHistoryVarLaundry(context, jobsOnQueueModelGlobal);
          jobsOnQueueModelGlobal.paymentLaundryGenerated = true;
        }

        //insert jobsOnQueueVar
        insertDataJobsOnQueueVar(jobsOnQueueModelGlobal);
      }
    },
    color: cButtons,
    child: const Text("Save Queue"),
  );
}
