//alterjobsdone
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/jobsonqueuemodel.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';
import 'package:laundry_firebase/services/database_jobsdone.dart';
import 'package:laundry_firebase/variables/variables.dart';

void showAlterJobsDoneVar(
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
                    conDoneStatVar(setState, jOQM),
                    //conQueueStatVar(setState, jOQM),
                    // Visibility(
                    //     visible: bViewMoreOptions,
                    //     child:
                    //         conOrderModeVar(setState, jOQM, decoLightBlue())),
                    conTotalPriceVar(setState, jOQM),
                    Visibility(
                        visible: bViewMoreOptions,
                        child: conBasketVar(setState, jOQM, decoLightBlue())),
                    Visibility(
                        visible: bViewMoreOptions,
                        child: conBagVar(setState, jOQM, decoLightBlue())),
                    conPaymentVar(context, setState, jOQM),
                    Visibility(
                        visible: (jOQM.paidgcash ? true : false),
                        child: conGCashVerified(setState, jOQM)),
                    conRemarksVar(setState, jOQM),
                    conMoreOptions(setState),
                    visAddOnVar(context, setState, jOQM, lOIM, "JobsDone",
                        jOQMNoChange),
                    // visExtraOnGoingVar(context, setState, jOQM, lOIM),
                    // visFoldVar(setState, jOQM),
                    // visMixVar(setState, jOQM),
                    visNeedOn(setState),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            //cancel button
            //cancelButtonReloginVar(context, jOQM),
            cancelButtonNoChangeVar(
                context, setState, jOQM, lOIM, jOQMNoChange, lOIMNoChange),

            //save button
            updateButtonJDVar(context, docId, jOQM, lOIM, jOQMNoChange),
          ],
        );
      });
    },
  );
}

void updateJDMVar(
    String docId, JobsOnQueueModel jOQM, List<OtherItemModel> lOIM) {
  DatabaseJobsDone databaseJobsDone = DatabaseJobsDone();
  jOQM.needOn = Timestamp.fromDate(dNeedOnVar);
  databaseJobsDone.updateJobsDone(docId, jOQM, lOIM);
}

Widget updateButtonJDVar(
    BuildContext context,
    String docId,
    JobsOnQueueModel jOQM,
    List<OtherItemModel> lOIM,
    JobsOnQueueModel jOQMNoChange) {
  return MaterialButton(
    onPressed: () {
      if (bDelAddOnsVar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Processing Data.')),
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

      //update JD
      updateJDMVar(docId, jOQM, lOIM);
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

Container conDoneStatVar(Function setState, JobsOnQueueModel jOQM) {
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
                value: jOQM.waitCustomerPickup,
                onChanged: (val) {
                  jOQM.waitCustomerPickup = true;
                  jOQM.waitRiderDelivery = false;
                  jOQM.nasaCustomerNa = false;

                  setState(
                    () {
                      jOQM.waitCustomerPickup;
                      jOQM.waitRiderDelivery;
                      jOQM.nasaCustomerNa;
                    },
                  );
                }),
            Text("Customer Pickup"),
          ],
        ),
        SizedBox(
          width: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
                value: jOQM.waitRiderDelivery,
                onChanged: (val) {
                  jOQM.waitCustomerPickup = false;
                  jOQM.waitRiderDelivery = true;
                  jOQM.nasaCustomerNa = false;

                  setState(
                    () {
                      jOQM.waitCustomerPickup;
                      jOQM.waitRiderDelivery;
                      jOQM.nasaCustomerNa;
                    },
                  );
                }),
            Text("For Delivery"),
          ],
        ),
        SizedBox(
          width: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
                value: jOQM.nasaCustomerNa,
                onChanged: (val) {
                  jOQM.waitCustomerPickup = false;
                  jOQM.waitRiderDelivery = false;
                  jOQM.nasaCustomerNa = true;

                  setState(
                    () {
                      jOQM.waitCustomerPickup;
                      jOQM.waitRiderDelivery;
                      jOQM.nasaCustomerNa;
                    },
                  );
                }),
            Text("Nasa Customer"),
          ],
        ),
      ],
    ),
  );
}

//insert new Done
void insertDataJobsDoneVar(JobsOnQueueModel jOQM, List<OtherItemModel> lOIM) {
  DatabaseJobsDone databaseJobsDone = DatabaseJobsDone();
  databaseJobsDone.addJobsDone(jOQM, lOIM);
  //resetJOQMGlobalVar();
}

Widget createNewJDVar(BuildContext context, String docId, JobsOnQueueModel jOQM,
    List<OtherItemModel> lOIM) {
  return MaterialButton(
    onPressed: () {
      if (jOQM.customerId == 1) {
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

        // insertDataJobsOnGoingVar(jOQM, lOIM);
        // deleteJOQVar(jOQM.docId, lOIM);
      }
    },
    color: cButtons,
    child: const Text("Jobs Done"),
  );
}
