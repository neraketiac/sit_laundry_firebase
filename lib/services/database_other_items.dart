import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/otherItems.dart';

const String COLLECTION_REF = "JobsOnQueue";
const String SUB_COLLECTION_REF = "OtherItems";

class DatabaseOtherItems {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _otherItemsRef;

  DatabaseOtherItems(String id) {
    _otherItemsRef = _firestore
        .collection(COLLECTION_REF)
        .doc(id)
        .collection(SUB_COLLECTION_REF)
        .withConverter<OtherItems>(
            fromFirestore: (snapshots, _) => OtherItems.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (otherItems, _) => otherItems.toJson());
  }

  Stream<QuerySnapshot> getOtherItems() {
    return _otherItemsRef.snapshots();
  }

  void addOtherItems(OtherItems otherItems) async {
    _otherItemsRef.add(otherItems);
  }
}
