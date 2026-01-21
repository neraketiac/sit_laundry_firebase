import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/customermodel.dart';
import 'package:laundry_firebase/pages/home.dart';
import 'package:laundry_firebase/pages/loyalty_admin.dart';
import 'package:laundry_firebase/pages/loyalty_single.dart';
import 'package:laundry_firebase/pages/menu/menu_constants.dart';
import 'package:laundry_firebase/pages/menu/menu_main.dart';
import 'package:laundry_firebase/pages/save_text.dart';
import 'package:laundry_firebase/pages/updatedpages/main_laundry_header.dart';
import 'package:laundry_firebase/variables/updatedvariables/customer_repository.dart';
import 'package:laundry_firebase/variables/variables.dart';

class EnterLoyaltyCode extends StatefulWidget {
  const EnterLoyaltyCode({super.key});

  @override
  State<EnterLoyaltyCode> createState() => _EnterLoyaltyCodeState();
}

class _EnterLoyaltyCodeState extends State<EnterLoyaltyCode> {
  String streamName = "0";
  late TextEditingController memberController = TextEditingController();
  final List<CustomerModel> customers = [];
  
  @override
  void initState() {
    super.initState();
  CustomerRepository.instance.loadOnce();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueAccent,
        appBar: AppBar(
          title: const Column(
            children: [Text("Wash Ko Lang"), Text("Loyalty Entry")],
          ),
          toolbarHeight: 60,
        ),
        body: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                setMemberController("1");
                              });
                            },
                            child: const Text("1")),
                        const SizedBox(
                          width: 1,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              setMemberController("2");
                            },
                            child: const Text("2")),
                        const SizedBox(
                          width: 1,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              setMemberController("3");
                            },
                            child: const Text("3")),
                      ],
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              setMemberController("4");
                            },
                            child: const Text("4")),
                        const SizedBox(
                          width: 1,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              setMemberController("5");
                            },
                            child: const Text("5")),
                        const SizedBox(
                          width: 1,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              setMemberController("6");
                            },
                            child: const Text("6")),
                      ],
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              setMemberController("7");
                            },
                            child: const Text("7")),
                        ElevatedButton(
                            onPressed: () {
                              setMemberController("8");
                            },
                            child: const Text("8")),
                        ElevatedButton(
                            onPressed: () {
                              setMemberController("9");
                            },
                            child: const Text("9")),
                      ],
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              setMemberController("*");
                            },
                            child: const Text("*")),
                        ElevatedButton(
                            onPressed: () {
                              setMemberController("0");
                            },
                            child: const Text("0")),
                        ElevatedButton(
                            onPressed: () {
                              setMemberController("#");
                            },
                            child: const Text("#")),
                      ],
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (memberController.text.isNotEmpty) {
                              _singleReadData(memberController.text);
                            }
                          });
                        },
                        child: const Text("View Card"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            memberController.text = "";
                          });
                        },
                        child: const Text("Clear"),
                      ),
                    ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Your Card Num: ${memberController.text}"),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void setMemberController(String s) {
    setState(() {
      memberController.text = memberController.text + s;
    });
  }

  void concatStreamName(String s) {
    log(s);
  }

  void _suppliesPage(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const MyHome()));
  }

  void _queuePage(BuildContext context, String empid) {
    Navigator.of(context)
        // .push(MaterialPageRoute(builder: (context) => MyQueue(empid)));
        .push(MaterialPageRoute(builder: (context) => MyMainLaundryHeader(empid)));
  }

  void _singleCard(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MyLoyaltyCard(memberController.text)));
  }

  void _allCards(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoyaltyAdmin()));
  }

  void _menuMain(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const MyMenuMain()));
  }

  void _saveText(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const MySaveText()));
  }

  Future<void> _singleReadData(String s) async {
    // // checkInternet(context);
    // // if (bHaveInternet) {
    // putEntries(); // try to put in other class, because right now, still no empid global
    // //anyone using empid global, cannot call here, because right now, it is still empty
    // //to comment putEntries;
    // //resetJOQMGlobalVar();
    // //fetchUsers();
    // //to comment putEntries end;
    if (s == "16") {
      _allCards(context);
    } else if (s == "456") {
      _suppliesPage(context);
    } else if (s == "369") {
      _saveText(context);
    } else if (s == "678") {
      fsKey = s;
      _menuMain(context);
    } else {
      var collection = FirebaseFirestore.instance.collection('loyalty');
      var docSnapshot = await collection.doc(s).get();
      if (docSnapshot.exists) {
        // ignore: use_build_context_synchronously
        _singleCard(context);
      } else {
        if (mapEmpId[s]!.isNotEmpty) {
          // ignore: use_build_context_synchronously    
          _queuePage(context, mapEmpId[s]!);
        } else {
          memberController.clear();
        }
      }
    }
    // }
  }
}
