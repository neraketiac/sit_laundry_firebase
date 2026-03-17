import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/employees/models/employeemodel.dart';
import 'package:laundry_firebase/core/global/variables.dart';

const String EMPLOYEE_HIST_REF = "EmployeeHist";

class DatabaseEmployeeHist {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _employeeHistRef;

  DatabaseEmployeeHist() {
    _employeeHistRef =
        _firestore.collection(EMPLOYEE_HIST_REF).withConverter<EmployeeModel>(
            fromFirestore: (snapshots, _) => EmployeeModel.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (eM, _) => eM.toJson());
  }

  Stream<QuerySnapshot> getEmployeeHistory() {
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

  Future<QuerySnapshot> getEmployeeHistoryPaginated({DocumentSnapshot? lastDoc}) async {
    Query query;
    if (empIdGlobal == 'Ket' || empIdGlobal == 'DonF') {
      query = _employeeHistRef.orderBy('LogDate', descending: true).limit(50);
    } else {
      query = _employeeHistRef
          .where('EmpId', isEqualTo: empNameToId[empIdGlobal])
          .orderBy('LogDate', descending: true)
          .limit(50);
    }
    
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }
    
    return await query.get();
  }

  Future<bool> addEmployeeHist(EmployeeModel eM) async {
    bool bSuccess = false;
    await _employeeHistRef
        .add(eM)
        .then((value) => {
              print("Supplies History Save done."),
              bSuccess = true,
            })
        .catchError((error) => {
              print("Failed : $error ${eM.empId}"),
              bSuccess = false,
            });
    return bSuccess;
  }
}
