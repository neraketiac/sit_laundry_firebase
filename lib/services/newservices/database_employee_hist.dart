import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/newmodels/employeemodel.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

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
