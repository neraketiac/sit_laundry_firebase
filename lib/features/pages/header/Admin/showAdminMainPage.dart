import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/other_item_admin/showBleItemsMaintenance.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/other_item_admin/showDetItemsMaintenance.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/other_item_admin/showFabItemsMaintenance.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/runMigration.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/showAdminDateDPage.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/showBatchPromo.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/batch_fix_promo_counter_page.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/batch_promo_review_page.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/loyalty_validation_page.dart';
import 'package:laundry_firebase/features/pages/header/Admin/subAdmin/migrateToThird.dart';
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
                      "The number below will be the next number for Jobs-OnGoing."),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "nextavailable",
                      border: OutlineInputBorder(),
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
                  title: const Text("Batch Promo Review"),
                  subtitle: const Text(
                      "Preview & apply promo error code changes per customer"),
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
                  title: const Text("Batch Fix PromoCounter"),
                  subtitle: const Text(
                      "Fix incorrect promoCounter values in Jobs_done and Jobs_completed"),
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
                  title: const Text("Monthly Analytics"),
                  subtitle: const Text(
                      "View weekly revenue charts and unpaid customers summary"),
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
                  title: const Text("Rider Schedule Management"),
                  subtitle: const Text("Set rider availability slots per day"),
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
                  title: const Text("Loyalty Count Validation"),
                  subtitle: const Text(
                      "Validate loyalty counts against applicable promoCounter (promoErrorCode = 0)"),
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
                child: const RunMigration(),
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
                  title: const Text("Migrate Reports DB"),
                  subtitle: const Text(
                      "Select collections to migrate from main to Reports DB"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar:
                              AppBar(title: const Text("Migrate to ThirdWeb")),
                          body: const SingleChildScrollView(
                            padding: EdgeInsets.all(16),
                            child: MigrateToThird(),
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
                  title: const Text("Other Items Maintenance"),
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
                  title: const Text("Deterget Items Maintenance"),
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
                  title: const Text("Fabricon Items Maintenance"),
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
                  title: const Text("Bleach Items Maintenance"),
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
          ],
        ),
      ),
    );
  }
}
