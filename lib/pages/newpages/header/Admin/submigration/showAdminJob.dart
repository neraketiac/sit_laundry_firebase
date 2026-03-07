import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';

class AdminJobRepoViewer extends StatefulWidget {
  final JobModelRepository jobRepo;

  const AdminJobRepoViewer({
    super.key,
    required this.jobRepo,
  });

  @override
  State<AdminJobRepoViewer> createState() => _AdminJobRepoViewerState();
}

class _AdminJobRepoViewerState extends State<AdminJobRepoViewer> {
  late JobModelRepository jobRepo;

  @override
  void initState() {
    super.initState();
    jobRepo = widget.jobRepo;
  }

  String formatValue(dynamic v) {
    if (v == null) return "-";

    if (v is Timestamp) {
      return DateFormat('MMM dd yyyy').format(v.toDate());
    }

    if (v is DateTime) {
      return DateFormat('MMM dd yyyy').format(v);
    }

    return v.toString();
  }

  Widget rowRepoSelected(String label, dynamic repo, dynamic selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 200, child: Text(label)),

          /// Repo column
          Expanded(child: Text(formatValue(repo))),

          /// Selected column
          Expanded(
            child: TextFormField(
              initialValue: formatValue(selected),
              onChanged: (v) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget rowRepoOnly(String label, dynamic repo) {
    bool isDate = repo is Timestamp || repo is DateTime;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 200, child: Text(label)),
          Expanded(
            child: isDate
                ? InkWell(
                    onTap: () async {
                      DateTime initial = repo is Timestamp
                          ? repo.toDate()
                          : repo is DateTime
                              ? repo
                              : DateTime.now();

                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setState(() {});
                      }
                    },
                    child: Text(formatValue(repo)),
                  )
                : Text(formatValue(repo)),
          ),
        ],
      ),
    );
  }

  Widget rowSelectedOnly(String label, dynamic selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 200, child: Text(label)),
          Expanded(child: Text(formatValue(selected))),
        ],
      ),
    );
  }

  Widget section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Admin JobRepo Debug"),
      content: SizedBox(
        width: 700,
        height: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  SizedBox(width: 200, child: Text("Field")),
                  Expanded(child: Text("Repo")),
                  Expanded(child: Text("Selected")),
                ],
              ),
              const Divider(),
              section("Identity"),
              rowRepoOnly("docId", jobRepo.docId),
              rowRepoSelected("jobId", jobRepo.jobId, jobRepo.selectedJobId),
              section("Dates"),
              rowRepoOnly("dateQ", jobRepo.dateQ),
              rowRepoOnly("needOn", jobRepo.needOn),
              rowRepoOnly("dateO", jobRepo.dateO),
              rowRepoOnly("paidD", jobRepo.paidD),
              rowRepoOnly("dateD", jobRepo.dateD),
              rowRepoOnly("dateC", jobRepo.dateC),
              rowRepoOnly("customerPickupDate", jobRepo.customerPickupDate),
              rowRepoOnly("riderDeliveryDate", jobRepo.riderDeliveryDate),
              section("Employee"),
              rowRepoOnly("createdBy", jobRepo.createdBy),
              rowRepoOnly("currentEmpId", jobRepo.currentEmpId),
              section("Customer"),
              rowRepoSelected(
                  "customerId", jobRepo.customerId, jobRepo.selectedCustomerId),
              rowRepoSelected("customerName", jobRepo.customerName,
                  jobRepo.selectedCustomerNameVar.text),
              rowRepoOnly("forSorting", jobRepo.forSorting),
              rowRepoOnly("riderPickup", jobRepo.riderPickup),
              rowRepoSelected("isCustomerPickedUp", jobRepo.isCustomerPickedUp,
                  jobRepo.selectedIsCustomerPickedUp),
              rowRepoSelected(
                  "isDeliveredToCustomer",
                  jobRepo.isDeliveredToCustomer,
                  jobRepo.selectedIsDeliveredToCustomer),
              section("Pricing"),
              rowRepoSelected(
                  "perKilo", jobRepo.perKilo, jobRepo.selectedPerKilo),
              rowRepoSelected(
                  "perLoad", jobRepo.perLoad, jobRepo.selectedPerLoad),
              rowRepoSelected(
                  "finalKilo", jobRepo.finalKilo, jobRepo.selectedFinalKilo),
              rowRepoSelected(
                  "finalLoad", jobRepo.finalLoad, jobRepo.selectedFinalLoad),
              rowRepoSelected(
                  "finalPrice", jobRepo.finalPrice, jobRepo.selectedFinalPrice),
              rowRepoSelected("promoCounter", jobRepo.promoCounter,
                  jobRepo.selectedPromoCounter),
              rowRepoOnly("pricingSetup", jobRepo.pricingSetup),
              section("Options"),
              rowRepoOnly("regular", jobRepo.regular),
              rowRepoOnly("sayosabon", jobRepo.sayosabon),
              rowRepoOnly("addOn", jobRepo.addOn),
              rowRepoSelected("fold", jobRepo.fold, jobRepo.selectedFold),
              rowRepoSelected("mix", jobRepo.mix, jobRepo.selectedMix),
              section("Containers"),
              rowRepoSelected("basket", jobRepo.basket, jobRepo.selectedBasket),
              rowRepoSelected("ebag", jobRepo.ebag, jobRepo.selectedEbag),
              rowRepoSelected("sako", jobRepo.sako, jobRepo.selectedSako),
              section("Payment"),
              rowRepoSelected("unpaid", jobRepo.unpaid, jobRepo.selectedUnpaid),
              rowRepoSelected(
                  "paidCash", jobRepo.paidCash, jobRepo.selectedPaidCash),
              rowRepoSelected(
                  "paidGCash", jobRepo.paidGCash, jobRepo.selectedPaidGCash),
              rowRepoSelected("paidGCashVerified", jobRepo.paidGCashVerified,
                  jobRepo.selectedPaidGCashVerified),
              rowRepoSelected("paidCashAmount", jobRepo.paidCashAmount,
                  jobRepo.selectedPaidCashAmount),
              rowRepoSelected("paidGCashAmount", jobRepo.paidGCashAmount,
                  jobRepo.selectedPaidGCashAmount),
              rowRepoSelected("paymentReceivedBy", jobRepo.paymentReceivedBy,
                  jobRepo.selectedPaymentReceivedBy),
              section("Remarks"),
              rowRepoSelected(
                  "remarks", jobRepo.remarks, jobRepo.selectedRemarksVar.text),
              section("Items"),
              rowRepoOnly("items length", jobRepo.items.length),
              rowSelectedOnly(
                  "selectedItems length", jobRepo.selectedItems.length),
              section("Workflow"),
              rowRepoSelected("processStep", jobRepo.processStep,
                  jobRepo.selectedProcessStep),
              rowRepoSelected(
                  "allStatus", jobRepo.allStatus, jobRepo.selectedAllStatus),
              section("Disposal"),
              rowRepoSelected("forDisposal", jobRepo.forDisposal,
                  jobRepo.selectedForDisposal),
              rowRepoSelected(
                  "disposed", jobRepo.disposed, jobRepo.selectedDisposed),
              rowRepoOnly("isSyncToDB2", jobRepo.isSyncToDB2),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            jobRepo.syncSelectedToRepoAll(jobRepo);
            setState(() {});
          },
          child: const Text("Sync Selected → Repo"),
        ),
        TextButton(
          onPressed: () {
            jobRepo.syncRepoToSelectedAll(jobRepo);
            setState(() {});
          },
          child: const Text("Sync Repo → Selected"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    );
  }
}
