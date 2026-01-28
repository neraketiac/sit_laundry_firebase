import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/models/JobsModel.dart';
import 'package:laundry_firebase/models/otheritemmodel.dart';

class JobsModelRepository {
  JobsModelRepository._();
  static final JobsModelRepository instance = JobsModelRepository._();

  /// Single job (nullable until set)
  JobsModel? jobsModel;

  Future<void> reset() async {
    clear();
  }

  void setSuppliesCurrent(JobsModel jobsModel) {
    jobsModel = jobsModel;
  }

  void clear() {
    // jobsModel = JobsModel.makeEmpty();
    //jobsModel = null;
    jobsModel = JobsModel(
        docId: '',
        dateQ: Timestamp.now(),
        needOn: Timestamp.now(),
        dateO: Timestamp.now(),
        paidD: Timestamp.now(),
        dateD: Timestamp.now(),
        createdBy: '',
        currentEmpId: '',
        customerId: 0,
        customerName: '',
        perKilo: true,
        perLoad: false,
        finalKilo: 0,
        finalLoad: 0,
        finalPrice: 0,
        regular: true,
        sayosabon: false,
        addOn: false,
        fold: true,
        mix: true,
        basket: 0,
        ebag: 0,
        sako: 0,
        unpaid: true,
        paidcash: false,
        paidgcash: false,
        paidgcashverified: false,
        paymentReceivedBy: '',
        remarks: '',
        items: [OtherItemModel.makeEmpty()],
        processStep: '',
        forDisposal: false,
        disposed: false);
  }
}
