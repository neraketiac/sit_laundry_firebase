import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/loyaltymodel.dart';
import 'package:laundry_firebase/services/database_loyalty.dart';

class LoyaltyAdmin extends StatefulWidget {
  const LoyaltyAdmin({super.key});

  @override
  State<LoyaltyAdmin> createState() => _LoyaltyAdminState();
}

class _LoyaltyAdminState extends State<LoyaltyAdmin> {
  String docIdMax = "0";
  String streamName = "0";
  int randomNum = 0;
  TextEditingController docIdFbController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController remarksController = TextEditingController();
  TextEditingController countController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: const Column(
          children: [Text("Wash Ko Lang"), Text("Loyalty Admin")],
        ),
        toolbarHeight: 60,
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }),
        child: ListView.builder(itemBuilder: (context, index) {
          return _readData("loyalty");
        }),
      ),

      /*
      Column(
        children: [
          Container(
            width: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
          Expanded(child: ListView.builder(itemBuilder: (context, index) {
            return _readData("loyalty");
          })),
        ],
      ),
      */
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Random random = Random();
          randomNum = random.nextInt(90) + 10;
          docIdFbController.text = (int.parse(docIdMax) + randomNum).toString();
          openNewCustomerBox();
        },
        child: const Icon(Icons.add_circle_outline_rounded),
      ),
    );
  }

  void openNewCustomerBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create New"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              enabled: false,
              controller: docIdFbController,
              decoration: InputDecoration(
                hintText: 'Card Number$docIdMax',
              ),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            TextField(
              controller: contactController,
              decoration: const InputDecoration(hintText: 'Contact'),
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(hintText: 'Address'),
            ),
            TextField(
              controller: remarksController,
              decoration: const InputDecoration(hintText: 'Remarks'),
            ),
          ],
        ),
        actions: [
          //cancel button
          _cancelButton(),

          //save button
          _createNewRecord(),
        ],
      ),
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
        onPressed: () {
          //pop box
          Navigator.pop(context);
        },
        child: const Text("Cancel"));
  }

  Widget _createNewRecord() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        //run firebase add
        _addDataJson(docIdFbController.text);
      },
      child: const Text("Save"),
    );
  }

  void toggleButtonIcon() {}

  Widget _readData(String s) {
    //read
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(s).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        List<Row> listWidgets = [];

        if (snapshot.hasData) {
          //body
          final buffRecords = snapshot.data?.docs.toList();
          int buffCounter = 0;

          for (var buffRecord in buffRecords!) {
            final String docid =
                snapshot.data!.docs[buffCounter].reference.id.toString();
            if (int.parse(docIdMax) < int.parse(docid)) {
              docIdMax = docid;
            }

            buffCounter += 1;

            int loyaltyCount = buffRecord['Count'] as int; //mod 10

            final listWidget = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const SizedBox(
                      width: 500,
                      child: Divider(
                        height: 20,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        const Text("Name:"),
                        Text(buffRecord["Name"],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(
                          width: 20,
                        ),
                        const Text("Card Id:"),
                        Text(docid,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("Contact:"),
                        Text(buffRecord["Contact"],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(
                          width: 20,
                        ),
                        const Text("Address:"),
                        Text(buffRecord["Address"],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            showAlertDialog(
                                context,
                                docid,
                                buffRecord['Name'],
                                buffRecord['Contact'],
                                buffRecord['Address'],
                                buffRecord['Remarks'],
                                1);
                          },
                          icon: Icon((loyaltyCount) >= 1
                              ? Icons.star_border_purple500_outlined
                              : Icons.circle_outlined),
                          label: const Text("1"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showAlertDialog(
                                context,
                                docid,
                                buffRecord['Name'],
                                buffRecord['Contact'],
                                buffRecord['Address'],
                                buffRecord['Remarks'],
                                2);
                          },
                          icon: Icon((loyaltyCount) >= 2
                              ? Icons.star_border_purple500_outlined
                              : Icons.circle_outlined),
                          label: const Text("2"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showAlertDialog(
                                context,
                                docid,
                                buffRecord['Name'],
                                buffRecord['Contact'],
                                buffRecord['Address'],
                                buffRecord['Remarks'],
                                3);
                          },
                          icon: Icon((loyaltyCount) >= 3
                              ? Icons.star_border_purple500_outlined
                              : Icons.circle_outlined),
                          label: const Text("3"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showAlertDialog(
                                context,
                                docid,
                                buffRecord['Name'],
                                buffRecord['Contact'],
                                buffRecord['Address'],
                                buffRecord['Remarks'],
                                4);
                          },
                          icon: Icon((loyaltyCount) >= 4
                              ? Icons.star_border_purple500_outlined
                              : Icons.circle_outlined),
                          label: const Text("4"),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            showAlertDialog(
                                context,
                                docid,
                                buffRecord['Name'],
                                buffRecord['Contact'],
                                buffRecord['Address'],
                                buffRecord['Remarks'],
                                5);
                          },
                          icon: Icon((loyaltyCount) >= 5
                              ? Icons.star_border_purple500_outlined
                              : Icons.circle_outlined),
                          label: const Text("5"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showAlertDialog(
                                context,
                                docid,
                                buffRecord['Name'],
                                buffRecord['Contact'],
                                buffRecord['Address'],
                                buffRecord['Remarks'],
                                6);
                          },
                          icon: Icon((loyaltyCount) >= 6
                              ? Icons.star_border_purple500_outlined
                              : Icons.circle_outlined),
                          label: const Text("6"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showAlertDialog(
                                context,
                                docid,
                                buffRecord['Name'],
                                buffRecord['Contact'],
                                buffRecord['Address'],
                                buffRecord['Remarks'],
                                7);
                          },
                          icon: Icon((loyaltyCount) >= 7
                              ? Icons.star_border_purple500_outlined
                              : Icons.circle_outlined),
                          label: const Text("7"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showAlertDialog(
                                context,
                                docid,
                                buffRecord['Name'],
                                buffRecord['Contact'],
                                buffRecord['Address'],
                                buffRecord['Remarks'],
                                8);
                          },
                          icon: Icon((loyaltyCount) >= 8
                              ? Icons.star_border_purple500_outlined
                              : Icons.circle_outlined),
                          label: const Text("8"),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            showAlertDialog(
                                context,
                                docid,
                                buffRecord['Name'],
                                buffRecord['Contact'],
                                buffRecord['Address'],
                                buffRecord['Remarks'],
                                9);
                          },
                          icon: Icon((loyaltyCount) >= 9
                              ? Icons.star_border_purple500_outlined
                              : Icons.circle_outlined),
                          label: const Text("9"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showAlertDialog(
                                context,
                                docid,
                                buffRecord['Name'],
                                buffRecord['Contact'],
                                buffRecord['Address'],
                                buffRecord['Remarks'],
                                10);
                          },
                          icon: Icon((loyaltyCount) >= 10
                              ? Icons.star_border_purple500_outlined
                              : Icons.circle_outlined),
                          label: const Text("10"),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Wrap(
                            children: <Widget>[
                              Icon(
                                Icons.star_border_purple500_outlined,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text("Bonus!", style: TextStyle(fontSize: 15)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
            listWidgets.add(listWidget);
          }
        }

        return
            //Expanded(
            //child:
            ListView(
          shrinkWrap: true,
          children: listWidgets,
        );
        //);
      },
    );
  }

  void _addData(String docIdFb) {
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('loyalty');
    collRef
        .doc(docIdFb)
        .set({
          'Name': nameController.text,
          'Contact': contactController.text,
          'Address': addressController.text,
          'Remarks': remarksController.text,
          //'cotime': DateTime.now(),
        })
        .then((value) => {
              docIdFbController.clear(),
              nameController.clear(),
              contactController.clear(),
              addressController.clear(),
              remarksController.clear(),
              showMessage(context, "New Customer Added"),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError((error) => showMessage(context, "Failed : $error"));
  }

  void _addDataJson(String docIdFb) {
    DatabaseLoyalty databaseLoyalty = DatabaseLoyalty();
    databaseLoyalty.addCustomerWithId(
        LoyaltyModel(
          name: nameController.text,
          contact: contactController.text,
          address: addressController.text,
          remarks: remarksController.text,
          count: 0,
        ),
        docIdFb);
    docIdFbController.clear();
    nameController.clear();
    contactController.clear();
    addressController.clear();
    remarksController.clear();
  }

  void _updateData(String docIdFb, String name, String contact, String address,
      String remarks, int count) {
    CollectionReference collRef =
        FirebaseFirestore.instance.collection('loyalty');
    collRef
        .doc(docIdFb)
        .set({
          'Name': name,
          'Contact': contact,
          'Address': address,
          'Remarks': remarks,
          'Count': count
          //'cotime': DateTime.now(),
        })
        .then((value) => {
              showMessage(
                  context, "Customer $name stars updated to $count stars."),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError((error) => showMessage(context, "Failed : $error"));
  }

//open message
  void showMessage(BuildContext context, String sMsg) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(sMsg),
              actions: [
                MaterialButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Ok"),
                ),
              ],
            ));
  }

  showAlertDialog(BuildContext context, String docIdFb, String name,
      String contact, String address, String remarks, int count) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Continue"),
      onPressed: () {
        setState(() {
          _updateData(docIdFb, name, contact, address, remarks, count);
        });
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Loyalty Card Update"),
      content: Text("Would you like to update the stars of $name to $count?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
