//alterjobsongoing
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/oldmodels/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/newmodels/otheritemmodel.dart';
import 'package:laundry_firebase/services/oldservices/database_jobsongoing.dart';
import 'package:laundry_firebase/services/oldservices/database_other_items.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';
import 'package:laundry_firebase/variables/oldvariables/variables_jobsdone.dart';

void showAlterJobsOnGoingVar(
  BuildContext context,
  Function setState,
  String docId,
  JobsOnQueueModel jOQM,
  List<OtherItemModel> lOIM,
  JobsOnQueueModel jOQMNoChange,
  List<OtherItemModel> lOIMNoChange,
) async {
  bViewMoreOptions = false;
  bViewAddOnDtlOnGoing = false;
  if (lOIM.isNotEmpty) {
    bViewMoreOptions = true;
  }
  dNeedOnVar = jOQM.needOn.toDate();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(
            "New Laundry ${DateTime.now().toString().substring(5, 13)}",
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
                    conOnGoingStatVar(setState, jOQM),
                    //conQueueStatVar(setState, jOQM),
                    Visibility(
                        visible: bViewMoreOptions,
                        child:
                            conOrderModeVar(setState, jOQM, decoLightBlue())),
                    conTotalPriceVar(setState, jOQM),
                    Visibility(
                        visible: bViewMoreOptions,
                        child: conBasketVar(setState, jOQM, decoLightBlue())),
                    Visibility(
                        visible: bViewMoreOptions,
                        child: conBagVar(setState, jOQM, decoLightBlue())),
                    conPaymentVar(context, setState, jOQM),
                    conRemarksVar(setState, jOQM),
                    conMoreOptions(setState),
                    visAddOnVar(context, setState, jOQM, lOIM, "JobsOnGoing",
                        jOQMNoChange),
                    visExtraOnGoingVar(context, setState, jOQM, lOIM),
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
            // moveToJDVar(context, docId, jOQM, lOIM),
            askMoveToJDVar(context, docId, jOQM, lOIM),

            //cancel button
            //cancelButtonReloginVar(context, jOQM),
            cancelButtonNoChangeVar(
                context, setState, jOQM, lOIM, jOQMNoChange, lOIMNoChange),

            //save button
            updateButtonJOGVar(context, docId, jOQM, lOIM, jOQMNoChange),

            //move to ongoing
            // moveToJOGVar(
            //     context,
            //     docId,
            //     jOQM,
            //     lOIM),
          ],
        );
      });
    },
  );
}

void showMessageSwapComplete(
    BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(
            title,
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
                    Text(message),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            closeButton2popVar(context),
          ],
        );
      });
    },
  );
}

void updateSwapVar(String sourceJobsId, String destinationJobsId) async {
  var collection = FirebaseFirestore.instance.collection('JobsOnGoing');
  var querySnapshots = await collection.get();
  for (var doc in querySnapshots.docs) {
    if (destinationJobsId == "${doc['D30_JobsId']}") {
      await doc.reference.update({
        'D30_JobsId': int.parse(sourceJobsId.replaceAll("#", "")),
      }).catchError((error) => print("Failed : $error"));
      ;
    } else if (sourceJobsId == "${doc['D30_JobsId']}") {
      await doc.reference.update({
        'D30_JobsId': int.parse(destinationJobsId.replaceAll("#", "")),
      }).catchError((error) => print("Failed : $error"));
    }
  }
}

Future<bool> canSwapVar(String destinationJobsId) async {
  var collection = FirebaseFirestore.instance.collection('JobsOnGoing');
  var querySnapshots = await collection.get();
  for (var doc in querySnapshots.docs) {
    if (destinationJobsId == "${doc['D30_JobsId']}") {
      if (!doc['D3_Waiting']) {
        return false;
      }
    }
  }
  //can swap if waiting or no data
  return true;
}

void deleteJOGVar(String docId, List<OtherItemModel> lOIM) {
  DatabaseOtherItems databaseOtherItems =
      DatabaseOtherItems("JobsOnGoing", docId);
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

  DatabaseJobsOnGoing databaseJobsOnGoing = DatabaseJobsOnGoing();
  databaseJobsOnGoing.deleteJobsOnGoing(docId);
}

void updateJOGMVar(
    String docId, JobsOnQueueModel jOQM, List<OtherItemModel> lOIM) {
  DatabaseJobsOnGoing databaseJobsOnGoing = DatabaseJobsOnGoing();
  jOQM.needOn = Timestamp.fromDate(dNeedOnVar);
  databaseJobsOnGoing.updateJobsOnGoing(docId, jOQM, lOIM);
}

Widget changeButtonJobsIdVar(
  BuildContext context,
  JobsOnQueueModel jOQM,
) {
  return MaterialButton(
    onPressed: () {
      moveUpVar(jOQM.jobsId);
      Navigator.pop(context); //need to relogin
    },
    color: cButtons,
    child: const Text("Move Up"),
  );
}

