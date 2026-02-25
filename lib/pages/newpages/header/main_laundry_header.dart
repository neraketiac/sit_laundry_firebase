import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/newpages/body/main_laundry_body.dart';
import 'package:laundry_firebase/pages/newpages/header/GCash/showGCashOnly.dart';
import 'package:laundry_firebase/pages/newpages/header/GCash/showGCashPending.dart';
import 'package:laundry_firebase/pages/newpages/header/Funds/showLaundryPayment.dart';
import 'package:laundry_firebase/pages/newpages/header/JobOnQueue/showJobOnQueue.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

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
    required double bottom,
    required double left,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      bottom: bottom,
      left: left,
      child: AnimatedScale(
        scale: _isOpen ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: _isOpen ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              heroTag: hero,
              mini: true,
              backgroundColor: backgroundColor,
              onPressed: onTap,
              child: Icon(icon),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double base = 16;
    const double step = 60;

    return Scaffold(
      body: MyMainLaundryBody(_sEmpId),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// GCash Funds
            _fab(
              hero: 'Gcash Funds',
              icon: Icons.attach_money_sharp,
              bottom: base,
              left: _isOpen ? base + step * 2 : base,
              onTap: () => showGCashOnly(context, jobRepoNonJob),
              backgroundColor: cAdmin,
            ),

            /// Laundry Payment
            _fab(
              hero: 'Laundry Payment',
              icon: Icons.payments_outlined,
              bottom: base,
              left: _isOpen ? base + step : base,
              onTap: () => showLaundryPayment(context, jobRepoNonJob),
              backgroundColor: cAdmin,
            ),

            /// GCash Pending
            _fab(
              hero: 'GCash Pending',
              icon: Icons.g_mobiledata,
              bottom: _isOpen ? base + step : base,
              left: _isOpen ? base + step : base,
              onTap: () => showGCashPending(context),
              backgroundColor: cShowGCash,
            ),

            /// Jobs On Queue
            _fab(
              hero: 'JobsOnQueue',
              icon: Icons.local_laundry_service,
              bottom: _isOpen ? base + step : base,
              left: base,
              onTap: () => showJobOnQueue(context, jobRepoOnQueue),
              backgroundColor: cJobsOnQueue,
            ),

            /// MAIN FAB (Glass Style)
            Positioned(
              bottom: base,
              left: base,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: FloatingActionButton(
                    heroTag: 'main',
                    backgroundColor: Colors.deepPurple,
                    elevation: 12,
                    onPressed: () {
                      setState(() => _isOpen = !_isOpen);
                    },
                    child: AnimatedRotation(
                      duration: const Duration(milliseconds: 250),
                      turns: _isOpen ? 0.125 : 0,
                      child: Icon(
                        _isOpen ? Icons.close : Icons.menu,
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
