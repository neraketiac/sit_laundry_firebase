import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/oldmodels/employeesetupmodel.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

const String EMPLOYEE_SETUP_REF = "EmployeeSetup";

class DatabaseEmployeeSetup {
  final CollectionReference<EmployeeSetupModel> _ref = FirebaseFirestore
      .instance
      .collection(EMPLOYEE_SETUP_REF)
      .withConverter<EmployeeSetupModel>(
        fromFirestore: (snap, _) => EmployeeSetupModel.fromJson(snap.data()!),
        toFirestore: (model, _) => model.toJson(),
      );

  Stream<QuerySnapshot<EmployeeSetupModel>> get() {
    return _ref.where('EmpId', isEqualTo: empNameToId[empIdGlobal]).snapshots();
  }

  Future<void> add(EmployeeSetupModel model) async {
    await _ref.add(model);
  }

  DocumentReference<EmployeeSetupModel> docId() {
    return _ref.doc();
  }

  Future<void> update(EmployeeSetupModel model) async {
    await _ref.doc(model.docId).update(model.toJson());
  }
}
