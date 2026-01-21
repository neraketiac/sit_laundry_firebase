
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/employeemodel.dart';
import 'package:laundry_firebase/models/jobsonqueuemodelfbmodel.dart';
import 'package:laundry_firebase/services/database_employeemodel.dart';
import 'package:laundry_firebase/services/database_jobsonqueuefbmodel.dart';
import 'package:laundry_firebase/variables/variables.dart';

class MyMainLaundryBody extends StatefulWidget {
  final String empidClass;

  const MyMainLaundryBody(this.empidClass, {super.key});

  @override
  State<MyMainLaundryBody> createState() => _MyMainLaundryBodyState();
}

class _MyMainLaundryBodyState extends State<MyMainLaundryBody> {

   @override
  void initState() {
    super.initState();
    empIdGlobal = widget.empidClass;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        title: Text(
            "${convertTimeStampVar(Timestamp.now()).substring(0, 12).trim()}. Hello $empIdGlobal"),
        toolbarHeight: 25,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                width: 200,
                color: Colors.blue,
                padding: const EdgeInsets.all(8.0),
                child: Column(children: <Widget>[
                  const SizedBox(
                    height: 1,
                  ),
                  _readDataJobsOnQueue(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

   //read current employee
  Widget _readDataCurrentEmployee() {
    DatabaseEmployeeModel dbEM = DatabaseEmployeeModel(empIdGlobal);
    return StreamBuilder<QuerySnapshot>(
      stream: dbEM.getEmployeeModel(),
      builder: (context, snapshot) {
        List listEM = snapshot.data?.docs ?? [];
        bool bHeader = true;
        List<TableRow> rowDatas = [];
        if (listEM.isNotEmpty) {
          //header
          if (bHeader) {
            const rowData = TableRow(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 9, 194, 49)),
                children: [
                  Text(
                    "Employee Summary",
                    style: TextStyle(fontSize: 10),
                  ),
                ]);
            rowDatas.add(rowData);
            bHeader = false;
          }

          listEM.forEach((listEMData) {
            EmployeeModel eM = listEMData.data();
            final rowData = TableRow(
                decoration:
                    BoxDecoration(color: Colors.black),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          /*
                          showAlterJobsOnQueueVar(
                              context,
                              jOQMData.id.toString(),
                              jOQM,
                              lOIM,
                              jOQMNoChange,
                              lOIMNoChange);
                              */
                        },
                        //child: conDisplayVar(context, false, jOQFBM),
                      ),
                    ),
                  )
                ]);

            rowDatas.add(rowData);
          });
        }

        return Table(
          children: rowDatas,
        );
      },
    );
  }

   //read JobsOnQueue
  Widget _readDataJobsOnQueue() {
    DatabaseJobsOnQueueFBModel dbJOQFBM = DatabaseJobsOnQueueFBModel();
    return StreamBuilder<QuerySnapshot>(
      stream: dbJOQFBM.getJobsOnQueueFBM(),
      builder: (context, snapshot) {
        List listJOQFBM = snapshot.data?.docs ?? [];
        bool bHeader = true;
        List<TableRow> rowDatas = [];
        if (listJOQFBM.isNotEmpty) {
          //header
          if (bHeader) {
            const rowData = TableRow(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 9, 194, 49)),
                children: [
                  Text(
                    "Jobs On Queue",
                    style: TextStyle(fontSize: 10),
                  ),
                ]);
            rowDatas.add(rowData);
            bHeader = false;
          }

          listJOQFBM.forEach((listJOQFBMData) {
            JobsOnQueueFBModel jOQFBM = listJOQFBMData.data();
            final rowData = TableRow(
                decoration:
                    BoxDecoration(color: Colors.black),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          /*
                          showAlterJobsOnQueueVar(
                              context,
                              jOQMData.id.toString(),
                              jOQM,
                              lOIM,
                              jOQMNoChange,
                              lOIMNoChange);
                              */
                        },
                        //child: conDisplayVar(context, false, jOQFBM),
                      ),
                    ),
                  )
                ]);

            rowDatas.add(rowData);
          });
        }

        return Table(
          children: rowDatas,
        );
      },
    );
  }

}