import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Get pending verification queue ────────────────────────────────────────
  Stream<QuerySnapshot> getPendingQueue() {
    // NOTE: orderBy('submittedAt') removed to avoid Firestore composite index requirement.
    // When migrating to Supabase or PostgreSQL, add ORDER BY submitted_at ASC back.
    return _db
        .collection('verificationQueue')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // ── Get HK profile details ────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getHkProfile(String uid) async {
    final doc = await _db.collection('housekeeperProfiles').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // ── Get guarantor details ─────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getGuarantor(String uid) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('guarantors')
        .doc('guarantor1')
        .get();
    return snap.exists ? snap.data() : null;
  }

  // ── Approve HK ────────────────────────────────────────────────────────────
  Future<void> approveHk({
    required String uid,
    required String adminId,
  }) async {
    final batch = _db.batch();

    // Update verification queue
    final queueRef = _db.collection('verificationQueue').doc(uid);
    batch.update(queueRef, {
      'status': 'approved',
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': adminId,
    });

    // Update housekeeper profile
    final profileRef = _db.collection('housekeeperProfiles').doc(uid);
    batch.update(profileRef, {
      'verificationStatus': 'approved',
      'isVerified': true,
      'approvedAt': FieldValue.serverTimestamp(),
      'approvedBy': adminId,
    });

    // Update user document
    final userRef = _db.collection('users').doc(uid);
    batch.update(userRef, {
      'verified': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Log admin action
    final actionRef = _db.collection('adminActions').doc();
    batch.set(actionRef, {
      'adminId': adminId,
      'targetUserId': uid,
      'actionType': 'approve_housekeeper',
      'reason': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ── Reject HK ─────────────────────────────────────────────────────────────
  Future<void> rejectHk({
    required String uid,
    required String adminId,
    required String reason,
    String? note,
  }) async {
    final batch = _db.batch();

    // Update verification queue
    final queueRef = _db.collection('verificationQueue').doc(uid);
    batch.update(queueRef, {
      'status': 'rejected',
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': adminId,
      'rejectionReason': reason,
      'rejectionNote': note,
    });

    // Update housekeeper profile
    final profileRef = _db.collection('housekeeperProfiles').doc(uid);
    batch.update(profileRef, {
      'verificationStatus': 'rejected',
      'isVerified': false,
      'rejectedAt': FieldValue.serverTimestamp(),
      'rejectedBy': adminId,
      'rejectionReason': reason,
    });

    // Log admin action
    final actionRef = _db.collection('adminActions').doc();
    batch.set(actionRef, {
      'adminId': adminId,
      'targetUserId': uid,
      'actionType': 'reject_housekeeper',
      'reason': reason,
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ── Get stats ─────────────────────────────────────────────────────────────
  Future<Map<String, int>> getStats() async {
    final pending = await _db
        .collection('verificationQueue')
        .where('status', isEqualTo: 'pending')
        .count()
        .get();

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final approved = await _db
        .collection('verificationQueue')
        .where('status', isEqualTo: 'approved')
        .where('reviewedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .count()
        .get();

    final rejected = await _db
        .collection('verificationQueue')
        .where('status', isEqualTo: 'rejected')
        .where('reviewedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .count()
        .get();

    final total = await _db
        .collection('housekeeperProfiles')
        .where('verificationStatus', isEqualTo: 'approved')
        .count()
        .get();

    return {
      'pending': pending.count ?? 0,
      'approvedToday': approved.count ?? 0,
      'rejectedToday': rejected.count ?? 0,
      'totalActive': total.count ?? 0,
    };
  }
}