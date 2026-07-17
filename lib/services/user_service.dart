import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Current user ──────────────────────────────────────────────────────────
  String? get currentUid => _auth.currentUser?.uid;

  // ── Create user document after signup ────────────────────────────────────
  // Called immediately after OTP verification for both Family and HK
  Future<void> createUserDocument({
    required String uid,
    required String phone,
    required String fullName,
    required String role, // 'family' or 'housekeeper'
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

  // ── Create HK profile (initial — after OTP) ───────────────────────────────
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

    // Save Fayda ID to profile
    final profileRef = _db.collection('housekeeperProfiles').doc(uid);
    batch.update(profileRef, {
      'faydaId': faydaId,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Save documents to subcollection
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

    if (backIdUrl != null) {
      final backRef = _db
          .collection('users')
          .doc(uid)
          .collection('documents')
          .doc('backId');
      batch.set(backRef, {
        'documentId': 'backId',
        'documentType': 'national_id_back',
        'fileUrl': backIdUrl,
        'status': 'pending',
        'reviewedBy': null,
        'reviewedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    if (selfieUrl != null) {
      final selfieRef = _db
          .collection('users')
          .doc(uid)
          .collection('documents')
          .doc('selfie');
      batch.set(selfieRef, {
        'documentId': 'selfie',
        'documentType': 'selfie_with_id',
        'fileUrl': selfieUrl,
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
    // Save guarantor to subcollection
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

    // Update HK profile - mark guarantor as added
    await _db.collection('housekeeperProfiles').doc(uid).update({
      'guarantorAdded': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Add to verification queue after Step 6 ───────────────────────────────
  Future<void> addToVerificationQueue({required String uid}) async {
    await _db.collection('verificationQueue').doc(uid).set({
      'queueId': uid,
      'housekeeperId': uid,
      'submittedAt': FieldValue.serverTimestamp(),
      'priority': 'normal',
      'status': 'pending',
      'assignedAdminId': null,
      'reviewedAt': null,
      'reviewedBy': null,
    });

    // Mark profile as submitted
    await _db.collection('housekeeperProfiles').doc(uid).update({
      'profileCompleted': true,
      'verificationStatus': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Get HK profile ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getHkProfile(String uid) async {
    final doc =
        await _db.collection('housekeeperProfiles').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // ── Get family profile ────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getFamilyProfile(String uid) async {
    final doc =
        await _db.collection('familyProfiles').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // ── Update last login ─────────────────────────────────────────────────────
  Future<void> updateLastLogin(String uid) async {
    await _db.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }
}