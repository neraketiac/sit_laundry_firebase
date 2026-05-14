import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/copy_to_loyalty_db.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/edit_auto_salary_date_page.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/AutoSalaryDateOneTimeBatch.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/other_item_admin/showBleItemsMaintenance.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/other_item_admin/showDetItemsMaintenance.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/other_item_admin/showFabItemsMaintenance.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/showAdminDateDPage.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/showBatchPromo.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/batch_fix_promo_counter_page.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/batch_promo_review_page.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/loyalty_validation_page.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/migrateToReportsDB.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/sit_vs_loyalty.dart';
import 'package:laundry_firebase/features/pages/header/Admin/rider/show_rider_management.dart';
import 'package:laundry_firebase/features/pages/header/Admin/reports/monthly_analytics/monthly_analytics_page.dart';
import 'package:laundry_firebase/core/global/variables.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/other_item_admin/showOtherItemsMaintenance.dart';

class ShowAdminMainPage extends StatefulWidget {
  const ShowAdminMainPage({super.key});

  @override
  State<ShowAdminMainPage> createState() => _ShowAdminMainPageState();
}

class _ShowAdminMainPageState extends State<ShowAdminMainPage> {
  final TextEditingController controller = TextEditingController();
  bool loading = true;

  final docRef =
      FirebaseFirestore.instance.collection('counters').doc('jobQueue');

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final doc = await docRef.get();
    controller.text = (doc.data()?['nextavailable'] ?? 0).toString();
    setState(() {
      loading = false;
    });
  }

  Future<void> save() async {
    final value = int.tryParse(controller.text) ?? 0;

    await docRef.update({
      'nextavailable': value,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Edit Counter
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "The number below will be the next number for Jobs-OnGoing.",
                    style: TextStyle(
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: Colors.grey.shade900,
                    ),
                    decoration: InputDecoration(
                      labelText: "nextavailable",
                      labelStyle: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: save,
                    child: const Text("Save"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// LOYALTY DATA SYNC - TOP PRIORITY
            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple.shade700, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.purple.shade50,
                ),
                child: ListTile(
                  leading:
                      const Icon(Icons.compare_arrows, color: Colors.purple),
                  title: Text(
                    "🔄 Loyalty Data Sync",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade900,
                    ),
                  ),
                  subtitle: Text(
                    "Compare and sync loyalty records between Primary DB and Loyalty DB",
                    style: TextStyle(
                      color: Colors.purple.shade700,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar:
                              AppBar(title: const Text("Loyalty Data Sync")),
                          body: const SingleChildScrollView(
                            padding: EdgeInsets.all(16),
                            child: SitVsLoyalty(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 30),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const BatchPromo(),
              ),

            const SizedBox(height: 30),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.preview, color: Colors.deepOrange),
                  title: Text(
                    "Batch Promo Review",
                    style: TextStyle(
                      color: Colors.deepOrange.shade900,
                    ),
                  ),
                  subtitle: Text(
                    "Preview & apply promo error code changes per customer",
                    style: TextStyle(
                      color: Colors.deepOrange.shade700,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BatchPromoReviewPage(),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 30),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.build_circle, color: Colors.orange),
                  title: Text(
                    "Batch Fix PromoCounterxxx",
                    style: TextStyle(
                      color: Colors.orange.shade900,
                    ),
                  ),
                  subtitle: Text(
                    "Fix incorrect promoCounter values in Jobs_done and Jobs_completed",
                    style: TextStyle(
                      color: Colors.orange.shade700,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BatchFixPromoCounterPage(),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 30),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.bar_chart, color: Colors.blue),
                  title: Text(
                    "Monthly Analytics",
                    style: TextStyle(
                      color: Colors.blue.shade900,
                    ),
                  ),
                  subtitle: Text(
                    "View weekly revenue charts and unpaid customers summary",
                    style: TextStyle(
                      color: Colors.blue.shade700,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MonthlyAnalyticsPage(),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 30),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.cyan.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading:
                      const Icon(Icons.delivery_dining, color: Colors.cyan),
                  title: Text(
                    "Rider Schedule Management",
                    style: TextStyle(
                      color: Colors.cyan.shade900,
                    ),
                  ),
                  subtitle: Text(
                    "Set rider availability slots per day",
                    style: TextStyle(
                      color: Colors.cyan.shade700,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ShowRiderManagement(),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 30),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.analytics, color: Colors.purple),
                  title: Text(
                    "Loyalty Count Validation",
                    style: TextStyle(
                      color: Colors.purple.shade900,
                    ),
                  ),
                  subtitle: Text(
                    "Validate loyalty counts against applicable promoCounter (promoErrorCode = 0)",
                    style: TextStyle(
                      color: Colors.purple.shade700,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoyaltyValidationPage(),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(
              height: 30,
            ),

            // if (isAdmin)
            //   Container(
            //     padding: const EdgeInsets.all(16),
            //     decoration: BoxDecoration(
            //       color: Colors.grey.shade300,
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: const ShowMoveDoneToCompleted(),
            //   ),

            // const SizedBox(height: 30),

            // if (isAdmin)
            //   Container(
            //     padding: const EdgeInsets.all(16),
            //     decoration: BoxDecoration(
            //       color: Colors.grey.shade300,
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: const ShowDeleteSecondaryData(),
            //   ),

            // const SizedBox(height: 40),

            // const SizedBox(height: 40),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const UpdateLoyaltyDB(),
              ),

            const SizedBox(height: 30),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.sync_alt, color: Colors.teal),
                  title: Text(
                    "Migrate Reports DB",
                    style: TextStyle(
                      color: Colors.teal.shade900,
                    ),
                  ),
                  subtitle: Text(
                    "Select collections to migrate from main to Reports DB",
                    style: TextStyle(
                      color: Colors.teal.shade700,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar:
                              AppBar(title: const Text("Migrate to ThirdWebx")),
                          body: const SingleChildScrollView(
                            padding: EdgeInsets.all(16),
                            child: UpdateBackUpDB(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 12),

            const SizedBox(height: 30),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const AdminDateDPage(),
              ),

            const SizedBox(height: 40),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.inventory),
                  title: Text(
                    "Other Items Maintenance",
                    style: TextStyle(
                      color: Colors.grey.shade900,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OtherItemsPage(),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 40),
            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.inventory),
                  title: Text(
                    "Deterget Items Maintenance",
                    style: TextStyle(
                      color: Colors.grey.shade900,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DetItemsPage(),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 40),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.inventory),
                  title: Text(
                    "Fabricon Items Maintenance",
                    style: TextStyle(
                      color: Colors.grey.shade900,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FabItemsPage(),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 40),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.inventory),
                  title: Text(
                    "Bleach Items Maintenance",
                    style: TextStyle(
                      color: Colors.grey.shade900,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BleItemsPage(),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 40),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.update, color: Colors.green),
                  title: Text(
                    "Auto Salary Date — One Time Batch",
                    style: TextStyle(
                      color: Colors.green.shade900,
                    ),
                  ),
                  subtitle: Text(
                    "Copy LogDate → AutoSalaryDate for all EmployeeHist records",
                    style: TextStyle(
                      color: Colors.green.shade700,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AutoSalaryDateOneTimeBatch(),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 40),

            if (isAdmin)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.edit_calendar, color: Colors.teal),
                  title: Text(
                    "Edit AutoSalaryDate",
                    style: TextStyle(
                      color: Colors.teal.shade900,
                    ),
                  ),
                  subtitle: Text(
                    "Manually edit AutoSalaryDate per EmployeeHist record",
                    style: TextStyle(
                      color: Colors.teal.shade700,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditAutoSalaryDatePage(),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
