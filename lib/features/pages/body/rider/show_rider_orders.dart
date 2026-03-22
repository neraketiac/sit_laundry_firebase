import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';
import 'loyalty_order_online_model.dart';

/// Standalone page (with Scaffold) — use when navigating directly
class ShowRiderOrdersPage extends StatelessWidget {
  const ShowRiderOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Rider Pickup Orders'), centerTitle: true),
      body: const ShowRiderOrders(),
    );
  }
}

/// Embeddable widget — use inside animatedPanel or any layout
class ShowRiderOrders extends StatefulWidget {
  const ShowRiderOrders({super.key});

  @override
  State<ShowRiderOrders> createState() => _ShowRiderOrdersState();
}

class _ShowRiderOrdersState extends State<ShowRiderOrders> {
  final _col =
      FirebaseService.forthFirestore.collection('loyalty_order_online');

  // Filter state
  PickupStatus? _filterStatus; // null = all
  DateTime? _filterDate;

  Stream<QuerySnapshot> get _stream {
    Query q = _col.orderBy('scheduleDate', descending: false);
    return q.snapshots();
  }

  List<LoyaltyOrderOnlineModel> _applyFilters(List<DocumentSnapshot> docs) {
    var list =
        docs.map((d) => LoyaltyOrderOnlineModel.fromFirestore(d)).toList();

    if (_filterStatus != null) {
      list = list.where((o) => o.pickupStatus == _filterStatus).toList();
    }
    if (_filterDate != null) {
      list = list
          .where((o) =>
              o.scheduleDate.year == _filterDate!.year &&
              o.scheduleDate.month == _filterDate!.month &&
              o.scheduleDate.day == _filterDate!.day)
          .toList();
    }
    return list;
  }

  Future<void> _updateStatus(
      LoyaltyOrderOnlineModel order, PickupStatus newStatus) async {
    await _col.doc(order.docId).update({'pickupStatus': newStatus.value});
  }

  Future<void> _deleteOrder(LoyaltyOrderOnlineModel order) async {
    await _col.doc(order.docId).delete();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    setState(() => _filterDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('🛵 Rider Orders',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              if (_filterDate != null || _filterStatus != null)
                IconButton(
                  icon: const Icon(Icons.filter_alt_off, size: 18),
                  tooltip: 'Clear filters',
                  onPressed: () => setState(() {
                    _filterDate = null;
                    _filterStatus = null;
                  }),
                ),
            ],
          ),
        ),
        _buildFilterBar(),
        const Divider(height: 1),
        StreamBuilder<QuerySnapshot>(
          stream: _stream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snap.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: ${snap.error}'),
              );
            }

            final orders = _applyFilters(snap.data?.docs ?? []);

            if (orders.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.delivery_dining, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No orders found',
                          style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _OrderCard(
                order: orders[i],
                onStatusChanged: (s) => _updateStatus(orders[i], s),
                onDelete: () => _deleteOrder(orders[i]),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Status filter chips
          ...PickupStatus.values.map((s) {
            final selected = _filterStatus == s;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(s.label),
                selected: selected,
                selectedColor: _statusColor(s).withOpacity(0.2),
                checkmarkColor: _statusColor(s),
                onSelected: (_) =>
                    setState(() => _filterStatus = selected ? null : s),
              ),
            );
          }),
          const SizedBox(width: 8),
          // Date filter
          ActionChip(
            avatar: Icon(
              Icons.calendar_today,
              size: 16,
              color: _filterDate != null ? Colors.teal : Colors.grey,
            ),
            label: Text(
              _filterDate != null
                  ? DateFormat('MMM d').format(_filterDate!)
                  : 'Date',
              style: TextStyle(
                color: _filterDate != null ? Colors.teal : null,
              ),
            ),
            onPressed: _pickDate,
          ),
        ],
      ),
    );
  }
}

// ── Order card ──────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final LoyaltyOrderOnlineModel order;
  final void Function(PickupStatus) onStatusChanged;
  final VoidCallback onDelete;

  const _OrderCard({
    required this.order,
    required this.onStatusChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final status = order.pickupStatus;
    final color = _statusColor(status);
    final dateLabel = DateFormat('EEE, MMM d yyyy').format(order.scheduleDate);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: name + status badge + delete
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(order.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                _StatusBadge(status: status),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 20),
                  tooltip: 'Delete',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Details
            _infoRow(Icons.phone, order.contact),
            const SizedBox(height: 4),
            _infoRow(Icons.location_on_outlined, order.address),
            const SizedBox(height: 4),
            _infoRow(Icons.calendar_today, '$dateLabel  •  ${order.timeSlot}'),
            const SizedBox(height: 12),

            // Status action buttons
            Row(
              children: PickupStatus.values.map((s) {
                final isActive = status == s;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: OutlinedButton(
                      onPressed:
                          isActive ? null : () => _confirmChange(context, s),
                      style: OutlinedButton.styleFrom(
                        backgroundColor:
                            isActive ? _statusColor(s).withOpacity(0.15) : null,
                        foregroundColor: _statusColor(s),
                        side: BorderSide(
                          color:
                              isActive ? _statusColor(s) : Colors.grey.shade300,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(s.label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text(
            'Delete pickup order for "${order.name}" on ${DateFormat('MMM d, yyyy').format(order.scheduleDate)}?\n\nThis cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) onDelete();
  }

  Future<void> _confirmChange(
      BuildContext context, PickupStatus newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Status'),
        content: Text(
            'Change pickup status for ${order.name} to "${newStatus.label}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes')),
        ],
      ),
    );
    if (confirm == true) onStatusChanged(newStatus);
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PickupStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.label,
        style:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

Color _statusColor(PickupStatus s) => switch (s) {
      PickupStatus.pending => Colors.orange,
      PickupStatus.ongoing => Colors.blue,
      PickupStatus.completed => Colors.green,
    };