Widget updateButtonJOGVar(
    BuildContext context,
    String docId,
    JobsOnQueueModel jOQM,
    List<OtherItemModel> lOIM,
    JobsOnQueueModel jOQMNoChange) {
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
      bViewAddOnDtlOnGoing = false;
      jOQM.remarks = remarksControllerVar.text;

      //pop box
      Navigator.pop(context);

      //insert SuppliesHist
      //another checking paidgenerated is not true
      if ((jOQM.paidcash || jOQM.paidgcash) && !jOQM.paymentLaundryGenerated) {
        insertDataSuppliesHistoryVarLaundry(context, jOQM);
        jOQM.paymentLaundryGenerated = true;
      }

      //update JOG
      updateJOGMVar(docId, jOQM, lOIM);
      if (lOIM.isNotEmpty) {
        bViewMoreOptions = true;

        Navigator.pop(context);
      }
      //jOQMNoChange = jOQM;
      resetJOQMNoChangeToJOQM(jOQMNoChange, jOQM);

      // Navigator.of(context).push(
      //     MaterialPageRoute(builder: (context) => MyQueue(jOQM.empidGlobal)));
    },
    color: cButtons,
    child: const Text("Update"),
  );
}

void showMessageOptionChangeJobId(
    BuildContext context, String title, String message, JobsOnQueueModel jOQM) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(
            title,
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
                    Text(message),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            closeButtonVar(context),
            changeButtonJobsIdVar(context, jOQM),
          ],
        );
      });
    },
  );
}

void showMessageMoveToJD(
  BuildContext context,
  String title,
  String message,
  JobsOnQueueModel jOQM,
  List<OtherItemModel> lOIM,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(
            title,
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
                    Text(message),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            closeButtonVar(context),
            moveToJDVar(context, jOQM.docId, jOQM, lOIM),
          ],
        );
      });
    },
  );
}

Future<void> finalNumberAutoVarV2() async {
  var colAuto = FirebaseFirestore.instance
      .collection('JobsOnGoing')
      .orderBy('D30_JobsId', descending: true);
  var queryAuto = await colAuto.get();
  print("update 1 autonumber=$autoNumber");
  for (var doc in queryAuto.docs) {
    if (doc['D30_JobsId'] == 99) {
      await doc.reference.update({
        'D30_JobsId': autoNumber,
      });
      print("update 2 autonumber=$autoNumber");
    }
    break;
  }
  print("update 3 autonumber=$autoNumber");
}

Future<int> getNumberAutoVarV2() async {
  var colAuto = FirebaseFirestore.instance
      .collection('JobsOnGoing')
      .orderBy('D30_JobsId');
  var queryAuto = await colAuto.get();
  int nFirstLowest = 0,
      nSecondLowest = 0,
      nPrevJobsIdFetch = 0,
      nCurrJobsIdFetch = 0;
  for (var doc in queryAuto.docs) {
    if (nCurrJobsIdFetch != doc['D30_JobsId']) {
      nPrevJobsIdFetch = nCurrJobsIdFetch;
      nCurrJobsIdFetch = doc['D30_JobsId'];
    }

    if ((nPrevJobsIdFetch + 1) != nCurrJobsIdFetch &&
        nFirstLowest != 0 &&
        nSecondLowest == 0) {
      nSecondLowest = nPrevJobsIdFetch + 1;
    }

    if ((nPrevJobsIdFetch + 1) != nCurrJobsIdFetch &&
        nFirstLowest == 0 &&
        nSecondLowest == 0) {
      nFirstLowest = nPrevJobsIdFetch + 1;
    }

    print("nFirstLowest=$nFirstLowest nSecondLowest=$nSecondLowest");

    //final
    if (doc['D30_JobsId'] == 99) {
      if (nSecondLowest == 0 || nSecondLowest > 25) {
        return nFirstLowest;
      } else {
        return nSecondLowest;
      }
    }
  }
  print("return 99");
  return 99;
}

Future<bool> onGoingFull() async {
  var colAuto = FirebaseFirestore.instance.collection('JobsOnGoing');
  var queryAuto = await colAuto.get();
  if (queryAuto.size >= 25) {
    return true;
  }
  return false;
}

