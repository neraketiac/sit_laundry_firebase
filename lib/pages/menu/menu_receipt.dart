import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/menu/menu_constants.dart';

class MyMenuReceipt extends StatelessWidget {
  const MyMenuReceipt({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: myAppBarX,
        /*
        appBar: AppBar(
          title: const Text("Item Menu"),
          backgroundColor: Colors.blueAccent,
        ),
        */
        //drawer: buildMenuItems(context),
        body: const Text("watata"),
      );
}
