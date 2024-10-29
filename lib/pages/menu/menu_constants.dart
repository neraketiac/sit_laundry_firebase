import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/menu/menu_main.dart';
import 'package:laundry_firebase/pages/menu/menu_receipt.dart';
import 'package:laundry_firebase/pages/menu/menu_select_customer.dart';
import 'package:laundry_firebase/pages/menu/menu_sub_main.dart';

const String appBarMsg = "Wash Ko Lang";
int userId = 0;
String currentPage = "sales";
int cartCount = 0;
String fsKey = "";
const String sCollection = "SalesOngoing";
//bool salesOpened = false, receiptOpened = false;

var myAppBarX = AppBar(backgroundColor: Colors.lightBlueAccent, title: const Text(appBarMsg), actions: [
  Badge(
    label: readDataX('$sCollection/$fsKey/$fsKey'),
    offset: const Offset(-5, 0),
    child: IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart)),
  ),
  Badge(
    label: null,
    offset: const Offset(-5, 0),
    //child: IconButton(onPressed: () {}, icon: const Icon(Icons.account_circle)),
    child: IconButton(onPressed: () {}, icon: const Icon(Icons.no_accounts_rounded)),
  ),
]);

AppBar allAppBarX(BuildContext context) {
  return AppBar(backgroundColor: Colors.lightBlueAccent, title: const Text(appBarMsg), actions: [
    Badge(
      label: readDataX('$sCollection/$fsKey/$fsKey'),
      offset: const Offset(-5, 0),
      child: IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart)),
    ),
    Badge(
      label: null,
      offset: const Offset(-5, 0),
      child: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const MySelectCustomer()));
          },
          icon: Icon(userId > 0 ? Icons.account_circle : Icons.no_accounts_rounded)),
    ),
  ]);
}

Future<String> readDataPerCall(String s) async {
  var intTotalPrice = 0;

  var collection = FirebaseFirestore.instance.collection(s);
  var querySnapshot = await collection.get();
  // ignore: unused_local_variable
  for (var queryDocumentSnapshot in querySnapshot.docs) {
    intTotalPrice += 1;
    /*
    Map<String, dynamic> data = queryDocumentSnapshot.data();
    var name = data['name'];
    var phone = data['phone'];
    */
  }

  return (intTotalPrice.toString());
}

Widget readDataX(String s) {
  //read
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection(s).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Text('Something went wrong');
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        if (cartCount != 0) {
          return Text(cartCount.toString());
        } else {
          return const Text("Loading");
        }
      }

      if (snapshot.hasData) {
        //
        cartCount = 0;

        //body
        final buffRecords = snapshot.data?.docs.toList();

        // ignore: unused_local_variable
        for (var buffRecord in buffRecords!) {
          cartCount += 1;
        }
      }

      return Text(cartCount.toString());

      //);
    },
  );
}

Widget buildMenuItems(BuildContext context) => Drawer(
    backgroundColor: Colors.blueAccent,
    child: Column(
      children: [
        const DrawerHeader(child: Icon(Icons.wash)),
        ListTile(
          leading: const Icon(Icons.local_grocery_store_outlined),
          title: const Text("S A L E S"),
          onTap: () {
            if (currentPage != "sales") {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyMenuMain()));
            } else {
              Navigator.pop(context);
            }
            currentPage = "sales";
          },
        ),
        ListTile(
          leading: const Icon(Icons.receipt),
          title: const Text("R E C E I P T"),
          onTap: () {
            if (currentPage != "receipt") {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyMenuReceipt()));
            } else {
              Navigator.pop(context);
            }
            currentPage = "receipt";
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text("S E T U P"),
          onTap: () {
            currentPage = "setup";
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text("L O G O U T"),
          onTap: () {
            currentPage = "logout";
          },
        ),
      ],
    ));

Widget allButtonsX({
  required BuildContext context,
  required String image,
  required int id,
  required int price,
  required String item,
}) {
  return Material(
    child: InkWell(
      onTap: () {
        //addMenuDataX(context);
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => MySubMenu(id, price)));
      },
      child: Ink.image(
        image: AssetImage(image),
        child: Center(
            child: Column(
          children: [
            const SizedBox(
              height: 60,
            ),
            Text(
              item,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        )),
      ),
    ),
  );
}

void showMessageX(BuildContext context, String sMsg) {
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

Future<void> addMenuDataX(BuildContext context) async {
  CollectionReference collRef = FirebaseFirestore.instance.collection('$sCollection/$fsKey/$fsKey');
  collRef
      .add({
        'sales_id': 123,
        'sales_name': 'test',
        'sales_price': 123,
        'sales_order': 123,
      })
      .then((value) => {
            showMessageX(context, "Added to cart"),
          })
      // ignore: invalid_return_type_for_catch_error
      .catchError((error) => showMessageX(context, "Failed : $error"));
}
