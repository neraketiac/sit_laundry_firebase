import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';
import 'package:laundry_firebase/features/items/models/otheritemmodel.dart';
import 'package:laundry_firebase/features/jobs/models/jobmodel.dart';
import 'package:laundry_firebase/features/loyalty/models/loyaltymodel.dart';
import 'package:laundry_firebase/features/pages/body/rider/loyalty_order_online_model.dart';
import 'package:web/web.dart' as web;

// 🔥 Make sure these are defined somewhere in your project
// const String JOBS_QUEUE_REF = "Jobs_queue";
// const String JOBS_ONGOING_REF = "Jobs_ongoing";
// const String JOBS_DONE_REF = "Jobs_done";
// const String JOBS_COMPLETED_REF = "Jobs_completed";

// ================= JOB QUERY FUNCTION =================

Future<List<JobModel>> getJobsByCardNumber(String cardNumber) async {
  const String JOBS_DONE_REF = "Jobs_done";
  const String JOBS_COMPLETED_REF = "Jobs_completed";

  List<JobModel> allJobs = [];

  // Jobs_done from jobsDoneFirestore
  final doneSnapshot = await FirebaseService.jobsDoneFirestore
      .collection(JOBS_DONE_REF)
      .where(
        'C00_CustomerId',
        isEqualTo: int.tryParse(cardNumber) ?? cardNumber,
      )
      .get();

  for (final doc in doneSnapshot.docs) {
    final data = doc.data();
    data['docId'] = doc.id;
    allJobs.add(JobModel.fromJson(data));
  }

  // Jobs_completed from primary DB
  final completedSnapshot = await FirebaseFirestore.instance
      .collection(JOBS_COMPLETED_REF)
      .where(
        'C00_CustomerId',
        isEqualTo: int.tryParse(cardNumber) ?? cardNumber,
      )
      .get();

  for (final doc in completedSnapshot.docs) {
    final data = doc.data();
    data['docId'] = doc.id;
    allJobs.add(JobModel.fromJson(data));
  }

  allJobs.sort((a, b) => b.dateD.compareTo(a.dateD));
  return allJobs;
}

// ================= MAIN WIDGET =================

class MyLoyaltyCardFull extends StatefulWidget {
  final String code;

  const MyLoyaltyCardFull(this.code, {super.key});

  @override
  State<MyLoyaltyCardFull> createState() => _MyLoyaltyCardFullState();
}

