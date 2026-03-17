import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/pages/body/Loyalty/loyalty_admin.dart';
import 'package:laundry_firebase/features/pages/body/Loyalty/loyalty_single.dart';
import 'package:laundry_firebase/features/menus/menu_constants.dart';
import 'package:laundry_firebase/features/menus/menu_main.dart';
import 'package:laundry_firebase/features/pages/body/Loyalty/save_text.dart';
import 'package:laundry_firebase/features/pages/header/main_laundry_header.dart';
import 'package:laundry_firebase/features/customers/repository/customer_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';

import 'package:web/web.dart' as web;

class EnterLoyaltyCode extends StatefulWidget {
  const EnterLoyaltyCode({super.key});

  @override
  State<EnterLoyaltyCode> createState() => _EnterLoyaltyCodeState();
}

class _EnterLoyaltyCodeState extends State<EnterLoyaltyCode> {
  String? error;

  String streamName = "0";

  @override
  void initState() {
    super.initState();
    CustomerRepository.instance.loadOnce();
    //OtherItemsRepository.instance.loadOnce(collectionName: 'other_items');

    _checkSavedCode();
  }

  Future<void> _checkSavedCode() async {
    final savedCode = web.window.localStorage.getItem(storageKey);

    if (savedCode == null) {
      setState(() => loading = false);
      return;
    }

    final isValid = await _validateCode(savedCode);

    setState(() {
      loggedIn = isValid;
      loading = false;
    });
  }

  Future<bool> _validateCode(String code) async {
    final snap = await FirebaseFirestore.instance
        .collection('EmployeeSetup')
        .where('EmpId', isEqualTo: code)
        // .where('active', isEqualTo: true)
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }

  Future<void> _login() async {
    final code = memberController.text.trim();

    if (code.isEmpty) {
      setState(() => error = 'Please enter your unique number');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final isValid = await _validateCode(code);

    if (isValid) {
      if (rememberMe) {
        web.window.localStorage.setItem(storageKey, code);
      }

      setState(() {
        loggedIn = true;
        loading = false;
      });
    } else {
      setState(() {
        error = 'Invalid unique number';
        loading = false;
      });
    }
  }

  void _logout() {
    web.window.localStorage.removeItem(storageKey);
    setState(() {
      loggedIn = false;
      memberController.clear();
      rememberMe = true;
    });
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
          child: loading
              ? const CircularProgressIndicator()
              : loggedIn
                  ? _rowSingleRead()
                  : _loginWKL(),
        ));
  }

  Row _loginWKL() {
    return Row(
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
                        // _singleReadData(memberController.text);
                        _login();
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
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(error.toString() == 'null' ? '' : error.toString(),
                      style: TextStyle(color: Colors.red))
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  void setMemberController(String s) {
    setState(() {
      memberController.text = memberController.text + s;
    });
  }

  void concatStreamName(String s) {
    log(s);
  }

  void _queuePage(BuildContext context, String empid) {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => MyMainLaundryHeader(empid)));
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

  Row _rowSingleRead() {
    final savedCode = web.window.localStorage.getItem(storageKey);
    // if (loggedIn) {
    _singleReadData(savedCode.toString());
    // } else {
    //   return _loginWKL();
    // }
    return Row(
      children: [],
    );
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
