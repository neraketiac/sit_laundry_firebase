import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/customers/models/customermodel.dart';
import 'package:laundry_firebase/features/customers/repository/customer_repository.dart';
import 'package:laundry_firebase/features/loyalty/models/loyaltymodel.dart';
import 'package:laundry_firebase/core/services/database_loyalty.dart';

class LoyaltyAdmin extends StatefulWidget {
  const LoyaltyAdmin({super.key});

  @override
  State<LoyaltyAdmin> createState() => _LoyaltyAdminState();
}

class _LoyaltyAdminState extends State<LoyaltyAdmin> {
  // ================= VARIABLES =================

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _docIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  int _nextId = 1000;

  // ================= LIFECYCLE =================

  @override
  void dispose() {
    _docIdController.dispose();
    _nameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        title: const Text(
          "LOYALTY ADMIN",
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: SafeArea(
          child: _buildLoyaltyStream(),
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  // ================= STREAM =================

  Widget _buildLoyaltyStream() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore.collection('loyalty').orderBy('cardNumber').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
              child: Text("Something went wrong",
                  style: TextStyle(color: Colors.white)));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
              child: Text("No loyalty members yet",
                  style: TextStyle(color: Colors.white)));
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return _buildCustomerCard(
              docId: doc.id,
              name: data['Name'] ?? '',
              contact: data['Contact'] ?? '',
              address: data['Address'] ?? '',
              remarks: data['C5_Remarks'] ?? '',
              count: data['Count'] ?? 0,
              cardNumber: data['cardNumber'] ?? 0,
            );
          }).toList(),
        );
      },
    );
  }

  // ================= FLOATING BUTTON =================

  Widget _buildFloatingButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _openCreateDialog,
        child: const Icon(Icons.add, color: Colors.cyanAccent),
      ),
    );
  }

  // ================= CUSTOMER CARD =================

  Widget _buildCustomerCard({
    required String docId,
    required String name,
    required String contact,
    required String address,
    required String remarks,
    required int count,
    required int cardNumber,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.02),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(name, cardNumber),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone, contact),
                _buildInfoRow(Icons.location_on, address),
                if (remarks.isNotEmpty) _buildInfoRow(Icons.notes, remarks),
                const SizedBox(height: 20),
                _buildStarButtons(
                    docId, name, contact, address, remarks, count),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name, int cardNumber) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.cyanAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            '#$cardNumber',
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  // ================= STARS =================

  Widget _buildStarButtons(
    String docId,
    String name,
    String contact,
    String address,
    String remarks,
    int count,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(10, (index) {
        final starNumber = index + 1;
        final isActive = count >= starNumber;

        return GestureDetector(
          onTap: () => _confirmUpdate(
              docId, name, contact, address, remarks, starNumber),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Colors.cyanAccent.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              isActive ? Icons.star : Icons.star_border,
              color: isActive ? Colors.cyanAccent : Colors.white38,
            ),
          ),
        );
      }),
    );
  }

  // ================= CREATE =================

  Future<void> _openCreateDialog() async {
    await _generateNextId();
    _docIdController.text = _nextId.toString();
    _nameController.clear();
    _contactController.clear();
    _addressController.clear();
    _remarksController.clear();

    // Edit mode state — null = creating new, non-null = editing existing
    String? editDocId;
    int? editCardNumber;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isEditMode = editDocId != null;
          final query = _nameController.text.trim().toLowerCase();
          final duplicates = (!isEditMode && query.isNotEmpty)
              ? CustomerRepository.instance.customers
                  .where((c) => c.name.toLowerCase().contains(query))
                  .take(5)
                  .toList()
              : <CustomerModel>[];
          final hasDuplicate = duplicates.isNotEmpty;

          Future<void> loadExisting(CustomerModel c) async {
            // Fetch full loyalty doc to get all fields
            final snap = await _firestore
                .collection('loyalty')
                .where('cardNumber', isEqualTo: c.customerId)
                .limit(1)
                .get();
            if (snap.docs.isEmpty) return;
            final doc = snap.docs.first;
            final data = doc.data();
            setDialogState(() {
              editDocId = doc.id;
              editCardNumber = c.customerId;
              _nameController.text = data['Name'] ?? c.name;
              _contactController.text = data['Contact'] ?? c.contact;
              _addressController.text = data['Address'] ?? c.address;
              _remarksController.text = data['C5_Remarks'] ?? c.remarks;
            });
          }

          return AlertDialog(
            backgroundColor: const Color(0xFF1E2A38),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    isEditMode
                        ? 'Edit Loyalty Member'
                        : 'Create Loyalty Member',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (isEditMode)
                  // Show card number badge + clear button
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.cyanAccent.withOpacity(0.3)),
                        ),
                        child: Text(
                          '#$editCardNumber',
                          style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setDialogState(() {
                          editDocId = null;
                          editCardNumber = null;
                          _nameController.clear();
                          _contactController.clear();
                          _addressController.clear();
                          _remarksController.clear();
                        }),
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.white38),
                      ),
                    ],
                  )
                else
                  Text(
                    'Card #: $_nextId',
                    style:
                        const TextStyle(color: Colors.cyanAccent, fontSize: 12),
                  ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name field
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      suffixIcon: hasDuplicate
                          ? const Icon(Icons.warning_amber,
                              color: Colors.orange, size: 18)
                          : null,
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  // Tappable duplicate suggestions
                  if (hasDuplicate) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tap to edit existing:',
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          ...duplicates.map((c) => InkWell(
                                onTap: () => loadExisting(c),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit,
                                          size: 12, color: Colors.cyanAccent),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${c.name} (#${c.customerId}) — ${c.address}',
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  _buildTextField(_contactController, 'Contact'),
                  _buildTextField(_addressController, 'Address'),
                  _buildTextField(_remarksController, 'Remarks'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white70)),
              ),
              TextButton(
                onPressed: () async {
                  if (isEditMode) {
                    await _updateCustomer(
                      docId: editDocId!,
                      cardNumber: editCardNumber!,
                      name: _nameController.text.trim(),
                      contact: _contactController.text.trim(),
                      address: _addressController.text.trim(),
                      remarks: _remarksController.text.trim(),
                      // count unchanged — only editable via stars
                      count: (await _firestore
                                  .collection('loyalty')
                                  .doc(editDocId)
                                  .get())
                              .data()?['Count'] ??
                          0,
                    );
                  } else {
                    await _createCustomer();
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(
                  isEditMode ? 'Update' : 'Save',
                  style: const TextStyle(color: Colors.cyanAccent),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
        ),
      ),
    );
  }

  Future<void> _generateNextId() async {
    final snapshot = await _firestore
        .collection('loyalty')
        .orderBy('cardNumber', descending: true)
        .limit(1)
        .get();

    final maxNumber = snapshot.docs.isNotEmpty
        ? snapshot.docs.first['cardNumber'] as int
        : 1000;

    _nextId = maxNumber + (Random().nextInt(90) + 10);
  }

  Future<void> _createCustomer() async {
    final id = _docIdController.text;
    final cardNumber = int.tryParse(id) ?? 0;
    final name = _nameController.text.trim();
    final contact = _contactController.text.trim();
    final address = _addressController.text.trim();
    final remarks = _remarksController.text.trim();

    DatabaseLoyalty().addCustomerWithId(
      LoyaltyModel(
        name: name,
        contact: contact,
        address: address,
        remarks: remarks,
        count: 0,
        cardNumber: cardNumber,
        logDate: Timestamp.now(),
      ),
      id,
    );

    // Add to in-memory list immediately — no extra Firestore read needed
    CustomerRepository.instance.customers.add(CustomerModel(
      customerId: cardNumber,
      name: name,
      address: address,
      contact: contact,
      remarks: remarks,
      loyaltyCount: 0,
    ));

    _nameController.clear();
    _contactController.clear();
    _addressController.clear();
    _remarksController.clear();
  }

  Future<void> _updateCustomer({
    required String docId,
    required int cardNumber,
    required String name,
    required String contact,
    required String address,
    required String remarks,
    required int count,
  }) async {
    // 1. Update loyalty record
    await _firestore.collection('loyalty').doc(docId).update({
      'Name': name,
      'Contact': contact,
      'Address': address,
      'C5_Remarks': remarks,
      'Count': count,
      // cardNumber is intentionally NOT updated — it's the key identifier
    });
    await bumpLoyaltyVersion();

    // 2. Sync customer name in Jobs_queue and Jobs_ongoing
    for (final collection in ['Jobs_queue', 'Jobs_ongoing']) {
      final snap = await _firestore
          .collection(collection)
          .where('C00_CustomerId', isEqualTo: cardNumber)
          .get();
      if (snap.docs.isEmpty) continue;
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'C01_CustomerName': name});
      }
      await batch.commit();
    }

    // 3. Sync in-memory customer list
    final repo = CustomerRepository.instance;
    final idx = repo.customers.indexWhere((c) => c.customerId == cardNumber);
    if (idx != -1) {
      repo.customers[idx] = CustomerModel(
        customerId: cardNumber,
        name: name,
        address: address,
        contact: contact,
        remarks: remarks,
        loyaltyCount: count,
      );
    }
  }

  // ================= UPDATE =================

  void _confirmUpdate(
    String docId,
    String name,
    String contact,
    String address,
    String remarks,
    int count,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A38),
        title:
            const Text("Update Stars", style: TextStyle(color: Colors.white)),
        content: Text(
          "Update $name to $count stars?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              await _updateStars(docId, count);
              Navigator.pop(context);
            },
            child: const Text("Confirm",
                style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStars(String docId, int count) async {
    await _firestore.collection('loyalty').doc(docId).update({'Count': count});
  }
}