Future<void> moveUpVar(int jobsId) async {
  bool bOnlyOne = false;

  var collection = FirebaseFirestore.instance.collection('JobsOnGoing');
  var querySnapshots = await collection.get();

  if (querySnapshots.size == 1) {
    bOnlyOne = true;
  }
  for (var doc in querySnapshots.docs) {
    if (bOnlyOne && doc['D30_JobsId'] == 0) {
      await doc.reference.update({
        'D30_JobsId': 1,
      });
    } else {
      if (jobsId == 1) {
        //updatePrevOne25(jobsId);
        //break;
        if (doc['D30_JobsId'] == 1) {
          await doc.reference.update({
            'D30_JobsId': 25,
          });
        }
        if (doc['D30_JobsId'] == 25) {
          await doc.reference.update({
            'D30_JobsId': 1,
          });
        }
      } else {
        if ((jobsId - 1) == doc['D30_JobsId']) {
          await doc.reference.update({
            'D30_JobsId': jobsId,
          });
        } else if ((jobsId) == doc['D30_JobsId']) {
          await doc.reference.update({
            'D30_JobsId': jobsId - 1,
          });
        }
      }
    }
  }
}

Container conOnGoingStatVar(Function setState, JobsOnQueueModel jOQM) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.all(1.0),
    decoration: decoAmber(),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
                value: jOQM.waiting,
                onChanged: (val) {
                  jOQM.waiting = true;
                  jOQM.washing = false;
                  jOQM.drying = false;
                  jOQM.folding = false;

                  setState(
                    () {
                      jOQM.waiting;
                      jOQM.washing;
                      jOQM.drying;
                      jOQM.folding;
                    },
                  );
                }),
            Text("Wait"),
            SizedBox(
              width: 5,
            ),
            Checkbox(
                value: jOQM.washing,
                onChanged: (val) {
                  jOQM.waiting = false;
                  jOQM.washing = true;
                  jOQM.drying = false;
                  jOQM.folding = false;

                  setState(
                    () {
                      jOQM.waiting;
                      jOQM.washing;
                      jOQM.drying;
                      jOQM.folding;
                    },
                  );
                }),
            Text("Wash"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
                value: jOQM.drying,
                onChanged: (val) {
                  jOQM.waiting = false;
                  jOQM.washing = false;
                  jOQM.drying = true;
                  jOQM.folding = false;

                  setState(
                    () {
                      jOQM.waiting;
                      jOQM.washing;
                      jOQM.drying;
                      jOQM.folding;
                    },
                  );
                }),
            Text("Dry"),
            SizedBox(
              width: 5,
            ),
            Checkbox(
                value: jOQM.folding,
                onChanged: (val) {
                  jOQM.waiting = false;
                  jOQM.washing = false;
                  jOQM.drying = false;
                  jOQM.folding = true;

                  setState(
                    () {
                      jOQM.waiting;
                      jOQM.washing;
                      jOQM.drying;
                      jOQM.folding;
                    },
                  );
                }),
            Text("Fold"),
          ],
        ),
      ],
    ),
  );
}

//insert new OnGoing
void insertDataJobsOnGoingVar(
    JobsOnQueueModel jOQM, List<OtherItemModel> lOIM) {
  DatabaseJobsOnGoing databaseJobsOnGoing = DatabaseJobsOnGoing();
  databaseJobsOnGoing.addJobsOnGoing(jOQM, lOIM);
  //resetJOQMGlobalVar();
}

Widget moveToJDVar(BuildContext context, String docId, JobsOnQueueModel jOQM,
    List<OtherItemModel> lOIM) {
  return MaterialButton(
    onPressed: () async {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing Data')),
      );
      //pop box
      Navigator.pop(context);

      //jOQM.riderPickup = false;
      jOQM.forSorting = false;
      jOQM.waiting = false;
      jOQM.washing = false;
      jOQM.drying = false;
      jOQM.folding = false;
      jOQM.waitCustomerPickup = false;
      jOQM.waitRiderDelivery = false;
      //if (jOQM.initTagForDeliveryWhenDone) {
      if (jOQM.riderPickup) {
        jOQM.waitRiderDelivery = true;
      } else {
        jOQM.waitCustomerPickup = true;
      }

      //insert SuppliesHist
      //another checking paidgenerated is not true
      if ((jOQM.paidcash || jOQM.paidgcash) && !jOQM.paymentLaundryGenerated) {
        insertDataSuppliesHistoryVarLaundry(context, jOQM);
        jOQM.paymentLaundryGenerated = true;
      }

      insertDataJobsDoneVar(jOQM, lOIM);
      //deleteJOQVar(jOQM.docId, lOIM);
      Navigator.pop(context);
      showMessage(context, "Move to Jobs Done", "Done.");
    },
    color: cButtons,
    child: const Text("Move To Jobs Done"),
  );
}

Widget askMoveToJDVar(BuildContext context, String docId, JobsOnQueueModel jOQM,
    List<OtherItemModel> lOIM) {
  return MaterialButton(
    onPressed: () async {
      showMessageMoveToJD(
          context, "Move to Jobs Done", "Are you sure?", jOQM, lOIM);
    },
    color: cButtons,
    child: const Text("Move To Jobs Done"),
  );
}
