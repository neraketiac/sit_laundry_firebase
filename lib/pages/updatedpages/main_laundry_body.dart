import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/pages/updatedpagesmethods/readDataEmployeeCurr.dart';
import 'package:laundry_firebase/pages/updatedpagesmethods/readDataEmployeeHist.dart';
import 'package:laundry_firebase/pages/updatedpagesmethods/readDataJobsOnQueue.dart';
import 'package:laundry_firebase/pages/updatedpagesmethods/readSuppliesCurrent.dart';
import 'package:laundry_firebase/pages/updatedpagesmethods/readSuppliesHist.dart';
import 'package:laundry_firebase/pages/updatedpagesmethods/sharedMethodAndVariable.dart';
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
    putEntries(); // only to use getItemNameOnly()
  }

  Widget _checkBox({
    required String title,
    required bool selectedBool,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 8,
        ),
        Transform.scale(
          scale: 0.8, // shrink the checkbox itself
          child: Checkbox(
            value: selectedBool,
            onChanged: onChanged,
            visualDensity:
                VisualDensity(horizontal: -4, vertical: -4), // tighter
            materialTapTargetSize:
                MaterialTapTargetSize.shrinkWrap, // no extra padding
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8), // tiny gap
      ],
    );
  }

  Widget _animatedPanel({
    required bool visible,
    required double width,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      width: visible ? width : 0,
      child: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            constraints: BoxConstraints(
              minWidth: 0,
              maxWidth: width,
            ),
            color: Colors.blue,
            padding: const EdgeInsets.all(8),
            child: child,
          ),
        ),
      ),
    );
  }

  //########################### MAIN ###############################
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        title: Row(
          children: [
            Text(
                "${DateFormat('MMM dd, yyyy').format(Timestamp.now().toDate())}. Hello $empIdGlobal"),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 10,
                ),
                Container(
                  color: Colors.amber,
                  child: _checkBox(
                    title: 'Show Laundry',
                    selectedBool: selectedShowLaundry,
                    onChanged: (value) {
                      setState(() {
                        selectedShowLaundry = value ?? false;
                      });
                    },
                  ),
                ),
                Container(
                  color: Colors.amber[200],
                  child: _checkBox(
                    title: 'Current Supplies',
                    selectedBool: selectedShowSuppliesCurr,
                    onChanged: (value) {
                      setState(() {
                        selectedShowSuppliesCurr = value ?? false;
                      });
                    },
                  ),
                ),
                Container(
                  color: Colors.amber,
                  child: _checkBox(
                    title: 'History Supplies',
                    selectedBool: selectedShowSuppliesHist,
                    onChanged: (value) {
                      setState(() {
                        selectedShowSuppliesHist = value ?? false;
                      });
                    },
                  ),
                ),
                Container(
                  color: Colors.amber[200],
                  child: _checkBox(
                    title: 'Employee Details',
                    selectedBool: selectedShowEmployee,
                    onChanged: (value) {
                      setState(() {
                        selectedShowEmployee = value ?? false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        toolbarHeight: 25,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _animatedPanel(
              visible: selectedShowLaundry,
              width: 250,
              child: readDataJobsOnQueue(),
            ),
            _animatedPanel(
              visible: selectedShowSuppliesCurr,
              width: 250,
              child: readDataSuppliesCurrent(),
            ),
            _animatedPanel(
              visible: selectedShowSuppliesHist,
              width: 600,
              child: readDataSuppliesHistory(),
            ),
            _animatedPanel(
              visible: selectedShowEmployee,
              width: 600,
              child: Column(children: <Widget>[
                const SizedBox(
                  height: 1,
                ),
                readDataEmployeeCurr(),
                readDataEmployeeHist(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
