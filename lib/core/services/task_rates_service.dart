import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laundry_firebase/core/services/firebase_service.dart';
import 'package:laundry_firebase/features/employees/models/task_rate_model.dart';

class TaskRatesService {
  static const String CONFIG_PATH = 'config';
  static const String COLLECTION_ID = 'task_rates';

  final FirebaseFirestore _firestore = FirebaseService.employeeFirestore;

  /// Load all task rates from Firestore
  Future<Map<int, TaskRate>> loadAllTaskRates() async {
    try {
      final configRef = _firestore.collection(CONFIG_PATH);
      final snapshot =
          await configRef.doc(COLLECTION_ID).collection('items').get();

      final rates = <int, TaskRate>{};
      for (final doc in snapshot.docs) {
        final taskRate = TaskRate.fromJson(doc.data());
        rates[taskRate.taskId] = taskRate;
      }
      return rates;
    } catch (e) {
      print('Error loading task rates: $e');
      return getDefaultRates();
    }
  }

  /// Get a single task rate
  Future<TaskRate?> getSingleTaskRate(int taskId) async {
    try {
      final configRef = _firestore.collection(CONFIG_PATH);
      final doc = await configRef
          .doc(COLLECTION_ID)
          .collection('items')
          .doc(taskId.toString())
          .get();

      if (!doc.exists) return null;
      return TaskRate.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting task rate: $e');
      return null;
    }
  }

  /// Update a single task rate
  Future<void> updateTaskRate(int taskId, int newRate) async {
    try {
      final configRef = _firestore.collection(CONFIG_PATH);
      final taskRate = getDefaultRates()[taskId];
      if (taskRate != null) {
        await configRef
            .doc(COLLECTION_ID)
            .collection('items')
            .doc(taskId.toString())
            .set({
          'taskId': taskId,
          'label': taskRate.label,
          'rate': newRate,
          'createdAt': Timestamp.now(),
        }, SetOptions(merge: false)); // Don't merge, replace entire doc
      }
    } catch (e) {
      print('Error updating task rate: $e');
      rethrow;
    }
  }

  /// Initialize default rates (only if they don't exist)
  Future<void> initializeDefaultRates() async {
    try {
      final defaults = getDefaultRates();
      final configRef = _firestore.collection(CONFIG_PATH);

      // Check if rates already exist
      final snapshot =
          await configRef.doc(COLLECTION_ID).collection('items').limit(1).get();

      // Only initialize if no rates exist yet
      if (snapshot.docs.isEmpty) {
        for (final entry in defaults.entries) {
          final taskId = entry.key;
          final taskRate = entry.value;
          await configRef
              .doc(COLLECTION_ID)
              .collection('items')
              .doc(taskId.toString())
              .set(taskRate.toJson());
        }
      }
    } catch (e) {
      print('Error initializing default rates: $e');
      rethrow;
    }
  }

  /// Get default rates (fallback)
  static Map<int, TaskRate> getDefaultRates() {
    return {
      1: TaskRate(
        taskId: 1,
        label: 'Sundo c-anne sa school',
        rate: 200,
        createdAt: Timestamp.now(),
      ),
      2: TaskRate(
        taskId: 2,
        label: 'Sundo caito sa school',
        rate: 200,
        createdAt: Timestamp.now(),
      ),
      3: TaskRate(
        taskId: 3,
        label: 'Hatid c-anne kay titser noreen',
        rate: 300,
        createdAt: Timestamp.now(),
      ),
      4: TaskRate(
        taskId: 4,
        label: 'Hatid caito kay titser noreen',
        rate: 300,
        createdAt: Timestamp.now(),
      ),
      5: TaskRate(
        taskId: 5,
        label: 'Sundo c-anne kay titser noreen',
        rate: 150,
        createdAt: Timestamp.now(),
      ),
      6: TaskRate(
        taskId: 6,
        label: 'Sundo caito kay titser noreen',
        rate: 150,
        createdAt: Timestamp.now(),
      ),
      7: TaskRate(
        taskId: 7,
        label: 'Pickup/Delivery',
        rate: 500,
        createdAt: Timestamp.now(),
      ),
    };
  }

  /// Get task label by ID
  static String getTaskLabel(int taskId) {
    final defaults = getDefaultRates();
    return defaults[taskId]?.label ?? 'Task $taskId';
  }
}
