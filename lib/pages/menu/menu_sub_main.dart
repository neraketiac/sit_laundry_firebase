import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/menu/menu_constants.dart';

class MySubMenu extends StatelessWidget {
  const MySubMenu(this.intFK, this.intPrice, {super.key});

  final int intFK, intPrice;

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
        body: _streamBuilderItem(intFK, intPrice),
      );

  Widget _streamBuilderItem(int intCatId, int intDisPrice) {
    return StreamBuilder(
        //stream: FirebaseFirestore.instance.collection('MenuItem').orderBy('order_id').snapshots(),
        stream: FirebaseFirestore.instance.collection('MenuItem').where('cat_id_fk', isEqualTo: intCatId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text('Loading menu...'));
          }

          if (snapshot.data?.size == 0) {
            //showMessageSub(context, "added");
            Navigator.pop(context);
            return Center(child: Text('no data$intDisPrice'));
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: _allButtonsSub(context: context, image: 'images/5.png', id: doc['item_id'], price: doc['item_price'], item: doc['item_name'].toString()));
            },
            itemCount: snapshot.data?.docs.length,
          );
        });
  }

  Widget _allButtonsSub({
    required BuildContext context,
    required String image,
    required int id,
    required int price,
    required String item,
  }) {
    return Material(
      child: InkWell(
        onTap: () {
          //addMenuData(context);
          ///intTotalPrice += 5;
          ///Navigator.of(context).push(MaterialPageRoute(builder: (context) => MySubMenu(id, price)));
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

  void showMessageSub(BuildContext context, String sMsg) {
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
}
