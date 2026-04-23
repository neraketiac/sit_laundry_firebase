import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyLoyalty extends StatefulWidget {
  const MyLoyalty({super.key});

  @override
  State<MyLoyalty> createState() => _MyLoyaltyState();
}

class _MyLoyaltyState extends State<MyLoyalty> {
  String streamName = "0";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Column(
            children: [Text("Wash Ko Lang"), Text("Loyalty Entry")],
          ),
          toolbarHeight: 60,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        concatStreamName("1");
                      },
                      child: const Text("1")),
                  ElevatedButton(
                      onPressed: () {
                        concatStreamName("2");
                      },
                      child: const Text("2")),
                  ElevatedButton(
                      onPressed: () {
                        concatStreamName("3");
                      },
                      child: const Text("3")),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        concatStreamName("4");
                      },
                      child: const Text("4")),
                  ElevatedButton(
                      onPressed: () {
                        concatStreamName("5");
                      },
                      child: const Text("5")),
                  ElevatedButton(
                      onPressed: () {
                        concatStreamName("6");
                      },
                      child: const Text("6")),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        concatStreamName("7");
                      },
                      child: const Text("7")),
                  ElevatedButton(
                      onPressed: () {
                        concatStreamName("8");
                      },
                      child: const Text("8")),
                  ElevatedButton(
                      onPressed: () {
                        concatStreamName("9");
                      },
                      child: const Text("9")),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        concatStreamName("*");
                      },
                      child: const Text("*")),
                  ElevatedButton(
                      onPressed: () {
                        concatStreamName("0");
                      },
                      child: const Text("0")),
                  ElevatedButton(
                      onPressed: () {
                        concatStreamName("#");
                      },
                      child: const Text("#")),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(
                  width: 60,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      streamName = streamName;
                    });
                  },
                  child: const Text("Enter"),
                ),
              ]),
              Center(
                child: Column(
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    _singleReadData("JAYDIE123"),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void concatStreamName(String s) {
    log(s);
  }

  Widget _singleReadData(String s) {
    CollectionReference users = FirebaseFirestore.instance.collection('loyalty');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(s).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> buffRecord = snapshot.data!.data() as Map<String, dynamic>;

          final int loyaltyCount = buffRecord['Count']; //mod 10

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      // ignore: prefer_interpolation_to_compose_strings
                      Text("Name:" + buffRecord['Name']),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(onPressed: () {}, child: Icon((loyaltyCount) >= 1 ? Icons.star_border_purple500_outlined : Icons.circle_outlined)),
                      ElevatedButton(onPressed: () {}, child: Icon((loyaltyCount) >= 2 ? Icons.star_border_purple500_outlined : Icons.circle_outlined)),
                      ElevatedButton(onPressed: () {}, child: Icon((loyaltyCount) >= 3 ? Icons.star_border_purple500_outlined : Icons.circle_outlined)),
                      ElevatedButton(onPressed: () {}, child: Icon((loyaltyCount) >= 4 ? Icons.star_border_purple500_outlined : Icons.circle_outlined)),
                      ElevatedButton(onPressed: () {}, child: Icon((loyaltyCount) >= 5 ? Icons.star_border_purple500_outlined : Icons.circle_outlined)),
                      ElevatedButton(onPressed: () {}, child: Icon((loyaltyCount) >= 6 ? Icons.star_border_purple500_outlined : Icons.circle_outlined)),
                      ElevatedButton(onPressed: () {}, child: Icon((loyaltyCount) >= 7 ? Icons.star_border_purple500_outlined : Icons.circle_outlined)),
                      ElevatedButton(onPressed: () {}, child: Icon((loyaltyCount) >= 8 ? Icons.star_border_purple500_outlined : Icons.circle_outlined)),
                      ElevatedButton(onPressed: () {}, child: Icon((loyaltyCount) >= 9 ? Icons.star_border_purple500_outlined : Icons.circle_outlined)),
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
                  )
                ],
              ),
            ],
          );

          //return Text("Full Name: ${data['full_name']} ${data['last_name']}");
        }

        return const Text("loading");
      },
    );
  }

}
