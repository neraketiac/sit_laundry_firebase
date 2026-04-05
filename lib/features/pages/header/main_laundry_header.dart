import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/features/pages/body/main_laundry_body.dart';
import 'package:laundry_firebase/features/pages/header/GCash/showGCashOnly.dart';
import 'package:laundry_firebase/features/pages/header/GCash/showGCashPending.dart';
import 'package:laundry_firebase/features/pages/header/Funds/showFundsInFundsOut.dart';
import 'package:laundry_firebase/features/pages/header/Funds/showLaundryPayment.dart';
import 'package:laundry_firebase/features/pages/header/JobOnQueue/showJobOnQueue.dart';
import 'package:laundry_firebase/features/jobs/repository/jobmodel_repository.dart';
import 'package:laundry_firebase/features/items/repository/supplies_hist_repository.dart';
import 'package:laundry_firebase/core/global/variables.dart';

class MyMainLaundryHeader extends StatefulWidget {
  final String empid;

  const MyMainLaundryHeader(this.empid, {super.key});

  @override
  State<MyMainLaundryHeader> createState() => _MyMainLaundryHeaderState();
}

class _MyMainLaundryHeaderState extends State<MyMainLaundryHeader>
    with SingleTickerProviderStateMixin {
  late JobModelRepository jobRepoOnQueue;
  late JobModelRepository jobRepoNonJob;

  late String _sEmpId;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();

    _sEmpId = widget.empid;
    empIdGlobal = _sEmpId;

    isAdmin = (empIdGlobal == 'Ket' || empIdGlobal == 'DonF');

    SuppliesHistRepository.instance.reset();

    jobRepoOnQueue = JobModelRepository()..reset();
    jobRepoNonJob = JobModelRepository();
  }

  Widget _fab({
    required String hero,
    required IconData icon,
    String? label,
    required double bottom,
    required double right,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      bottom: bottom,
      right: right,
      child: AnimatedScale(
        scale: _isOpen ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: _isOpen ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label (only show if label is provided)
              if (_isOpen && label != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (label != null) const SizedBox(width: 12),
              // Button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  heroTag: hero,
                  mini: true,
                  backgroundColor: backgroundColor,
                  onPressed: onTap,
                  child: Icon(icon, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double base = 16;
    const double step = 70;
    const double horizontalStep = 70; // Horizontal spacing between buttons

    return Scaffold(
      body: MyMainLaundryBody(_sEmpId),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        width: 400,
        height: 450,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// Laundry Payment
            if (_isOpen)
              _fab(
                hero: 'Laundry Payment',
                icon: Icons.payments_outlined,
                label: 'Laundry Payment',
                bottom: base + step * 3,
                right: base,
                onTap: () {
                  setState(() => _isOpen = false);
                  showLaundryPayment(context, jobRepoNonJob);
                },
                backgroundColor: Colors.teal,
              ),

            /// Cash In/Out
            if (_isOpen)
              _fab(
                hero: 'Gcash Funds',
                icon: Icons.attach_money_sharp,
                label: 'Cash In/Out',
                bottom: base + step * 2,
                right: base,
                onTap: () {
                  setState(() => _isOpen = false);
                  showGCashOnly(context, jobRepoNonJob);
                },
                backgroundColor: Colors.green,
              ),

            /// Funds In/Out
            if (_isOpen)
              _fab(
                hero: 'Funds In Out',
                icon: Icons.swap_vert,
                label: 'Funds In/Out',
                bottom: base + step,
                right: base,
                onTap: () {
                  setState(() => _isOpen = false);
                  showFundsInFundsOut(context);
                },
                backgroundColor: Colors.deepPurple,
              ),

            // /// Inventory
            // if (_isOpen)
            //   _fab(
            //     hero: 'Supplies',
            //     icon: Icons.inventory,
            //     label: 'Inventory',
            //     bottom: base + step,
            //     right: base,
            //     onTap: () {
            //       setState(() => _isOpen = false);
            //       showItemsInOut(context);
            //     },
            //     backgroundColor: Colors.orange,
            //   ),

            /// Enter GCash (Bottom Middle - No Label)
            if (_isOpen)
              _fab(
                hero: 'GCash Pending',
                icon: Icons.g_mobiledata,
                label: null,
                bottom: base,
                right: base + horizontalStep,
                onTap: () {
                  setState(() => _isOpen = false);
                  showGCashPending(context);
                },
                backgroundColor: cShowGCash,
              ),

            /// Enter Laundry (Bottom Left)
            if (_isOpen)
              _fab(
                hero: 'Jobs On Queue',
                icon: Icons.local_laundry_service,
                label: 'Enter Laundry/GCash',
                bottom: base,
                right: base + horizontalStep * 2,
                onTap: () {
                  setState(() => _isOpen = false);
                  showJobOnQueue(context, jobRepoOnQueue);
                },
                backgroundColor: Colors.blueAccent,
              ),

            /// MAIN FAB (Always visible)
            Positioned(
              bottom: base,
              right: base,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: FloatingActionButton(
                    heroTag: 'main',
                    mini: true,
                    backgroundColor: _isOpen ? Colors.red : Colors.deepPurple,
                    elevation: 12,
                    onPressed: () {
                      if (_isOpen) {
                        setState(() => _isOpen = false);
                      } else {
                        setState(() => _isOpen = true);
                      }
                    },
                    child: AnimatedRotation(
                      duration: const Duration(milliseconds: 250),
                      turns: _isOpen ? 0.125 : 0,
                      child: Icon(
                        _isOpen ? Icons.close : Icons.add,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
