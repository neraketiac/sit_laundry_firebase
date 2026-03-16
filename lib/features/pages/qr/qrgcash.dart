import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/constants/sharedConstantsFinal.dart';
import 'package:laundry_firebase/core/global/variables_all_codes.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/core/global/variables_supplies.dart';

class QRCash extends StatefulWidget {
  const QRCash({super.key});

  @override
  State<QRCash> createState() => _QRCashState();
}

class _QRCashState extends State<QRCash> {
  late String qrData;

  @override
  void initState() {
    super.initState();
    SuppliesHistRepository.instance.reset();
    SuppliesHistRepository.instance
        .setItemName(getItemNameOnly(menuOthCashInOutFunds, selectedFundCode!));
    SuppliesHistRepository.instance.setItemId(menuOthCashInOutFunds);
    SuppliesHistRepository.instance.setItemUniqueId(selectedFundCode!);
    SuppliesHistRepository.instance.setRemarks(remarksSuppliesVar.text);
    SuppliesHistRepository.instance.setCurrentCounter(
        int.parse(customerAmountVar.text.replaceAll(',', '')));
  }

  Future<void> saveButtonProcessEOD() async {
    await setSuppliesRepository(context);
  }

  @override
  Widget build(BuildContext context) {
    saveButtonProcessEOD();
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Cash Payment'),
      ),
      body: Center(
        child: Container(
          child: Text('GCash QR'),
        ),
      ),
    );
  }
}
