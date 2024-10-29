import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/menu/menu_constants.dart';
import 'package:laundry_firebase/pages/menu/menu_main.dart';

class MySelectCustomer extends StatelessWidget {
  const MySelectCustomer({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: null,
        body: Center(
            child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  userId = 888;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyMenuMain()));
                },
                child: const Text("Select")),
            ElevatedButton(
                onPressed: () {
                  userId = 0;
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyMenuMain()));
                },
                child: const Text("Close")),
          ],
        )),
      );
}
