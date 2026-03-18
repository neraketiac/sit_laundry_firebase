import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/global/variables_oth.dart';
import 'package:laundry_firebase/core/utils/sharedMethods.dart';
import 'package:laundry_firebase/core/utils/sharedmethodsdatabase.dart';
import 'package:laundry_firebase/core/services/database_loyalty.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';

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
  int _expandedSection = 0;

  Future<void> saveButtonSetRepository() async {
    jobRepo.currentEmpId = empIdGlobal;
    jobRepo.syncSelectedToRepoAll(jobRepo);
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
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(height: 6),
                _buildEditWidget(label, repo, selected),
              ],
            )
          : Row(
              children: [
                SizedBox(width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(formatValue(repo), style: TextStyle(color: Colors.grey.shade700)),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        onChanged: (v) {
          setState(() => _updateField(label, v));
        },
      );
    }
    
    return TextFormField(
      initialValue: formatValue(selected),
      decoration: InputDecoration(
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      onChanged: (v) {
        setState(() => _updateField(label, v));
      },
    );
  }

  void _updateField(String label, dynamic value) {
    switch (label) {
      case "jobId":
        jobRepo.selectedJobId = int.tryParse(value.toString()) ?? 0;
        break;
      case "customerId":
        jobRepo.selectedCustomerId = int.tryParse(value.toString()) ?? 0;
        break;
      case "customerName":
        jobRepo.selectedCustomerNameVar.text = value;
        break;
      case "isCustomerPickedUp":
        jobRepo.selectedIsCustomerPickedUp = value;
        break;
      case "isDeliveredToCustomer":
        jobRepo.selectedIsDeliveredToCustomer = value;
        break;
      case "fold":
        jobRepo.selectedFold = value;
        break;
      case "mix":
        jobRepo.selectedMix = value;
        break;
      case "unpaid":
        jobRepo.selectedUnpaid = value;
        break;
      case "paidCash":
        jobRepo.selectedPaidCash = value;
        break;
      case "paidGCash":
        jobRepo.selectedPaidGCash = value;
        break;
      case "paidGCashVerified":
        jobRepo.selectedPaidGCashVerified = value;
        break;
      case "forDisposal":
        jobRepo.selectedForDisposal = value;
        break;
      case "disposed":
        jobRepo.selectedDisposed = value;
        break;
      case "paidCashAmount":
        jobRepo.selectedPaidCashAmount = int.tryParse(value.toString()) ?? 0;
        break;
      case "paidGCashAmount":
        jobRepo.selectedPaidGCashAmount = int.tryParse(value.toString()) ?? 0;
        break;
      case "remarks":
        jobRepo.selectedRemarksVar.text = value;
        break;
      case "perKilo":
        jobRepo.selectedPerKilo = value == "true";
        break;
      case "perLoad":
        jobRepo.selectedPerLoad = value == "true";
        break;
      case "finalKilo":
        jobRepo.selectedFinalKilo = double.tryParse(value.toString()) ?? 0;
        break;
      case "finalLoad":
        jobRepo.selectedFinalLoad = int.tryParse(value.toString()) ?? 0;
        break;
      case "finalPrice":
        jobRepo.selectedFinalPrice = int.tryParse(value.toString()) ?? 0;
        break;
      case "promoCounter":
        jobRepo.selectedPromoCounter = int.tryParse(value.toString()) ?? 0;
        break;
      case "basket":
        jobRepo.selectedBasket = int.tryParse(value.toString()) ?? 0;
        break;
      case "ebag":
        jobRepo.selectedEbag = int.tryParse(value.toString()) ?? 0;
        break;
      case "sako":
        jobRepo.selectedSako = int.tryParse(value.toString()) ?? 0;
        break;
      case "paymentReceivedBy":
        jobRepo.selectedPaymentReceivedBy = value;
        break;
      case "processStep":
        jobRepo.selectedProcessStep = value;
        break;
      case "allStatus":
        jobRepo.selectedAllStatus = double.tryParse(value.toString()) ?? 0;
        break;
      case "PromoErrorCode":
        jobRepo.selectedPromoErrorCode = int.tryParse(value.toString()) ?? 0;
        break;
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              const Text('Current Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 10),
              if (jobRepo.selectedItems.isEmpty)
                const Text('No items added', style: TextStyle(color: Colors.grey, fontSize: 12))
              else
                ...jobRepo.selectedItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;
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
                        Expanded(child: Text('${item.itemName} (₱${item.itemPrice})', style: const TextStyle(fontSize: 12))),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                          onPressed: () {
                            setState(() => jobRepo.selectedItems.removeAt(index));
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
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
              const Text('Add Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => jobRepo.selectedItems.clear());
                    },
                    icon: const Icon(Icons.delete_sweep, size: 18),
                    label: const Text('Clear All'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                  const SizedBox(width: 10),
                  Text('Total: ₱${jobRepo.selectedItems.fold(0, (sum, item) => sum + item.itemPrice)}', 
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() => jobRepo.selectedItems.add(promoFree));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text('${promoFree.itemName} (₱${promoFree.itemPrice})', style: const TextStyle(fontSize: 11)),
                  ),
                  ...listOthItems
                      .where((item) => item.itemId != promoFree.itemId)
                      .map((item) {
                    return ElevatedButton(
                      onPressed: () {
                        setState(() => jobRepo.selectedItems.add(item));
                      },
                      child: Text('${item.itemName} (₱${item.itemPrice})', style: const TextStyle(fontSize: 11)),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ],
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
                _buildFieldRow("customerId", jobRepo.customerId, jobRepo.selectedCustomerId),
                _buildFieldRow("customerName", jobRepo.customerName, jobRepo.selectedCustomerNameVar.text),
                _buildFieldRow("isCustomerPickedUp", jobRepo.isCustomerPickedUp, jobRepo.selectedIsCustomerPickedUp),
                _buildFieldRow("isDeliveredToCustomer", jobRepo.isDeliveredToCustomer, jobRepo.selectedIsDeliveredToCustomer),
              ]),
              _buildSection("Pricing", [
                _buildFieldRow("perKilo", jobRepo.perKilo, jobRepo.selectedPerKilo),
                _buildFieldRow("perLoad", jobRepo.perLoad, jobRepo.selectedPerLoad),
                _buildFieldRow("finalKilo", jobRepo.finalKilo, jobRepo.selectedFinalKilo),
                _buildFieldRow("finalLoad", jobRepo.finalLoad, jobRepo.selectedFinalLoad),
                _buildFieldRow("finalPrice", jobRepo.finalPrice, jobRepo.selectedFinalPrice),
                _buildFieldRow("promoCounter", jobRepo.promoCounter, jobRepo.selectedPromoCounter),
              ]),
              _buildSection("Options", [
                _buildFieldRow("fold", jobRepo.fold, jobRepo.selectedFold),
                _buildFieldRow("mix", jobRepo.mix, jobRepo.selectedMix),
              ]),
              _buildSection("Containers", [
                _buildFieldRow("basket", jobRepo.basket, jobRepo.selectedBasket),
                _buildFieldRow("ebag", jobRepo.ebag, jobRepo.selectedEbag),
                _buildFieldRow("sako", jobRepo.sako, jobRepo.selectedSako),
              ]),
              _buildSection("Payment", [
                _buildFieldRow("unpaid", jobRepo.unpaid, jobRepo.selectedUnpaid),
                _buildFieldRow("paidCash", jobRepo.paidCash, jobRepo.selectedPaidCash),
                _buildFieldRow("paidGCash", jobRepo.paidGCash, jobRepo.selectedPaidGCash),
                _buildFieldRow("paidGCashVerified", jobRepo.paidGCashVerified, jobRepo.selectedPaidGCashVerified),
                _buildFieldRow("paidCashAmount", jobRepo.paidCashAmount, jobRepo.repoVarCashAmountVar),
                _buildFieldRow("paidGCashAmount", jobRepo.paidGCashAmount, jobRepo.repoVarGCashAmountVar),
                _buildFieldRow("paymentReceivedBy", jobRepo.paymentReceivedBy, jobRepo.selectedPaymentReceivedBy),
              ]),
              _buildSection("Remarks", [
                _buildFieldRow("remarks", jobRepo.remarks, jobRepo.selectedRemarksVar),
              ]),
              _buildSection("Items", [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 150, child: Text("Items Count", style: TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(child: Text("${jobRepo.items.length}", style: TextStyle(color: Colors.grey.shade700))),
                      Expanded(child: Text("${jobRepo.selectedItems.length}", style: const TextStyle(fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildItemsEditor(),
              ]),
              _buildSection("Workflow", [
                _buildFieldRow("processStep", jobRepo.processStep, jobRepo.selectedProcessStep),
                _buildFieldRow("allStatus", jobRepo.allStatus, jobRepo.selectedAllStatus),
              ]),
              _buildSection("Disposal", [
                _buildFieldRow("forDisposal", jobRepo.forDisposal, jobRepo.selectedForDisposal),
                _buildFieldRow("disposed", jobRepo.disposed, jobRepo.selectedDisposed),
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
                        builder: (context) => AlertDialog(
                          title: const Text("Delete Job"),
                          content: const Text("Are you sure? This cannot be undone."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await FirebaseFirestore.instance
                            .collection('Jobs_queue')
                            .doc(jobRepo.docId)
                            .delete();

                        bool hasPromoFree = jobRepo.items
                            .any((item) => item.itemUniqueId == promoFree.itemUniqueId);

                        if (hasPromoFree) {
                          DatabaseLoyalty loyalty = DatabaseLoyalty();
                          loyalty.addCountByCardNumber(jobRepo.customerId, 10);
                        }

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Job deleted: ${jobRepo.customerName}")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Delete', style: TextStyle(color: Colors.white)),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (jobRepo.selectedCustomerId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select customer name.')),
                      );
                      return;
                    }
                    await saveButtonSetRepository();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
