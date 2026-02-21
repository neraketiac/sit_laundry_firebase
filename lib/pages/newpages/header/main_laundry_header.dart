import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/newpages/body/main_laundry_body.dart';
import 'package:laundry_firebase/pages/newpages/header/Funds/showCalendarDialog.dart';
import 'package:laundry_firebase/pages/newpages/header/Funds/showFundsInFundsOut.dart';
import 'package:laundry_firebase/pages/newpages/header/GCash/showGCashOnly.dart';
import 'package:laundry_firebase/pages/newpages/header/GCash/showGCashPending.dart';
import 'package:laundry_firebase/pages/newpages/header/Funds/showLaundryPayment.dart';
import 'package:laundry_firebase/pages/newpages/header/Funds/showFundCheck.dart';
import 'package:laundry_firebase/pages/newpages/header/JobOnQueue/showJobOnQueue.dart';
import 'package:laundry_firebase/pages/newpages/header/Employee/showSalaryMaintenance.dart';
import 'package:laundry_firebase/variables/newvariables/jobmodel_repository.dart';
import 'package:laundry_firebase/variables/newvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/newvariables/variables.dart';

/*
cd C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase
C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase> git status
C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase> git add .
C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase> git commit -m "JobsOnGoing"
C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase> git push

flutter build web
firebase login
///--<< do this on first time only
  firebase init hosting
    public (yes)
    rewrite index (yes)
    github (no)
  open file firebase.json change public to build/web
//-->>
firebase deploy


*/

class MyMainLaundryHeader extends StatefulWidget {
  final String empid;

  const MyMainLaundryHeader(this.empid, {super.key});

  @override
  State<MyMainLaundryHeader> createState() => _MyMainLaundryHeaderState();
}

class _MyMainLaundryHeaderState extends State<MyMainLaundryHeader> {
//*showJobsOnQueue
//*showJobsOnQueue

  late JobModelRepository jobRepoBQ;
  late JobModelRepository jobRepoNonJob;

  late String _sEmpId;

  bool _isOpen = false;

  @override
  void initState() {
    super.initState();

    _sEmpId = widget.empid;
    empIdGlobal = _sEmpId;
    if (empIdGlobal == 'Ket' || empIdGlobal == 'DonF') {
      isAdmin = true;
    } else {
      isAdmin = false;
    }
    SuppliesHistRepository.instance.reset();

    jobRepoBQ = JobModelRepository();
    jobRepoNonJob = JobModelRepository();

    //JobModelRepository.instance.reset();

    //*show JobsOnQueue

    //*showJobsOnQueue
  }

  Widget _fab({
    required String hero,
    required IconData icon,
    required double bottom,
    required double right,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 320), // fast → slow
      curve: Curves.easeOutCubic,
      bottom: bottom,
      right: right,
      child: FloatingActionButton(
        backgroundColor: backgroundColor,
        heroTag: hero,
        mini: true,
        onPressed: onTap,
        child: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double base = 16;
    const double step = 60;

    return Scaffold(
      body: MyMainLaundryBody(_sEmpId),
      floatingActionButton: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            //4th floor

            //3rd floor

            _fab(
                hero: 'Gcash Funds',
                icon: Icons.attach_money_sharp,
                bottom: _isOpen ? base : base,
                right: _isOpen ? base + step + step : base,
                onTap: () => showGCashOnly(context, jobRepoNonJob),
                backgroundColor: cAdmin),

            _fab(
                hero: 'Laundry Payment',
                icon: Icons.payments_outlined,
                bottom: _isOpen ? base : base,
                right: _isOpen ? base + step : base,
                onTap: () => showLaundryPayment(context, jobRepoNonJob),
                backgroundColor: cAdmin),

            //1st floor

            _fab(
                hero: 'GCash Pending',
                icon: Icons.g_mobiledata,
                bottom: _isOpen ? base + step : base,
                right: _isOpen ? base + step : base,
                onTap: () => showGCashPending(context),
                backgroundColor: cShowGCash),

            _fab(
                hero: 'JobsOnQueue',
                icon: Icons.local_laundry_service,
                bottom: _isOpen ? base + step : base,
                right: _isOpen ? base : base,
                onTap: () => showJobOnQueue(context, jobRepoBQ),
                backgroundColor: cJobsOnQueue),

            /// ───── Main FAB
            Positioned(
              bottom: base,
              right: base,
              child: FloatingActionButton(
                heroTag: 'main',
                onPressed: () {
                  setState(() => _isOpen = !_isOpen);
                },
                child: Icon(_isOpen ? Icons.close : Icons.menu),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
