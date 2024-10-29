import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/menu/menu_constants.dart';

class MyItemMenu extends StatefulWidget {
  const MyItemMenu(this.intFK, this.intFKPrice, {super.key});
  final int intFK, intFKPrice;

  @override
  State<MyItemMenu> createState() => _MyItemMenuState();
}

class _MyItemMenuState extends State<MyItemMenu> {
  bool withDetails = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBarX,
      /*
      appBar: AppBar(
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.red),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyMenuMain()));
                //Navigator.of(context).pop();
              }),
          title: const Text("Item Menu"),
          backgroundColor: Colors.blueAccent,
          actions: [
            Badge(
              label: Text(intTotalPrice.toString()),
              offset: const Offset(-5, 0),
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart)),
            )
          ]),
          */
      //drawer: buildMenuItems(context),
      body: _firstStreamBuilder(widget.intFK, widget.intFKPrice),
    );
  }

  Widget _firstStreamBuilder(int intCatId, int intCatPrice) {
    Widget secStreamBuilder = _streamBuilder(intCatId, intCatPrice);
    return secStreamBuilder;
  }

  Widget _streamBuilder(int intCatId, int intCatPrice) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('MenuItem').where('cat_id_fk', isEqualTo: intCatId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text('Loading menu...'));
          }
          if (snapshot.data?.size == 0) {
            withDetails = false;
            //Navigator.pop(context);
            return Padding(
                padding: const EdgeInsets.all(1.0), child: _allButtons(context: context, image: 'images/9.png', id: intCatId, price: intCatPrice, item: 'Add this item'));
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              return Container(
                  width: 10,
                  height: 10,
                  padding: const EdgeInsets.all(1.0),
                  child: _allButtons(context: context, image: 'images/5.png', id: doc['item_id'], price: doc['item_price'], item: doc['item_name'].toString()));
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
          setState(() {});

          //Navigator.of(context).push(MaterialPageRoute(builder: (context) => MySubMenu(id, price)));
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
}
