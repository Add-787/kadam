import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/user_model.dart';
import '../models/daily_step_record.dart';

@lazySingleton
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User Profile
  Future<void> createUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<UserModel?> streamUserProfile(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Step Records
  Future<void> saveStepRecord(DailyStepRecord record) async {
    await _db.collection('dailySteps').doc(record.id).set(record.toMap(), SetOptions(merge: true));
  }

  Stream<List<DailyStepRecord>> streamUserSteps(String userId, String startDate, String endDate) {
    return _db
        .collection('dailySteps')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startDate)
        .where('date', isLessThanOrEqualTo: endDate)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => DailyStepRecord.fromMap(doc.data(), doc.id)).toList());
  }

  // Groups
  Future<void> createGroup(String name, String description, String creatorId) async {
    await _db.collection('groups').add({
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'createdAt': FieldValue.serverTimestamp(),
      'memberIds': [creatorId],
    });
  }
}
