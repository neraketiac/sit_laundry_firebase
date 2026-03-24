import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/core/services/database_loyalty.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/features/pages/body/Loyalty/loyalty_single.dart';

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
    // Capture admin's explicit unpaid choice before sync overwrites it
    final adminUnpaid = jobRepo.selectedUnpaid;
    jobRepo.syncSelectedToRepoAll(jobRepo);
    // Restore admin override — syncSelectedToRepoAll recalculates unpaid from payment logic
    jobRepo.unpaid = adminUnpaid;
    jobRepo.selectedUnpaid = adminUnpaid;
    await callDatabaseUpdateJob(context, jobRepo.getJobsModel()!);
  }

  @override
  void initState() {
    super.initState();
    jobRepo = widget.jobRepo;
    jobRepo.syncRepoToSelectedAll(jobRepo);
    if (listOthItems.isEmpty) {
      addListOthItems();
    }
  }

  String formatValue(dynamic v) {
    if (v == null) return "-";
    if (v is Timestamp) return DateFormat('MMM dd yyyy').format(v.toDate());
    if (v is DateTime) return DateFormat('MMM dd yyyy').format(v);
    return v.toString();
  }

  Widget _buildFieldRow(String label, dynamic repo, dynamic selected) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(height: 6),
                _buildEditWidget(label, repo, selected),
              ],
            )
          : Row(
              children: [
                SizedBox(
                    width: 150,
                    child: Text(label,
                        style: const TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(formatValue(repo),
                        style: TextStyle(color: Colors.grey.shade700)),
                  ),
                ),
                Expanded(child: _buildEditWidget(label, repo, selected)),
              ],
            ),
    );
  }

  Widget _buildEditWidget(String label, dynamic repo, dynamic selected) {
    if (selected is bool) {
      return DropdownButton<bool>(
        isExpanded: true,
        value: selected,
        items: const [
          DropdownMenuItem(value: true, child: Text("Yes")),
          DropdownMenuItem(value: false, child: Text("No")),
        ],
        onChanged: (v) {
          if (v == null) return;
          setState(() => _updateField(label, v));
        },
      );
    }
    if (selected is TextEditingController) {
      return TextFormField(
        controller: selected,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        onChanged: (v) => setState(() => _updateField(label, v)),
      );
    }
    return TextFormField(
      initialValue: formatValue(selected),
      decoration: InputDecoration(
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      onChanged: (v) => setState(() => _updateField(label, v)),
    );
  }

  void _updateField(String label, dynamic value) {
    switch (label) {
      case "jobId":
        jobRepo.selectedJobId = int.tryParse(value.toString()) ?? 0;
      case "customerId":
        jobRepo.selectedCustomerId = int.tryParse(value.toString()) ?? 0;
      case "customerName":
        jobRepo.selectedCustomerNameVar.text = value;
      case "isCustomerPickedUp":
        jobRepo.selectedIsCustomerPickedUp = value;
      case "isDeliveredToCustomer":
        jobRepo.selectedIsDeliveredToCustomer = value;
      case "fold":
        jobRepo.selectedFold = value;
      case "mix":
        jobRepo.selectedMix = value;
      case "unpaid":
        jobRepo.selectedUnpaid = value;
      case "paidCash":
        jobRepo.selectedPaidCash = value;
      case "paidGCash":
        jobRepo.selectedPaidGCash = value;
      case "paidGCashVerified":
        jobRepo.selectedPaidGCashVerified = value;
      case "forDisposal":
        jobRepo.selectedForDisposal = value;
      case "disposed":
        jobRepo.selectedDisposed = value;
      case "paidCashAmount":
        jobRepo.selectedPaidCashAmount = int.tryParse(value.toString()) ?? 0;
      case "paidGCashAmount":
        jobRepo.selectedPaidGCashAmount = int.tryParse(value.toString()) ?? 0;
      case "remarks":
        jobRepo.selectedRemarksVar.text = value;
      case "perKilo":
        jobRepo.selectedPerKilo = value == "true";
      case "perLoad":
        jobRepo.selectedPerLoad = value == "true";
      case "finalKilo":
        jobRepo.selectedFinalKilo = double.tryParse(value.toString()) ?? 0;
      case "finalLoad":
        jobRepo.selectedFinalLoad = int.tryParse(value.toString()) ?? 0;
      case "finalPrice":
        jobRepo.selectedFinalPrice = int.tryParse(value.toString()) ?? 0;
      case "promoCounter":
        jobRepo.selectedPromoCounter = int.tryParse(value.toString()) ?? 0;
      case "basket":
        jobRepo.selectedBasket = int.tryParse(value.toString()) ?? 0;
      case "ebag":
        jobRepo.selectedEbag = int.tryParse(value.toString()) ?? 0;
      case "sako":
        jobRepo.selectedSako = int.tryParse(value.toString()) ?? 0;
      case "paymentReceivedBy":
        jobRepo.selectedPaymentReceivedBy = value;
      case "processStep":
        jobRepo.selectedProcessStep = value;
      case "allStatus":
        jobRepo.selectedAllStatus = double.tryParse(value.toString()) ?? 0;
      case "PromoErrorCode":
        jobRepo.selectedPromoErrorCode = int.tryParse(value.toString()) ?? 0;
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        backgroundColor: Colors.blue.shade50,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current Items:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 10),
              if (jobRepo.selectedItems.isEmpty)
                const Text('No items added',
                    style: TextStyle(color: Colors.grey, fontSize: 12))
              else
                ...jobRepo.selectedItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text('${item.itemName} (₱${item.itemPrice})',
                                style: const TextStyle(fontSize: 12))),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 18),
                          onPressed: () => setState(
                              () => jobRepo.selectedItems.removeAt(index)),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.blue.shade50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Items:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () =>
                        setState(() => jobRepo.selectedItems.clear()),
                    icon: const Icon(Icons.delete_sweep, size: 18),
                    label: const Text('Clear All'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Total: ₱${jobRepo.selectedItems.fold(0, (t, item) => t + item.itemPrice)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => jobRepo.selectedItems.add(promoFree)),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text(
                        '${promoFree.itemName} (₱${promoFree.itemPrice})',
                        style: const TextStyle(fontSize: 11)),
                  ),
                  ...listOthItems
                      .where((item) => item.itemId != promoFree.itemId)
                      .map((item) => ElevatedButton(
                            onPressed: () =>
                                setState(() => jobRepo.selectedItems.add(item)),
                            child: Text('${item.itemName} (₱${item.itemPrice})',
                                style: const TextStyle(fontSize: 11)),
                          )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromoErrorLegend() {
    const codes = [
      (0, '0 - No error, eligible, included in promo, paid'),
      (1, '1 - On review, partial eligible, unpaid'),
      (2, '2 - Not eligible: unpaid for 2+ weeks'),
      (3, '3 - Not eligible: last laundry not within 2 weeks'),
      (4, '4 - Promo ended (manually set)'),
      (5, '5 - Reset: previous eligible jobs now considered not eligible'),
      (99, '99 - Default, no status'),
    ];
    final current = jobRepo.selectedPromoErrorCode;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PromoErrorCode legend:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 6),
          ...codes.map((entry) {
            final isCurrent = entry.$1 == current;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text(
                entry.$2,
                style: TextStyle(
                  fontSize: 11,
                  color: isCurrent ? Colors.deepOrange : Colors.grey.shade700,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Dialog(
      insetPadding: EdgeInsets.all(isMobile ? 8 : 16),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Job Details", style: TextStyle(fontSize: 16)),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              jobRepo.syncRepoToSelectedAll(jobRepo);
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildSection("Identity", [
                _buildFieldRow("docId", jobRepo.docId, jobRepo.docId),
                _buildFieldRow("jobId", jobRepo.jobId, jobRepo.selectedJobId),
              ]),
              _buildSection("Dates", [
                _buildFieldRow("dateQ", jobRepo.dateQ, jobRepo.dateQ),
                _buildFieldRow("needOn", jobRepo.needOn, jobRepo.needOn),
                _buildFieldRow("dateO", jobRepo.dateO, jobRepo.dateO),
                _buildFieldRow("paidD", jobRepo.paidD, jobRepo.paidD),
                _buildFieldRow("dateD", jobRepo.dateD, jobRepo.dateD),
                _buildFieldRow("dateC", jobRepo.dateC, jobRepo.dateC),
              ]),
              _buildSection("Customer", [
                _buildFieldRow("customerId", jobRepo.customerId,
                    jobRepo.selectedCustomerId),
                _buildFieldRow("customerName", jobRepo.customerName,
                    jobRepo.selectedCustomerNameVar.text),
                _buildFieldRow("isCustomerPickedUp", jobRepo.isCustomerPickedUp,
                    jobRepo.selectedIsCustomerPickedUp),
                _buildFieldRow(
                    "isDeliveredToCustomer",
                    jobRepo.isDeliveredToCustomer,
                    jobRepo.selectedIsDeliveredToCustomer),
              ]),
              _buildSection("Pricing", [
                _buildFieldRow(
                    "perKilo", jobRepo.perKilo, jobRepo.selectedPerKilo),
                _buildFieldRow(
                    "perLoad", jobRepo.perLoad, jobRepo.selectedPerLoad),
                _buildFieldRow(
                    "finalKilo", jobRepo.finalKilo, jobRepo.selectedFinalKilo),
                _buildFieldRow(
                    "finalLoad", jobRepo.finalLoad, jobRepo.selectedFinalLoad),
                _buildFieldRow("finalPrice", jobRepo.finalPrice,
                    jobRepo.selectedFinalPrice),
                _buildFieldRow("promoCounter", jobRepo.promoCounter,
                    jobRepo.selectedPromoCounter),
                _buildFieldRow("PromoErrorCode", jobRepo.promoErrorCode,
                    jobRepo.selectedPromoErrorCode),
                _buildPromoErrorLegend(),
              ]),
              _buildSection("Options", [
                _buildFieldRow("fold", jobRepo.fold, jobRepo.selectedFold),
                _buildFieldRow("mix", jobRepo.mix, jobRepo.selectedMix),
              ]),
              _buildSection("Containers", [
                _buildFieldRow(
                    "basket", jobRepo.basket, jobRepo.selectedBasket),
                _buildFieldRow("ebag", jobRepo.ebag, jobRepo.selectedEbag),
                _buildFieldRow("sako", jobRepo.sako, jobRepo.selectedSako),
              ]),
              _buildSection("Payment", [
                _buildFieldRow(
                    "unpaid", jobRepo.unpaid, jobRepo.selectedUnpaid),
                _buildFieldRow(
                    "paidCash", jobRepo.paidCash, jobRepo.selectedPaidCash),
                _buildFieldRow(
                    "paidGCash", jobRepo.paidGCash, jobRepo.selectedPaidGCash),
                _buildFieldRow("paidGCashVerified", jobRepo.paidGCashVerified,
                    jobRepo.selectedPaidGCashVerified),
                _buildFieldRow("paidCashAmount", jobRepo.paidCashAmount,
                    jobRepo.repoVarCashAmountVar),
                _buildFieldRow("paidGCashAmount", jobRepo.paidGCashAmount,
                    jobRepo.repoVarGCashAmountVar),
                _buildFieldRow("paymentReceivedBy", jobRepo.paymentReceivedBy,
                    jobRepo.selectedPaymentReceivedBy),
              ]),
              _buildSection("Remarks", [
                _buildFieldRow(
                    "remarks", jobRepo.remarks, jobRepo.selectedRemarksVar),
              ]),
              _buildSection("Items", [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(
                          width: 150,
                          child: Text("Items Count",
                              style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(
                          child: Text("${jobRepo.items.length}",
                              style: TextStyle(color: Colors.grey.shade700))),
                      Expanded(
                          child: Text("${jobRepo.selectedItems.length}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildItemsEditor(),
              ]),
              _buildSection("Workflow", [
                _buildFieldRow("processStep", jobRepo.processStep,
                    jobRepo.selectedProcessStep),
                _buildFieldRow(
                    "allStatus", jobRepo.allStatus, jobRepo.selectedAllStatus),
              ]),
              _buildSection("Disposal", [
                _buildFieldRow("forDisposal", jobRepo.forDisposal,
                    jobRepo.selectedForDisposal),
                _buildFieldRow(
                    "disposed", jobRepo.disposed, jobRepo.selectedDisposed),
              ]),
              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    jobRepo.syncRepoToSelectedAll(jobRepo);
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 8),
              if (jobRepo.processStep == '')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete Job"),
                          content: const Text(
                              "Are you sure? This cannot be undone."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Delete",
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        await FirebaseFirestore.instance
                            .collection('Jobs_queue')
                            .doc(jobRepo.docId)
                            .delete();
                        final hasPromoFree = jobRepo.items.any((item) =>
                            item.itemUniqueId == promoFree.itemUniqueId);
                        if (hasPromoFree) {
                          DatabaseLoyalty()
                              .addCountByCardNumber(jobRepo.customerId, 10);
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Job deleted: ${jobRepo.customerName}")),
                          );
                        }
                      }
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (jobRepo.selectedCustomerId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select customer name.')),
                      );
                      return;
                    }
                    await saveButtonSetRepository();
                    if (context.mounted) Navigator.pop(context);
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child:
                      const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
