import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/menu/menu_constants.dart';
import 'package:laundry_firebase/pages/menu/menu_item.dart';

class MyMenuMain extends StatefulWidget {
  const MyMenuMain({super.key});

  @override
  State<MyMenuMain> createState() => _MyMenuMainState();
}

class _MyMenuMainState extends State<MyMenuMain> {
  //var intLastPrice = 0;
  //CollectionReference collRef = FirebaseFirestore.instance.collection('MenuCategory');

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: allAppBarX(context), drawer: buildMenuItems(context), body: _streamBuilder(0));
  }

  Widget _streamBuilder(int intFK) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('MenuCategory').orderBy('order_id').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text('Loading menu...'));
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: allButtonsX(context: context, image: 'images/5.png', id: doc['cat_id'], price: doc['cat_price'], item: doc['cat_name'].toString()));
            },
            itemCount: snapshot.data?.docs.length,
          );
        });
  }

  Widget _allButtons({
    required BuildContext context,
    required String image,
    required int id,
    required int price,
    required String item,
  }) {
    return Material(
      child: InkWell(
        onTap: () {
          addMenuDataX(context);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyItemMenu(id, price)));
          setState(() {});
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

  _myAppBar() {
    return AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text(appBarMsg),
        //actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart),), Badge.count(count: 5)],
        actions: [
          Badge(
            label: const Text('0'),
            offset: const Offset(-5, 0),
            child: IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart)),
          )
        ]);
  }

  /*
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

  Future<void> addMenuData(BuildContext context) async {
    collRef
        .add({
          'cat_id': 123,
          'cat_name': 'test',
          'cat_price': 123,
          'order_id': 123,
        })
        .then((value) => {
              showMessage(context, "New Customer Added"),
            })
        // ignore: invalid_return_type_for_catch_error
        .catchError((error) => showMessage(context, "Failed : $error"));
  }
  */
}
