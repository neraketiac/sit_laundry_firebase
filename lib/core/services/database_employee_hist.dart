import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/utils/firestore_timeout.dart';
import 'package:laundry_firebase/features/employees/models/employeemodel.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';

const String EMPLOYEE_HIST_REF = "EmployeeHist";

class DatabaseEmployeeHist {
  final _firestore = FirebaseService.employeeFirestore;
  late final CollectionReference _employeeHistRef;

  DatabaseEmployeeHist() {
    _employeeHistRef = _firestore
        .collection(EMPLOYEE_HIST_REF)
        .withConverter<EmployeeModel>(
            fromFirestore: (s, _) => EmployeeModel.fromJson(s.data()!),
            toFirestore: (eM, _) => eM.toJson());
  }

  Stream<QuerySnapshot> getEmployeeHistory({String? filterEmpId}) {
    if (filterEmpId != null) {
      return _employeeHistRef
          .where('EmpId', isEqualTo: filterEmpId)
          .orderBy('LogDate', descending: true)
          .limit(100)
          .snapshots();
    }
    if (empIdGlobal == 'Ket' || empIdGlobal == 'DonF') {
      return _employeeHistRef
          .orderBy('LogDate', descending: true)
          .limit(100)
          .snapshots();
    } else {
      return _employeeHistRef
          .where('EmpId', isEqualTo: empNameToId[empIdGlobal])
          .orderBy('LogDate', descending: true)
          .limit(100)
          .snapshots();
    }
  }

  Future<QuerySnapshot> getEmployeeHistoryPaginated(
      {DocumentSnapshot? lastDoc, String? filterEmpId}) async {
    Query query;
    if (filterEmpId != null) {
      query = _employeeHistRef
          .where('EmpId', isEqualTo: filterEmpId)
          .orderBy('LogDate', descending: true)
          .limit(20);
    } else if (empIdGlobal == 'Ket' || empIdGlobal == 'DonF') {
      query = _employeeHistRef.orderBy('LogDate', descending: true).limit(20);
    } else {
      query = _employeeHistRef
          .where('EmpId', isEqualTo: empNameToId[empIdGlobal])
          .orderBy('LogDate', descending: true)
          .limit(20);
    }
    if (lastDoc != null) query = query.startAfterDocument(lastDoc);
    return query.get().withFsTimeout();
  }

  Future<bool> addEmployeeHist(EmployeeModel eM) async {
    try {
      await _employeeHistRef.add(eM).withFsTimeout();
      return true;
    } catch (e) {
      return false;
    }
  }
}
