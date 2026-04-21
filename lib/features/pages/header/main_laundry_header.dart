import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/core/utils/app_scale.dart';
import 'package:laundry_firebase/features/pages/body/main_laundry_body.dart';
import 'package:laundry_firebase/features/pages/header/Funds/showLaundryPayment.dart';
import 'package:laundry_firebase/features/pages/header/GCash/showGCashOnly.dart';
import 'package:laundry_firebase/features/pages/header/GCash/showGCashPending.dart';
import 'package:laundry_firebase/features/pages/header/Funds/showFundsInFundsOut.dart';
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
    double iconSize = 20,
    double labelFontSize = 13,
    bool mini = true,
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
              if (_isOpen && label != null)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: labelFontSize, vertical: labelFontSize * 0.6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (label != null) const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  heroTag: hero,
                  mini: mini,
                  backgroundColor: backgroundColor,
                  onPressed: onTap,
                  child: Icon(icon, size: iconSize),
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
    final s = AppScale.of(context);
    final double base = 16;
    final double step = s.isTablet ? 90.0 : 70.0;
    final double horizontalStep = s.isTablet ? 90.0 : 70.0;
    final double iconSize = s.isTablet ? 26.0 : 20.0;
    final double labelSize = s.isTablet ? 15.0 : 13.0;
    final bool mini = !s.isTablet; // full-size FAB on iPad

    return Scaffold(
      body: MyMainLaundryBody(_sEmpId),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        width: s.isTablet ? 520 : 400,
        height: s.isTablet ? 580 : 450,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// Laundry Payment
            if (_isOpen || isAdmin)
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
                iconSize: iconSize,
                labelFontSize: labelSize,
                mini: mini,
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
                iconSize: iconSize,
                labelFontSize: labelSize,
                mini: mini,
              ),

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
                iconSize: iconSize,
                mini: mini,
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
                iconSize: iconSize,
                labelFontSize: labelSize,
                mini: mini,
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
                    mini: mini,
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
                        size: iconSize,
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
