import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert' show utf8;

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show AnchorElement;

import 'package:intl/intl.dart';

class MySaveText extends StatefulWidget {
  const MySaveText({super.key});

  @override
  State<MySaveText> createState() => _MySaveTextState();
}

class _MySaveTextState extends State<MySaveText> {
  @override
  void initState() {
    super.initState();
  }

  late String textData = "";

  @override
  Widget build(BuildContext context) {
    fetchUsers();

    return Text("Web Backup only");
    // return StreamBuilder<QuerySnapshot>(
    //   stream: FirebaseFirestore.instance
    //       .collection('JobsOnGoing')
    //       .orderBy('JobsId')
    //       .snapshots(),
    //   builder: (context, snapshot) {
    //     List<TableRow> rowDatas = [];
    //     if (snapshot.hasData) {
    //       const rowData =
    //           TableRow(decoration: BoxDecoration(color: Colors.red), children: [
    //         Text(
    //           "Jobs On Queue",
    //           style: TextStyle(fontSize: 10),
    //         ),
    //       ]);
    //       rowDatas.add(rowData);

    //       //body
    //       final buffRecords = snapshot.data?.docs.toList();

    //       for (var buffRecord in buffRecords!) {
    //         textData =
    //             "\n$textData${buffRecord['JobsId']},${buffRecord['Customer']},";
    //         final rowData = TableRow(children: [
    //           Text("watata"),
    //         ]);
    //         rowDatas.add(rowData);
    //       }
    //     }

    //     return Table(
    //       children: rowDatas,
    //     );
    //   },
    // );
  }

  void saveTextFile(String filename) {
    AnchorElement()
      ..href =
          '${Uri.dataFromString(textData, mimeType: 'text/plain', encoding: utf8)}'
      ..download = filename
      ..style.display = 'none'
      ..click();
  }

  Future<void> fetchUsers() {
    CollectionReference users =
        FirebaseFirestore.instance.collection('JobsDone');

    return users.get().then((QuerySnapshot snapshot) {
      textData =
          "Bag,Basket,CreatedBy,Customer,DateD,DateQ,DateW,ExtraDryPrice,FinalLoad,FinalPrice,Fold,InitialLoad,InitialPrice,JobsId,Kulang,MaxFab,MaySukli,Mix,NeedOn,PaymentReceivedBy,PaymentStat,QueueStat,\n";
      for (var doc in snapshot.docs) {
        //textData = "\n" + "$textData${doc['JobsId']},${doc['Customer']},";

        textData =
            "$textData${doc['C4_Bag']},${doc['C3_Basket']},${doc['A4_CreatedBy']},${doc['Customer']},${convertTimeStamp(doc['D7_DateD'])},${convertTimeStamp(doc['A1_DateQ'])},${convertTimeStamp(doc['DateW'])},${doc['ExtraDryPrice']},${doc['B2_FinalLoad']},${doc['B3_FinalPrice']},${doc['C1_Fold']},${doc['A7_InitialLoad']},${doc['A8_InitialPrice']},${doc['JobsId']},${doc['Kulang']},${doc['MaxFab']},${doc['MaySukli']},${doc['C2_Mix']},${convertTimeStamp(doc['B9_NeedOn'])},${doc['C9_PaymentReceivedBy']},${doc['PaymentStat']},${doc['QueueStat']},\n";

        // textData =
        //     "${textData}Bag:${doc['C4_Bag']},Basket:${doc['C3_Basket']},CreatedBy:${doc['A4_CreatedBy']},Customer:${doc['Customer']},DateD:${convertTimeStamp(doc['D7_DateD'])},DateQ:${convertTimeStamp(doc['A1_DateQ'])},DateW:${convertTimeStamp(doc['DateW'])},ExtraDryPrice:${doc['ExtraDryPrice']},FinalLoad:${doc['B2_FinalLoad']},FinalPrice:${doc['B3_FinalPrice']},Fold:${doc['C1_Fold']},InitialLoad:${doc['A7_InitialLoad']},InitialPrice:${doc['A8_InitialPrice']},JobsId:${doc['JobsId']},Kulang:${doc['Kulang']},MaxFab:${doc['MaxFab']},MaySukli:${doc['MaySukli']},Mix:${doc['C2_Mix']},NeedOn:${convertTimeStamp(doc['B9_NeedOn'])},PaymentReceivedBy:${doc['C9_PaymentReceivedBy']},PaymentStat:${doc['PaymentStat']},QueueStat:${doc['QueueStat']},\n";
      }
      saveTextFile("JobsDone");
    }).catchError((error) => print("Failed to fetch users: $error"));
  }

  static convertTimeStamp(Timestamp timestamp) {
    //assert(timestamp != null);
    String convertedDate;
    convertedDate = DateFormat.yMMMd()
        .add_jm()
        .format(timestamp.toDate())
        .replaceAll(",", "");
    //return "${convertedDate.substring(0, convertedDate.indexOf(',') + 1)} ${convertedDate.substring(convertedDate.indexOf(':') - 2, convertedDate.indexOf(':'))} ${convertedDate.substring(convertedDate.indexOf(':') + 4, convertedDate.indexOf(':') + 6)}";
    return convertedDate;
  }
}
