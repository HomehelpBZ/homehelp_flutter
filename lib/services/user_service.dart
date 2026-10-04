import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Current user ──────────────────────────────────────────────────────────
  String? get currentUid => _auth.currentUser?.uid;

  // ── Create user document after signup ────────────────────────────────────
  Future<void> createUserDocument({
    required String uid,
    required String phone,
    required String fullName,
    required String role,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'phone': phone,
      'fullName': fullName,
      'roles': [role],
      'adminLevel': null,
      'status': 'active',
      'verified': false,
      'country': 'Ethiopia',
      'city': 'Addis Ababa',
      'language': 'am',
      'currency': 'ETB',
      'photoUrl': null,
      'isDeleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'createdBy': uid,
    });
  }

  // ── Create family profile ─────────────────────────────────────────────────
  Future<void> createFamilyProfile({
    required String uid,
    required String fullName,
    required String phone,
  }) async {
    await _db.collection('familyProfiles').doc(uid).set({
      'userId': uid,
      'fullName': fullName,
      'phone': phone,
      'address': null,
      'children': null,
      'pets': null,
      'preferredLanguage': 'am',
      'favoriteHousekeepers': [],
      'bio': null,
      'emergencyContact': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Create HK profile (initial) ───────────────────────────────────────────
  Future<void> createHousekeeperProfile({
    required String uid,
    required String phone,
    required String fullName,
  }) async {
    await _db.collection('housekeeperProfiles').doc(uid).set({
      'userId': uid,
      'fullName': fullName,
      'phone': phone,
      'bio': null,
      'experienceYears': null,
      'rates': {
        'monthlyRate': null,
        'currency': 'ETB',
        'period': 'monthly',
      },
      'availability': {
        'mon': true,
        'tue': true,
        'wed': true,
        'thu': true,
        'fri': true,
        'sat': false,
        'sun': false,
        'startTime': null,
        'endTime': null,
        'arrangement': null,
      },
      'skills': [],
      'languages': [],
      'education': null,
      'ratingAverage': 0.0,
      'ratingCount': 0,
      'jobsCompleted': 0,
      'responseRate': 0.0,
      'profileCompleted': false,
      'isVerified': false,
      'verificationStatus': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Update HK profile after Step 1 ───────────────────────────────────────
  Future<void> updateHkStep1({
    required String uid,
    required String fullName,
    required String phone,
    required String region,
    required String ageRange,
    required String gender,
    String? photoUrl,
  }) async {
    await _db.collection('housekeeperProfiles').doc(uid).update({
      'fullName': fullName,
      'phone': phone,
      'region': region,
      'ageRange': ageRange,
      'gender': gender,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Update HK profile after Step 2 ───────────────────────────────────────
  Future<void> updateHkStep2({
    required String uid,
    required String education,
    required String experienceYears,
    String? workHistory,
  }) async {
    await _db.collection('housekeeperProfiles').doc(uid).update({
      'education': education,
      'experienceYears': experienceYears,
      'workHistory': workHistory,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Update HK profile after Step 3 ───────────────────────────────────────
  Future<void> updateHkStep3({
    required String uid,
    required List<String> skills,
    required List<String> languages,
  }) async {
    await _db.collection('housekeeperProfiles').doc(uid).update({
      'skills': skills,
      'languages': languages,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Update HK profile after Step 4 ───────────────────────────────────────
  Future<void> updateHkStep4({
    required String uid,
    required List<String> jobTypes,
    required String arrangement,
    required Map<String, bool> workingDays,
    required List<String> preferredAreas,
    required String expectedSalary,
  }) async {
    await _db.collection('housekeeperProfiles').doc(uid).update({
      'jobTypes': jobTypes,
      'availability': {
        'mon': workingDays['mon'] ?? true,
        'tue': workingDays['tue'] ?? true,
        'wed': workingDays['wed'] ?? true,
        'thu': workingDays['thu'] ?? true,
        'fri': workingDays['fri'] ?? true,
        'sat': workingDays['sat'] ?? false,
        'sun': workingDays['sun'] ?? false,
        'arrangement': arrangement,
      },
      'preferredAreas': preferredAreas,
      'rates': {
        'monthlyRate': expectedSalary,
        'currency': 'ETB',
        'period': 'monthly',
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Save HK documents after Step 5 ───────────────────────────────────────
  Future<void> saveHkDocuments({
    required String uid,
    required String faydaId,
    String? frontIdUrl,
    String? backIdUrl,
    String? selfieUrl,
  }) async {
    final batch = _db.batch();

    final profileRef = _db.collection('housekeeperProfiles').doc(uid);
    batch.update(profileRef, {
      'faydaId': faydaId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (frontIdUrl != null) {
      final frontRef = _db
          .collection('users')
          .doc(uid)
          .collection('documents')
          .doc('frontId');
      batch.set(frontRef, {
        'documentId': 'frontId',
        'documentType': 'national_id_front',
        'fileUrl': frontIdUrl,
        'status': 'pending',
        'reviewedBy': null,
        'reviewedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // ── Save guarantor after Step 6 ──────────────────────────────────────────
  Future<void> saveGuarantor({
    required String uid,
    required String fullName,
    required String phone,
    required String relationship,
  }) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('guarantors')
        .doc('guarantor1')
        .set({
      'fullName': fullName,
      'phone': phone,
      'relationship': relationship,
      'verificationStatus': 'pending',
      'verifiedBy': null,
      'verifiedAt': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('housekeeperProfiles').doc(uid).update({
      'guarantorAdded': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Add to verification queue ─────────────────────────────────────────────
  Future<void> addToVerificationQueue({required String uid}) async {
    await _db.collection('verificationQueue').doc(uid).set({
      'queueId': uid,
      'housekeeperId': uid,
      'submittedAt': FieldValue.serverTimestamp(),
      'priority': 'normal',
      'status': 'pending_guarantor',
      'assignedAdminId': null,
      'reviewedAt': null,
      'reviewedBy': null,
    });

    await _db.collection('housekeeperProfiles').doc(uid).update({
      'profileCompleted': true,
      'verificationStatus': 'pending_guarantor',
      'submittedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Set pending_guarantor status ──────────────────────────────────────────
  Future<void> setPendingGuarantorStatus({required String uid}) async {
    await _db.collection('housekeeperProfiles').doc(uid).update({
      'verificationStatus': 'pending_guarantor',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('verificationQueue').doc(uid).update({
      'status': 'pending_guarantor',
    });
  }

  // ── Save guarantor ID (after profile submission) ──────────────────────────
  Future<void> saveGuarantorId({
    required String uid,
    required String idType,
    String? faydaId,
  }) async {
    final batch = _db.batch();

    final guarantorRef = _db
        .collection('users')
        .doc(uid)
        .collection('guarantors')
        .doc('guarantor1');
    batch.update(guarantorRef, {
      'idType': idType,
      'faydaId': faydaId,
      'idSubmittedAt': FieldValue.serverTimestamp(),
    });

    final profileRef = _db.collection('housekeeperProfiles').doc(uid);
    batch.update(profileRef, {
      'verificationStatus': 'pending_review',
      'guarantorIdSubmitted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final queueRef = _db.collection('verificationQueue').doc(uid);
    batch.update(queueRef, {
      'status': 'pending',
      'guarantorIdSubmittedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ── Update bio ───────────────────────────────────────────────────────────
  Future<void> updateHkBio({
    required String uid,
    required String bio,
  }) async {
    await _db.collection('housekeeperProfiles').doc(uid).update({
      'bio': bio,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Get guarantor ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getGuarantor(String uid) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('guarantors')
        .doc('guarantor1')
        .get();
    return doc.exists ? doc.data() : null;
  }

  // ── Get HK profile ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getHkProfile(String uid) async {
    final doc =
        await _db.collection('housekeeperProfiles').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // ── Get family profile ────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getFamilyProfile(String uid) async {
    final doc = await _db.collection('familyProfiles').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // ── Update last login ─────────────────────────────────────────────────────
  Future<void> updateLastLogin(String uid) async {
    await _db.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  // ── Post a job ────────────────────────────────────────────────────────────
  Future<String> postJob({
    required String familyUid,
    required String jobType,
    required String arrangement,
    required Map<String, bool> workingDays,
    required String area,
    required String salary,
    required String description,
    String? startDate,
  }) async {
    final ref = _db.collection('jobs').doc();
    await ref.set({
      'jobId': ref.id,
      'familyId': familyUid,
      'jobType': jobType,
      'arrangement': arrangement,
      'workingDays': workingDays,
      'area': area,
      'salary': salary,
      'description': description,
      'startDate': startDate,
      'status': 'open',
      'interestedHks': [],
      'interestedCount': 0,
      'postedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // ── Get family jobs ───────────────────────────────────────────────────────
  // Filter client-side to avoid Firestore index requirement
  // When migrating to PostgreSQL, use WHERE family_id = uid ORDER BY posted_at DESC
  Future<List<Map<String, dynamic>>> getFamilyJobs(String familyUid) async {
    final snap = await _db.collection('jobs').get();
    return snap.docs
        .map((d) => {'id': d.id, ...d.data()})
        .where((d) => d['familyId'] == familyUid)
        .toList();
  }

  // ── Get all open jobs (for HK job board) ─────────────────────────────────
  // NOTE: orderBy removed to avoid Firestore composite index — add back when migrating
  Future<List<Map<String, dynamic>>> getOpenJobs() async {
    final snap = await _db
        .collection('jobs')
        .where('status', isEqualTo: 'open')
        .get();
    return snap.docs
        .map((d) => {'id': d.id, ...d.data()})
        .toList();
  }

  // ── Express interest in a job ─────────────────────────────────────────────
  Future<void> expressInterest({
    required String jobId,
    required String hkUid,
  }) async {
    await _db.collection('jobs').doc(jobId).update({
      'interestedHks': FieldValue.arrayUnion([hkUid]),
      'interestedCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Delete a job ──────────────────────────────────────────────────────────
  Future<void> deleteJob(String jobId) async {
    await _db.collection('jobs').doc(jobId).delete();
  }

  // ── Update job ────────────────────────────────────────────────────────────
  Future<void> updateJob({
    required String jobId,
    required String jobType,
    required String arrangement,
    required Map<String, bool> workingDays,
    required String area,
    required String salary,
    required String description,
    String? startDate,
  }) async {
    await _db.collection('jobs').doc(jobId).update({
      'jobType': jobType,
      'arrangement': arrangement,
      'workingDays': workingDays,
      'area': area,
      'salary': salary,
      'description': description,
      'startDate': startDate,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

}