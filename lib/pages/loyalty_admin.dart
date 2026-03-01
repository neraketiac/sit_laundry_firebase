import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/models/newmodels/loyaltymodel.dart';
import 'package:laundry_firebase/services/newservices/database_loyalty.dart';

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "LOYALTY ADMIN",
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
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
                _buildHeader(name, docId),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone, contact),
                _buildInfoRow(Icons.location_on, address),
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

  Widget _buildHeader(String name, String docId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.cyanAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            "#$docId",
            style: const TextStyle(
              color: Colors.cyanAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A38),
        title: const Text("Create Loyalty Member",
            style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              Text("Card #: $_nextId",
                  style: const TextStyle(color: Colors.cyanAccent)),
              const SizedBox(height: 10),
              _buildTextField(_nameController, "Name"),
              _buildTextField(_contactController, "Contact"),
              _buildTextField(_addressController, "Address"),
              _buildTextField(_remarksController, "Remarks"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              await _createCustomer();
              Navigator.pop(context);
            },
            child:
                const Text("Save", style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
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

    DatabaseLoyalty().addCustomerWithId(
      LoyaltyModel(
        name: _nameController.text.trim(),
        contact: _contactController.text.trim(),
        address: _addressController.text.trim(),
        remarks: _remarksController.text.trim(),
        count: 0,
        cardNumber: int.tryParse(id) ?? 0,
        logDate: Timestamp.now(),
      ),
      id,
    );

    _nameController.clear();
    _contactController.clear();
    _addressController.clear();
    _remarksController.clear();
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
