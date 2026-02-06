import 'package:flutter/material.dart';
import 'package:laundry_firebase/pages/updatedpages/body/main_laundry_body.dart';
import 'package:laundry_firebase/pages/updatedpages/header/Funds/showCalendarDialog.dart';
import 'package:laundry_firebase/pages/updatedpages/header/Funds/showCashFundsInput.dart';
import 'package:laundry_firebase/pages/updatedpages/header/Funds/showFundCheck.dart';
import 'package:laundry_firebase/pages/updatedpages/header/JobsOnQueue/showJobsOnQueue.dart';
import 'package:laundry_firebase/pages/updatedpages/header/Employee/showSalaryMaintenance.dart';
import 'package:laundry_firebase/variables/updatedvariables/jobsmodel_repository.dart';
import 'package:laundry_firebase/variables/updatedvariables/supplies_hist_repository.dart';
import 'package:laundry_firebase/variables/variables.dart';

/*
cd C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase
C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase> git status
C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase> git add .
C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase> git commit -m "JobsOnGoing"
C:\Users\haali\Documents\GIT_SIT\sit_laundry_firebase> git push

flutter build web
firebase login
firebase init hosting
  public (yes)
  rewrite index (yes)
  github (no)
open file firebase.json change public to build/web
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
    JobsModelRepository.instance.reset();

    //*show JobsOnQueue

    //*showJobsOnQueue
  }

  Widget _fab({
    required String hero,
    required IconData icon,
    required double bottom,
    required double right,
    required VoidCallback onTap,
  }) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 320), // fast → slow
      curve: Curves.easeOutCubic,
      bottom: bottom,
      right: right,
      child: FloatingActionButton(
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
    return Scaffold(
      body: MyMainLaundryBody(_sEmpId),
      floatingActionButton: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// ───── Vertical (bottom → top)
            _fab(
              hero: 'JobsOnQueue',
              icon: Icons.local_laundry_service,
              bottom: _isOpen ? base + 180 : base,
              right: base,
              onTap: () {
                showJobsOnQueue(context);
              },
            ),
            _fab(
              hero: 'Funds In Funds Out',
              icon: Icons.money,
              bottom: _isOpen ? base + 120 : base,
              right: base,
              onTap: () {
                showCashFundsInput(context);
              },
            ),
            _fab(
              hero: 'Fund Check',
              icon: Icons.price_check_outlined,
              bottom: _isOpen ? base + 60 : base,
              right: base,
              onTap: () {
                showFundCheck(context);
              },
            ),

            /// ───── Horizontal (right → left)
            // _fab(
            //   hero: 'FundCheck',
            //   icon: Icons.price_check_outlined,
            //   bottom: base,
            //   right: _isOpen ? base + 180 : base,
            //   onTap: () {
            //     showFundCheck(context);
            //   },
            // ),
            _fab(
              hero: 'Calendar',
              icon: Icons.calendar_month,
              bottom: base,
              right: _isOpen ? base + 120 : base,
              onTap: () async {
                await showCalendarDialog(context);

                // if (result != null) {
                //   print(result); // Map<DateTime, DaySelection>
                // };
              },
            ),
            _fab(
              hero: 'Salary Input',
              icon: Icons.timer_sharp,
              bottom: base,
              right: _isOpen ? base + 60 : base,
              onTap: () {
                showSalaryMaintenance(context);
              },
            ),

            /// ───── Main FAB (Y)
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
