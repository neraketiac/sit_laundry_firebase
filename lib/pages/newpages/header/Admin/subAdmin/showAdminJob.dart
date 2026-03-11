import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedMethods.dart';
import 'package:laundry_firebase/pages/newpages/sharedmethods/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/services/newservices/database_loyalty.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

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

  Future<void> saveButtonSetRepository() async {
    jobRepo.currentEmpId = empIdGlobal;
    jobRepo.syncSelectedToRepoAll(jobRepo);
    await callDatabaseUpdateJob(context, jobRepo.getJobsModel()!);
    //await setRepositoryLaundryPayment(context, 'Show Jobs OnQueue');
  }

  @override
  void initState() {
    super.initState();
    jobRepo = widget.jobRepo;
    jobRepo.syncRepoToSelectedAll(jobRepo);
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        color: Colors.grey.shade300,
        child: Row(
          children: [
            SizedBox(width: 200, child: Text(label)),

            /// Repo column
            Expanded(
                child: Text(
              formatValue(repo),
              textAlign: TextAlign.center,
            )),

            const SizedBox(width: 20),

            /// Selected column
            Expanded(
              child: selected is bool
                  ? DropdownButton<bool>(
                      alignment: Alignment.center,
                      value: selected,
                      items: const [
                        DropdownMenuItem(value: true, child: Text("true")),
                        DropdownMenuItem(value: false, child: Text("false")),
                      ],
                      onChanged: (v) {
                        if (v == null) return;

                        setState(() {
                          switch (label) {
                            case "isCustomerPickedUp":
                              jobRepo.selectedIsCustomerPickedUp = v;
                              break;

                            case "isDeliveredToCustomer":
                              jobRepo.selectedIsDeliveredToCustomer = v;
                              break;

                            case "fold":
                              jobRepo.selectedFold = v;
                              break;

                            case "mix":
                              jobRepo.selectedMix = v;
                              break;

                            case "unpaid":
                              jobRepo.selectedUnpaid = v;
                              break;

                            case "paidCash":
                              jobRepo.selectedPaidCash = v;
                              break;

                            case "paidGCash":
                              jobRepo.selectedPaidGCash = v;
                              break;

                            case "paidGCashVerified":
                              jobRepo.selectedPaidGCashVerified = v;
                              break;

                            case "forDisposal":
                              jobRepo.selectedForDisposal = v;
                              break;

                            case "disposed":
                              jobRepo.selectedDisposed = v;
                              break;

                            case "isPromoCounter":
                              jobRepo.selectedIsPromoCounter = v;
                              break;
                          }
                        });
                      },
                    )
                  : selected is TextEditingController
                      ? TextFormField(
                          controller: selected,
                          textAlign: TextAlign.center,
                          onChanged: (v) {
                            setState(() {
                              switch (label) {
                                case "paidCashAmount":
                                  jobRepo.selectedPaidCashAmount =
                                      int.tryParse(v) ?? 0;
                                  break;

                                case "paidGCashAmount":
                                  jobRepo.selectedPaidGCashAmount =
                                      int.tryParse(v) ?? 0;
                                  break;

                                case "remarks":
                                  jobRepo.selectedRemarksVar.text = v;
                                  break;
                              }
                            });
                          },
                        )
                      : TextFormField(
                          textAlign: TextAlign.center,
                          initialValue: (formatValue(selected)),
                          onChanged: (v) {
                            setState(() {
                              switch (label) {
                                case "jobId":
                                  jobRepo.selectedJobId = int.tryParse(v) ?? 0;
                                  break;

                                case "customerId":
                                  jobRepo.selectedCustomerId =
                                      int.tryParse(v) ?? 0;
                                  break;

                                case "customerName":
                                  jobRepo.selectedCustomerNameVar.text = v;
                                  break;

                                case "perKilo":
                                  jobRepo.selectedPerKilo = v == "true";
                                  break;

                                case "perLoad":
                                  jobRepo.selectedPerLoad = v == "true";
                                  break;

                                case "finalKilo":
                                  jobRepo.selectedFinalKilo =
                                      double.tryParse(v) ?? 0;
                                  break;

                                case "finalLoad":
                                  jobRepo.selectedFinalLoad =
                                      int.tryParse(v) ?? 0;
                                  break;

                                case "finalPrice":
                                  jobRepo.selectedFinalPrice =
                                      int.tryParse(v) ?? 0;
                                  break;

                                case "promoCounter":
                                  jobRepo.selectedPromoCounter =
                                      int.tryParse(v) ?? 0;
                                  break;

                                case "basket":
                                  jobRepo.selectedBasket = int.tryParse(v) ?? 0;
                                  break;

                                case "ebag":
                                  jobRepo.selectedEbag = int.tryParse(v) ?? 0;
                                  break;

                                case "sako":
                                  jobRepo.selectedSako = int.tryParse(v) ?? 0;
                                  break;

                                case "paymentReceivedBy":
                                  jobRepo.selectedPaymentReceivedBy = v;
                                  break;

                                case "processStep":
                                  jobRepo.selectedProcessStep = v;
                                  break;

                                case "allStatus":
                                  jobRepo.selectedAllStatus =
                                      double.tryParse(v) ?? 0;
                                  break;
                              }
                            });
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rowRepoOnly(String label, dynamic repo) {
    bool isDate = repo is Timestamp || repo is DateTime;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        color: Colors.grey.shade300,
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
                      child: Text(
                        formatValue(repo),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Text(
                      formatValue(repo),
                      textAlign: TextAlign.center,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rowSelectedOnly(String label, dynamic selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        color: Colors.grey.shade300,
        child: Row(
          children: [
            SizedBox(width: 200, child: Text(label)),
            Expanded(
                child: Text(
              formatValue(selected),
              textAlign: TextAlign.center,
            )),
          ],
        ),
      ),
    );
  }

  Widget section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        color: Colors.green.shade300,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Admin JobRepo Debug"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 600,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 700,
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
                  rowRepoSelected(
                      "jobId", jobRepo.jobId, jobRepo.selectedJobId),
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
                  rowRepoSelected("customerId", jobRepo.customerId,
                      jobRepo.selectedCustomerId),
                  rowRepoSelected("customerName", jobRepo.customerName,
                      jobRepo.selectedCustomerNameVar.text),
                  rowRepoOnly("forSorting", jobRepo.forSorting),
                  rowRepoOnly("riderPickup", jobRepo.riderPickup),
                  rowRepoSelected(
                      "isCustomerPickedUp",
                      jobRepo.isCustomerPickedUp,
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
                  rowRepoSelected("finalKilo", jobRepo.finalKilo,
                      jobRepo.selectedFinalKilo),
                  rowRepoSelected("finalLoad", jobRepo.finalLoad,
                      jobRepo.selectedFinalLoad),
                  rowRepoSelected("finalPrice", jobRepo.finalPrice,
                      jobRepo.selectedFinalPrice),
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
                  rowRepoSelected(
                      "basket", jobRepo.basket, jobRepo.selectedBasket),
                  rowRepoSelected("ebag", jobRepo.ebag, jobRepo.selectedEbag),
                  rowRepoSelected("sako", jobRepo.sako, jobRepo.selectedSako),
                  section("Payment"),
                  rowRepoSelected(
                      "unpaid", jobRepo.unpaid, jobRepo.selectedUnpaid),
                  rowRepoSelected(
                      "paidCash", jobRepo.paidCash, jobRepo.selectedPaidCash),
                  rowRepoSelected("paidGCash", jobRepo.paidGCash,
                      jobRepo.selectedPaidGCash),
                  rowRepoSelected(
                      "paidGCashVerified",
                      jobRepo.paidGCashVerified,
                      jobRepo.selectedPaidGCashVerified),
                  rowRepoSelected("paidCashAmount", jobRepo.paidCashAmount,
                      jobRepo.repoVarCashAmountVar),
                  rowRepoSelected("paidGCashAmount", jobRepo.paidGCashAmount,
                      jobRepo.repoVarGCashAmountVar),
                  rowRepoSelected(
                      "paymentReceivedBy",
                      jobRepo.paymentReceivedBy,
                      jobRepo.selectedPaymentReceivedBy),
                  section("Remarks"),
                  rowRepoSelected(
                      "remarks", jobRepo.remarks, jobRepo.selectedRemarksVar),
                  section("Items"),
                  rowRepoOnly("items length", jobRepo.items.length),
                  rowSelectedOnly(
                      "selectedItems length", jobRepo.selectedItems.length),
                  section("Workflow"),
                  rowRepoSelected("processStep", jobRepo.processStep,
                      jobRepo.selectedProcessStep),
                  rowRepoSelected("allStatus", jobRepo.allStatus,
                      jobRepo.selectedAllStatus),
                  section("Disposal"),
                  rowRepoSelected("forDisposal", jobRepo.forDisposal,
                      jobRepo.selectedForDisposal),
                  rowRepoSelected(
                      "disposed", jobRepo.disposed, jobRepo.selectedDisposed),
                  rowRepoOnly("isSyncToDB2", jobRepo.isSyncToDB2),
                  rowRepoSelected("isPromoCounter", jobRepo.isPromoCounter,
                      jobRepo.selectedIsPromoCounter),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              syncRepoToSelectedALL(jobRepo);
            });
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black),
          ),
        ),
        //only jobs on queue can be deleted
        if (jobRepo.processStep == '')
          TextButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Delete Job"),
                    content: Text(
                        "Are you sure you want to delete this job? This cannot be undone."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await FirebaseFirestore.instance
                    .collection('Jobs_queue') // change if needed
                    .doc(jobRepo.docId)
                    .delete();

                DatabaseLoyalty loyalty = DatabaseLoyalty();
                loyalty.addCountByCardNumber(jobRepo.customerId, 10);

                Navigator.pop(context); // close AdminJobRepoViewer

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          "Job deleted successfully ${jobRepo.customerName}")),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        boxButtonElevated(
          context: context,
          label: 'Save',
          onPressed: () async {
            if (jobRepo.selectedCustomerId == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select customer name.')),
              );
              return false;
            } else {
              await saveButtonSetRepository();
              return true;
            }
          },
        ),
      ],
    );
  }
}
