import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyLoyaltyCard extends StatefulWidget {
  final String something;
  // ignore: use_super_parameters
  const MyLoyaltyCard(this.something, {super.key});

  @override
  State<MyLoyaltyCard> createState() => _MyLoyaltyCardState();
}

class _MyLoyaltyCardState extends State<MyLoyaltyCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blueAccent,
        appBar: AppBar(
          title: Column(
            children: [const Text("Wash Ko Lang"), Text("Your Loyalty Card ${widget.something}")],
          ),
          toolbarHeight: 60,
        ),
        body: Row(
          children: [
            Center(
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  _singleReadData(widget.something),
                ],
              ),
            ),
          ],
        ));
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
                      const Text("Name:"),
                      Text(buffRecord["Name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(
                        width: 20,
                      ),
                      const Text("Card Id:"),
                      Text(s, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Barangay:"),
                      Text(buffRecord["Barangay"], style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(
                        width: 20,
                      ),
                      const Text("Address:"),
                      Text(buffRecord["Address"], style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon((loyaltyCount) >= 1 ? Icons.star_border_purple500_outlined : Icons.circle_outlined),
                        label: const Text("1"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon((loyaltyCount) >= 2 ? Icons.star_border_purple500_outlined : Icons.circle_outlined),
                        label: const Text("2"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon((loyaltyCount) >= 3 ? Icons.star_border_purple500_outlined : Icons.circle_outlined),
                        label: const Text("3"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon((loyaltyCount) >= 4 ? Icons.star_border_purple500_outlined : Icons.circle_outlined),
                        label: const Text("4"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon((loyaltyCount) >= 5 ? Icons.star_border_purple500_outlined : Icons.circle_outlined),
                        label: const Text("5"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon((loyaltyCount) >= 6 ? Icons.star_border_purple500_outlined : Icons.circle_outlined),
                        label: const Text("6"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon((loyaltyCount) >= 7 ? Icons.star_border_purple500_outlined : Icons.circle_outlined),
                        label: const Text("7"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon((loyaltyCount) >= 8 ? Icons.star_border_purple500_outlined : Icons.circle_outlined),
                        label: const Text("8"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon((loyaltyCount) >= 9 ? Icons.star_border_purple500_outlined : Icons.circle_outlined),
                        label: const Text("9"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon((loyaltyCount) >= 10 ? Icons.star_border_purple500_outlined : Icons.circle_outlined),
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

          //return Text("Full Name: ${data['full_name']} ${data['last_name']}");
        }

        return const Text("loading");
      },
    );
  }
}