class _MyLoyaltyCardFullState extends State<MyLoyaltyCardFull>
    with TickerProviderStateMixin {
  int? _selectedIndex;
  Future<LoyaltyModel?>? _future;
  late AnimationController controller;
  late Animation<double> animation;
  late AnimationController controllerbubble;
  late Animation<double> animationbubble;
  final Map<int, String> promoErrorMessages = {
    0: "Eligible for promo",
    1: "On review – partial eligible, unpaid",
    2: "Not eligible – unpaid for 2 weeks",
    3: "Not eligible – last laundry not within 2 weeks",
    4: "Promo ended",
    5: "Promo reset – previous eligible jobs are no longer counted",
    99: "No promo status",
  };

  String getPromoErrorMessage(int? code) {
    return promoErrorMessages[code] ?? "Unknown promo status";
  }

  final promoFree = OtherItemModel(
    docId: "",
    itemId: 423,
    itemUniqueId: 423,
    itemGroup: "Oth",
    itemName: "Free",
    itemPrice: -155,
    stocksAlert: 5,
    stocksType: "pcs",
    logDate: Timestamp.now(),
  );

  @override
  void initState() {
    super.initState();
    _future = _fetchLoyalty();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    animation = Tween<double>(begin: -6, end: 6).animate(controller);

    controllerbubble = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    animationbubble = Tween<double>(
      begin: -10,
      end: 16,
    ).animate(controllerbubble);
  }

  @override
  void dispose() {
    controller.dispose(); // IMPORTANT
    controllerbubble.dispose();
    super.dispose();
  }

  Future<LoyaltyModel?> _fetchLoyalty() async {
    final parsed = int.tryParse(widget.code);
    if (parsed == null) return null;

    // loyalty collection is on the forthWeb database
    final snap = await FirebaseService.forthFirestore
        .collection('loyalty')
        .where('cardNumber', isEqualTo: parsed)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final loyalty = LoyaltyModel.fromJson(snap.docs.first.data());

    // 🔥 Dynamically fetch jobs
    final jobs = await getJobsByCardNumber(widget.code);

    jobs.sort((a, b) => a.dateD.compareTo(b.dateD));

    // Inject jobs in memory only
    loyalty.jobs = jobs;

    if (loyalty.jobs.isNotEmpty) {
      _selectedIndex = 0;
    }

    return loyalty;
  }

  void _showPromoRules() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Laundry Loyalty Promo"),
        content: const SingleChildScrollView(
          child: Text(
            "• The promo aims to reward customers who continuously use our laundry service for two (2) weeks.\n\n"
            "• “Using our service” means availing the laundry service and settling the payment on time for each transaction.\n\n"
            "• If a payment is delayed or unpaid, the time will still be counted within the two-week period. In such cases, the promo eligibility may be reset or removed.\n\n"
            "• The promo period begins on the date when there are no payment or service violations.\n\n"
            "• Promo is only applicable in Full Service 155 Php (1 load = 1 star). Any modifications would still be considered as 1 star.\n\n"
            "• Customers who successfully complete ten (10) paid laundry services within the promo conditions will receive one (1) free wash.\n\n"
            "• The free wash may only be claimed upon reaching a minimum of ten (10) stamps and is redeemable on the customer’s next visit only, not within the same transaction.\n\n"
            "• The loyalty promo is non-transferable and intended for the same customer account.\n\n"
            "• Management reserves the right to adjust or clarify the promo terms if necessary to maintain fairness and service quality.",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFF90CAF9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<LoyaltyModel?>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text("Card not found"));
              }

              return _modernCardUI(snapshot.data!);
            },
          ),
        ),
      ),
    );
  }

  // ================= MAIN CARD =================

  Widget _modernCardUI(LoyaltyModel loyalty) {
    /// sort jobs by date
    final jobsAll = [...loyalty.jobs];
    print("Total jobs loaded: ${jobsAll.length}");
    for (var job in jobsAll) {
      final paid = job.paidCashAmount +
          (job.paidGCashverified ? job.paidGCashAmount : 0);
      print(
        "Job #${job.jobId} - Date: ${job.dateD.toDate()} - Price: ₱${job.finalPrice} - Paid: ₱$paid - Unpaid: ${job.unpaid} - PaidCash: ${job.paidCashAmount} - PaidGCash: ${job.paidGCashAmount} - GCashVerified: ${job.paidGCashverified} code: ${job.promoErrorCode}",
      );
    }
    jobsAll.sort((a, b) => b.dateD.compareTo(a.dateD));

    final sorted = [...loyalty.jobs]
      ..sort((a, b) => b.dateD.compareTo(a.dateD));

    final hasBoundary = sorted.any((j) => j.promoErrorCode != 0);

    final jobs = hasBoundary
        ? sorted.takeWhile((j) => j.promoErrorCode == 0).toList()
        : sorted;

    jobs.sort((a, b) => a.dateD.compareTo(b.dateD));

    /// map stamps to jobs
    final List<int> starToJobIndex = [];

    for (int j = 0; j < jobs.length; j++) {
      final job = jobs[j];
      print(job);

      for (int i = 0; i < job.promoCounter; i++) {
        starToJobIndex.add(j);
      }
    }

    /// detect reward stamps
    final List<int> rewardStars = [];
    final List<int> filteredStars = [];

    for (int i = 0; i < starToJobIndex.length; i++) {
      if ((i + 1) % 11 == 0) {
        rewardStars.add(starToJobIndex[i]);
      } else {
        filteredStars.add(starToJobIndex[i]);
      }
    }

    /// split stamps into promo groups
    final List<List<int>> promoGroups = [];

    for (int i = 0; i < filteredStars.length; i += 10) {
      promoGroups.add(
        filteredStars.sublist(
          i,
          (i + 10 > filteredStars.length) ? filteredStars.length : i + 10,
        ),
      );
    }

    /// newest promo card on top
    final groups = promoGroups.reversed.toList();

    final promoCounter = starToJobIndex.length;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: animationbubble,
                  builder: (_, child) {
                    return Transform.translate(
                      offset: Offset(0, animationbubble.value),
                      child: child,
                    );
                  },
                  child: const Text(
                    "🫧",
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),

                //Image.asset("assets/images/washkolang.png", width: 280),
                AnimatedBuilder(
                  animation: animation,
                  builder: (_, child) {
                    return Transform.translate(
                      offset: Offset(0, animation.value),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    "assets/images/washkolang.png",
                    width: 280,
                  ),
                ),

                AnimatedBuilder(
                  animation: animationbubble,
                  builder: (_, child) {
                    return Transform.translate(
                      offset: Offset(0, animationbubble.value),
                      child: child,
                    );
                  },
                  child: const Text(
                    "🫧",
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              "Laundry Hub",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Card #${loyalty.cardNumber}",
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.shade200, blurRadius: 18),
                  ],
                ),
                child: Column(
                  children: [
                    _infoRow("Name", loyalty.name),
                    _infoRow("Contact", loyalty.contact),
                    _infoRow("Address", loyalty.address),

                    const SizedBox(height: 18),

                    /// PROMO CARDS
                    Column(
                      spacing: 10,
                      children: groups.asMap().entries.map((entry) {
                        final groupIndex = entry.key;
                        final groupStars = entry.value;
                        final filledStars = groupStars.length;

                        /// real promo index
                        final rewardIndex = promoGroups.length - 1 - groupIndex;

                        return Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent[100],
                            borderRadius: BorderRadius.circular(
                              16,
                            ), // 👈 curve corners
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// STAMP GRID
                                Expanded(
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: 10,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                    ),
                                    itemBuilder: (context, index) {
                                      final filled = index < filledStars;

                                      int? jobIndex;

                                      if (filled && index < groupStars.length) {
                                        jobIndex = groupStars[index];
                                      }

                                      String? stampDate;
                                      bool hasPromoFree = false;
                                      int promoFreeCount = 0;

                                      if (filled && jobIndex != null) {
                                        final job = jobs[jobIndex];

                                        //check the star if has free - start

                                        //check if this job took the free
                                        hasPromoFree = job.items.any(
                                          (item) =>
                                              item.itemUniqueId ==
                                              promoFree.itemUniqueId,
                                        );

                                        promoFreeCount = job.items
                                            .where(
                                              (item) =>
                                                  item.itemUniqueId ==
                                                  promoFree.itemUniqueId,
                                            )
                                            .length;

                                        //check the star if has free - end

                                        final DateTime d = job.dateD.toDate();

                                        stampDate =
                                            "${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}";
                                      }

                                      return GestureDetector(
                                        onTap: filled && jobIndex != null
                                            ? () {
                                                setState(() {
                                                  _selectedIndex = jobIndex!;
                                                });
                                              }
                                            : null,
                                        child: AnimatedScale(
                                          scale: (_selectedIndex == jobIndex)
                                              ? 1.15
                                              : 0.7,
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: filled
                                                  ? const LinearGradient(
                                                      colors: [
                                                        Color(0xFF4FC3F7),
                                                        Color(0xFF1E88E5),
                                                      ],
                                                    )
                                                  : null,
                                              color: filled
                                                  ? null
                                                  : Colors.blue.shade100,
                                              boxShadow: filled
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.blueAccent
                                                            .withOpacity(.4),
                                                        blurRadius: 12,
                                                      ),
                                                    ]
                                                  : [],
                                            ),
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              alignment: Alignment.center,
                                              children: [
                                                Icon(
                                                  filled
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: filled
                                                      ? Colors.white
                                                      : Colors.blueGrey,
                                                  size: 54,
                                                ),
                                                if (filled && stampDate != null)
                                                  Positioned(
                                                    top: 26,
                                                    right: 6,
                                                    child: Transform.rotate(
                                                      angle: 0.2,
                                                      child: Stack(
                                                        children: [
                                                          Text(
                                                            stampDate,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              foreground:
                                                                  Paint()
                                                                    ..style =
                                                                        PaintingStyle
                                                                            .stroke
                                                                    ..strokeWidth =
                                                                        3
                                                                    ..color =
                                                                        Colors
                                                                            .black,
                                                            ),
                                                          ),
                                                          Text(
                                                            stampDate,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .amberAccent,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (hasPromoFree)
                                                  Positioned(
                                                    top: 8,
                                                    right: 0,
                                                    child: Transform.rotate(
                                                      angle: 0,
                                                      child: Stack(
                                                        children: [
                                                          Text(
                                                            "($promoFreeCount) Free Taken",
                                                            style: TextStyle(
                                                              fontSize: 8,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              foreground:
                                                                  Paint()
                                                                    ..style =
                                                                        PaintingStyle
                                                                            .stroke
                                                                    ..strokeWidth =
                                                                        3
                                                                    ..color =
                                                                        Colors
                                                                            .black,
                                                            ),
                                                          ),
                                                          Text(
                                                            "($promoFreeCount) Free Taken",
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 8,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .amberAccent,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// BIG FREE STAR
                                /// BIG FREE STAR
                                Builder(
                                  builder: (context) {
                                    int? jobIndex;

                                    if (rewardStars.length > rewardIndex) {
                                      jobIndex = rewardStars[rewardIndex];
                                    }

                                    String? stampDate;
                                    bool hasPromoFree = false;
                                    int promoFreeCount = 0;

                                    if (jobIndex != null) {
                                      final job = jobs[jobIndex];
                                      final DateTime d = job.dateD.toDate();
                                      stampDate =
                                          "${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}";
                                      hasPromoFree = job.items.any(
                                        (item) =>
                                            item.itemUniqueId ==
                                            promoFree.itemUniqueId,
                                      );
                                      promoFreeCount = job.items
                                          .where(
                                            (item) =>
                                                item.itemUniqueId ==
                                                promoFree.itemUniqueId,
                                          )
                                          .length;
                                    }

                                    return GestureDetector(
                                      onTap: jobIndex != null
                                          ? () {
                                              setState(() {
                                                _selectedIndex = jobIndex!;
                                              });
                                            }
                                          : null,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: jobIndex != null
                                              ? const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFFD54F),
                                                    Color(0xFFFFA000),
                                                  ],
                                                )
                                              : null,
                                          color: jobIndex != null
                                              ? null
                                              : Colors.orange.shade100,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.orange.withOpacity(
                                                .35,
                                              ),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              "FREE",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            if (stampDate != null)
                                              Text(
                                                stampDate,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            if (hasPromoFree)
                                              Text(
                                                "($promoFreeCount) Free Taken",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontSize: 7,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.amberAccent,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: _showPromoRules,
                      child: const Text(
                        "Promo Rules",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    /// TOTAL
                    Text(
                      "$promoCounter Load(s) Full Service",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// JOB DETAILS
                    if (_selectedIndex != null && _selectedIndex! < jobs.length)
                      _jobDetailCard(jobs[_selectedIndex!]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _pickupOrdersList(loyalty.cardNumber),
            _jobHistoryList(jobsAll),
          ],
        ),
      ),
    );
  }

  // ================= PICKUP ORDERS =================

  Widget _pickupOrdersList(int cardNumber) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseService.secondaryFirestore
          .collection('loyalty_order_online')
          .where('cardNumber', isEqualTo: cardNumber)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }
        final orders = snapshot.data!.docs
            .map((d) => LoyaltyOrderOnlineModel.fromFirestore(d))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'My Pickup Bookings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),
            ...orders.map((o) => _pickupOrderCard(o)),
          ],
        );
      },
    );
  }

  Widget _pickupOrderCard(LoyaltyOrderOnlineModel o) {
    final statusColor = switch (o.pickupStatus) {
      PickupStatus.queued => Colors.orange,
      PickupStatus.enroute => Colors.blue,
      PickupStatus.done => Colors.green,
    };
    final date = DateFormat('MMM d, yyyy').format(o.scheduleDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.blue.shade100, blurRadius: 8)],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$date · ${o.timeSlot}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.blueGrey,
                  ),
                ),
                if (o.address.isNotEmpty)
                  Text(
                    o.address,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.blueGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              o.pickupStatus.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Widget _jobHistoryList(List<JobModel> jobs) {
    bool foundFirstFalse = false;
    bool foundCode5 = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const Text(
          "Job History",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),

        const SizedBox(height: 8),

        /// HEADER ROW
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "JobId",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Date",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              // Expanded(
              //   flex: 2,
              //   child: Text(
              //     "Status",
              //     style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              //   ),
              // ),
              Expanded(
                flex: 2,
                child: Text(
                  "Stamps",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Payment",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Promo",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        ...jobs.map((job) {
          final DateTime d = job.dateD.toDate();

          bool firstFalseOnly = true;

          if (job.promoErrorCode != 0 && !foundFirstFalse) {
            firstFalseOnly = false; // this is the first false
            foundFirstFalse = true; // remember we already found it
          }

          if (job.promoErrorCode == 5) {
            foundCode5 = true;
          }

          final date =
              "${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}";

          final isPromo = job.promoErrorCode == 0;

          String payment = "Unpaid";
          if (job.paidCash) payment = "Cash";
          if (job.paidGCash) {
            payment = "GCash${job.paidGCashverified ? '' : ' Pending'}";
          }

          String status = "Unknown";

          if (job.dateC.seconds > 0) {
            status = "Completed";
          } else if (job.dateD.seconds > 0) {
            status = "Done";
          } else if (job.dateO.seconds > 0) {
            status = "On-going";
          } else {
            status = "Queue";
          }

          final hasPromoFree = job.items.any(
            (item) => item.itemUniqueId == promoFree.itemUniqueId,
          );
          final promoFreeCount = job.items
              .where((item) => item.itemUniqueId == promoFree.itemUniqueId)
              .length;

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    "#${job.jobId}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(date, style: const TextStyle(fontSize: 12)),
                ),
                // Expanded(
                //   flex: 2,
                //   child: Text(status, style: const TextStyle(fontSize: 12)),
                // ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "${job.promoCounter}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: () {
                    String payment = "Unpaid";
                    Color paymentColor = Colors.red;

                    if (job.paidCash) {
                      payment = "Cash";
                      paymentColor = Colors.black;
                    }
                    if (job.paidGCash) {
                      if (job.paidGCashverified) {
                        payment = "GCash";
                        paymentColor = Colors.black;
                      } else {
                        payment = "GCash Pending";
                        paymentColor = Colors.orange.shade800;
                      }
                    }

                    return Text(
                      payment,
                      style: TextStyle(fontSize: 12, color: paymentColor),
                    );
                  }(),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    foundCode5
                        ? 'stamp lost, due to previous violation'
                        : job.promoErrorCode == 5
                            ? 'stamp lost, due to previous violation'
                            : job.promoErrorCode == 0 && hasPromoFree
                                ? '${getPromoErrorMessage(job.promoErrorCode)} ($promoFreeCount free taken)'
                                : getPromoErrorMessage(job.promoErrorCode),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: foundCode5
                          ? Colors.red
                          : job.promoErrorCode == 0
                              ? Colors.green
                              : job.promoErrorCode == 1
                                  ? Colors.orange.shade800
                                  : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String textJobStatus(JobModel jM) {
    if (jM.processStep == '') {
      if (jM.forSorting) {
        return 'For Sorting';
      }
      if (jM.riderPickup) {
        return 'Rider Pickup';
      }
    } else {
      if (jM.processStep == 'done') {
        if (jM.riderPickup) {
          if (jM.isDeliveredToCustomer) {
            return '${jM.processStep} 🚲 delivered'; // ${DateFormat('MMMM dd, yyyy').format(jM.riderDeliveryDate.toDate())}';
          } else {
            return '${jM.processStep} 🚲 for delivery';
          }
        } else {
          if (jM.isCustomerPickedUp) {
            return '${jM.processStep} 🛒 pickedup'; // ${DateFormat('MMMM dd, yyyy').format(jM.riderDeliveryDate.toDate())}';
          } else {
            return '${jM.processStep} 🛒 wait customer pickup';
          }
        }
      } else {
        return jM.processStep;
      }
    }

    return 'no status';
  }

  Widget _jobDetailCard(JobModel job) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withOpacity(.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow("💼 Job Id", "#${job.jobId}"),
          _detailRow(
            "📅 Date",
            DateFormat('MMMM dd, yyyy').format(job.dateD.toDate()),
          ),
          _detailRow('🫧 Status', textJobStatus(job)),
          _detailRow('⭐ Stamps', '${job.promoCounter}'),
          _detailRow(
            "💳 Payment",
            job.paidCash
                ? "Paid Cash"
                : job.paidGCashverified
                    ? "Paid GCash"
                    : job.paidGCash
                        ? "GCash Pending"
                        : "Unpaid",
          ),
          if (job.remarks != '') _detailRow("✍️ Remarks", job.remarks),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent,
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }
}
