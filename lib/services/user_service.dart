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
      ratingAverageField: 0.0,
      ratingCountField: 0,
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
      ..._clearedReview,
    });

    await batch.commit();
  }

  // Back in the admin queue as unreviewed (the security rules require the
  // old reviewer fields cleared when a housekeeper re-submits).
  static final Map<String, dynamic> _clearedReview = {
    'reviewedBy': null,
    'reviewedAt': null,
    'rejectionReason': FieldValue.delete(),
    'rejectionNote': FieldValue.delete(),
  };

  // ── Re-submit after a rejection ──────────────────────────────────────────
  Future<void> resubmitForReview({required String uid}) async {
    final batch = _db.batch();
    batch.update(_db.collection('housekeeperProfiles').doc(uid), {
      'verificationStatus': 'pending_review',
      'resubmittedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      _db.collection('verificationQueue').doc(uid),
      {
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
        ..._clearedReview,
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  // The admin's note on the last rejection, if any.
  Future<String?> getRejectionNote(String uid) async {
    final doc = await _db.collection('verificationQueue').doc(uid).get();
    return doc.data()?['rejectionNote'] as String?;
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

  // ── Favorites ─────────────────────────────────────────────────────────────
  Future<List<String>> getFavoriteIds(String familyUid) async {
    final doc = await _db.collection('familyProfiles').doc(familyUid).get();
    final data = doc.data();
    if (data == null) return [];
    return List<String>.from(data['favoriteHousekeepers'] ?? []);
  }

  Future<void> addFavorite(String familyUid, String hkUid) async {
    await _db.collection('familyProfiles').doc(familyUid).set({
      'favoriteHousekeepers': FieldValue.arrayUnion([hkUid]),
    }, SetOptions(merge: true));
  }

  Future<void> removeFavorite(String familyUid, String hkUid) async {
    await _db.collection('familyProfiles').doc(familyUid).set({
      'favoriteHousekeepers': FieldValue.arrayRemove([hkUid]),
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getFavoriteHks(String familyUid) async {
    final ids = await getFavoriteIds(familyUid);
    if (ids.isEmpty) return [];
    final results = <Map<String, dynamic>>[];
    // Firestore whereIn supports max 10 per query
    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
      final snap = await _db
          .collection('housekeeperProfiles')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        results.add({'id': doc.id, ...doc.data()});
      }
    }
    return results;
  }

  // ── Reviews ───────────────────────────────────────────────────────────────
  // Rating fields on housekeeperProfiles (set to 0 when the profile is created).
  static const ratingAverageField = 'ratingAverage';
  static const ratingCountField = 'ratingCount';

  // Thrown by submitReview when this family already reviewed this housekeeper.
  static const alreadyReviewedCode = 'already-reviewed';

  // One review per family per housekeeper; firestore.rules relies on this id.
  static String reviewId(String familyUid, String hkUid) => '${familyUid}_$hkUid';

  // Rating fields after adding one star rating to a housekeeper profile.
  // The average is stored unrounded so it stays exact; round it for display.
  static Map<String, dynamic> ratingAfterReview(
      Map<String, dynamic>? profile, int starRating) {
    final count = (profile?[ratingCountField] as num?)?.toInt() ?? 0;
    final avg = (profile?[ratingAverageField] as num?)?.toDouble() ?? 0.0;
    final newCount = count + 1;
    return {
      ratingAverageField: (avg * count + starRating) / newCount,
      ratingCountField: newCount,
    };
  }

  // "4.7" style text for a profile's rating, or "0" if it has none yet.
  static String ratingText(Map<String, dynamic>? profile) {
    final avg = (profile?[ratingAverageField] as num?)?.toDouble() ?? 0.0;
    return avg == 0 ? '0' : avg.toStringAsFixed(1);
  }

  Future<bool> hasReviewed(String familyUid, String hkUid) async =>
      (await _db.collection('reviews').doc(reviewId(familyUid, hkUid)).get())
          .exists;

  // Saves the review and updates the housekeeper's rating in one transaction.
  Future<void> submitReview({
    required String hkUid,
    required String familyUid,
    required String familyName,
    required int starRating,
    required bool? wouldHireAgain,
    required List<String> tags,
    required String reviewText,
  }) async {
    final reviewRef = _db.collection('reviews').doc(reviewId(familyUid, hkUid));
    final hkRef = _db.collection('housekeeperProfiles').doc(hkUid);
    await _db.runTransaction((tx) async {
      final existing = await tx.get(reviewRef);
      if (existing.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: alreadyReviewedCode,
          message: 'You already reviewed this housekeeper.',
        );
      }
      final hkSnap = await tx.get(hkRef);
      tx.set(reviewRef, {
        'hkUid': hkUid,
        'familyUid': familyUid,
        'familyName': familyName,
        'starRating': starRating,
        'wouldHireAgain': wouldHireAgain,
        'tags': tags,
        'reviewText': reviewText,
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(hkRef, ratingAfterReview(hkSnap.data(), starRating));
    });
  }

  // Rating fields after taking one star rating out (an admin removed it).
  static Map<String, dynamic> ratingAfterRemoval(
      Map<String, dynamic>? profile, int starRating) {
    final count = (profile?[ratingCountField] as num?)?.toInt() ?? 0;
    final avg = (profile?[ratingAverageField] as num?)?.toDouble() ?? 0.0;
    if (count <= 1) return {ratingAverageField: 0.0, ratingCountField: 0};
    final newCount = count - 1;
    return {
      ratingAverageField: (avg * count - starRating) / newCount,
      ratingCountField: newCount,
    };
  }

  // Rating fields after a family changes their stars from [oldStars].
  static Map<String, dynamic> ratingAfterEdit(
      Map<String, dynamic>? profile, int oldStars, int newStars) {
    final count = (profile?[ratingCountField] as num?)?.toInt() ?? 0;
    final avg = (profile?[ratingAverageField] as num?)?.toDouble() ?? 0.0;
    if (count == 0) return {ratingAverageField: avg, ratingCountField: 0};
    return {
      ratingAverageField: (avg * count - oldStars + newStars) / count,
      ratingCountField: count,
    };
  }

  // Families can edit their review, and housekeepers their reply, for this
  // long. firestore.rules has the same 48 hours.
  static const editWindow = Duration(hours: 48);

  // Whether something written at [writtenAt] can still be edited.
  static bool canEdit(Timestamp? writtenAt, DateTime now) =>
      writtenAt != null && now.isBefore(writtenAt.toDate().add(editWindow));

  // Family edits their review (within editWindow). Reviews can't be deleted.
  Future<void> updateReview({
    required String familyUid,
    required String hkUid,
    required int starRating,
    required bool? wouldHireAgain,
    required List<String> tags,
    required String reviewText,
  }) async {
    final reviewRef = _db.collection('reviews').doc(reviewId(familyUid, hkUid));
    final hkRef = _db.collection('housekeeperProfiles').doc(hkUid);
    await _db.runTransaction((tx) async {
      final review = await tx.get(reviewRef);
      final hkSnap = await tx.get(hkRef);
      final oldStars = (review.data()!['starRating'] as num).toInt();
      tx.update(reviewRef, {
        'starRating': starRating,
        'wouldHireAgain': wouldHireAgain,
        'tags': tags,
        'reviewText': reviewText,
        'editedAt': FieldValue.serverTimestamp(),
      });
      if (oldStars != starRating) {
        tx.update(hkRef, ratingAfterEdit(hkSnap.data(), oldStars, starRating));
      }
    });
  }

  // Admin hides an abusive review and takes it out of the rating. The review
  // stays stored, so the family can't simply post it again.
  Future<void> removeReview({
    required String reviewDocId,
    required String adminUid,
    required String reason,
  }) async {
    final reviewRef = _db.collection('reviews').doc(reviewDocId);
    await _db.runTransaction((tx) async {
      final review = await tx.get(reviewRef);
      final data = review.data();
      if (data == null || data['removed'] == true) return;
      final hkRef = _db.collection('housekeeperProfiles').doc(data['hkUid'] as String);
      final hkSnap = await tx.get(hkRef);
      tx.update(reviewRef, {
        'removed': true,
        'removedAt': FieldValue.serverTimestamp(),
        'removedBy': adminUid,
        'removedReason': reason,
      });
      tx.update(hkRef,
          ratingAfterRemoval(hkSnap.data(), (data['starRating'] as num).toInt()));
    });
  }

  // Whether this user is listed in /admins (added in the Firebase console).
  Future<bool> isAdmin(String uid) async {
    try {
      return (await _db.collection('admins').doc(uid).get()).exists;
    } catch (_) {
      return false;
    }
  }

  // Whether this account signed up as [role] ('family' or 'housekeeper').
  // Checks the roles list on /users, then the role's profile doc.
  Future<bool> hasRole(String uid, String role) async {
    final user = await _db.collection('users').doc(uid).get();
    final roles = (user.data()?['roles'] as List?)?.cast<String>() ?? const [];
    if (roles.contains(role)) return true;
    final profiles = role == 'family' ? 'familyProfiles' : 'housekeeperProfiles';
    return (await _db.collection(profiles).doc(uid).get()).exists;
  }

  // Whether this account may sign in as [role]. Only accounts known to be the
  // other role are refused; ones with no user or profile doc (a sign-up whose
  // save failed) are let through.
  Future<bool> canSignInAs(String uid, String role) async {
    if (await hasRole(uid, role)) return true;
    final other = role == 'family' ? 'housekeeper' : 'family';
    return !await hasRole(uid, other);
  }

  // Housekeeper's one reply to a review, editable within editWindow.
  static const responseMaxLength = 300;

  Future<void> respondToReview(String reviewDocId, String text) {
    return _db.collection('reviews').doc(reviewDocId).update({
      'response': {
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      },
    });
  }

  // Keeps the reply's original date; firestore.rules checks it.
  Future<void> editResponse(
      String reviewDocId, String text, Timestamp repliedAt) {
    return _db.collection('reviews').doc(reviewDocId).update({
      'response': {
        'text': text,
        'createdAt': repliedAt,
        'editedAt': FieldValue.serverTimestamp(),
      },
    });
  }

  // Reviews hidden by an admin aren't shown anywhere.
  static List<Map<String, dynamic>> visibleReviews(
          List<Map<String, dynamic>> reviews) =>
      reviews.where((r) => r['removed'] != true).toList();

  // All visible reviews of a housekeeper, newest first.
  Stream<List<Map<String, dynamic>>> watchHkReviews(String hkUid) {
    return _db
        .collection('reviews')
        .where('hkUid', isEqualTo: hkUid)
        .snapshots()
        .map((snap) => sortNewestFirst(
            visibleReviews(snap.docs.map((d) => {'id': d.id, ...d.data()}).toList()),
            field: 'createdAt'));
  }

  // Every review, newest first, for the admin panel (removed ones included).
  Stream<List<Map<String, dynamic>>> watchAllReviews() {
    return _db.collection('reviews').snapshots().map((snap) => sortNewestFirst(
        snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        field: 'createdAt'));
  }

  // This family's review of this housekeeper (null if none).
  Stream<Map<String, dynamic>?> watchReview(String familyUid, String hkUid) {
    return _db
        .collection('reviews')
        .doc(reviewId(familyUid, hkUid))
        .snapshots()
        .map((d) => d.exists ? {'id': d.id, ...d.data()!} : null);
  }

  // ── Messaging ─────────────────────────────────────────────────────────────
  String _chatId(String familyUid, String hkUid) {
    final ids = [familyUid, hkUid]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> sendMessage({
    required String familyUid,
    required String hkUid,
    required String senderUid,
    required String text,
    String? familyName,
    String? hkName,
    String? kind, // set for hire notices (see HireService)
  }) async {
    final chatId = _chatId(familyUid, hkUid);
    final batch = _db.batch();
    // Add message
    final msgRef = _db.collection('chats').doc(chatId).collection('messages').doc();
    batch.set(msgRef, {
      'senderUid': senderUid,
      'text': text,
      if (kind != null) 'kind': kind,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Update chat thread metadata
    final chatRef = _db.collection('chats').doc(chatId);
    batch.set(
      chatRef,
      chatThreadUpdate(
        familyUid: familyUid,
        hkUid: hkUid,
        senderUid: senderUid,
        text: text,
        familyName: familyName,
        hkName: hkName,
      ),
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  // Chat thread fields, shared by the writer and both message lists.
  static const unreadFamilyField = 'unreadFamily';
  static const unreadHkField = 'unreadHk';

  // Thread metadata written (merged) on every message.
  static Map<String, dynamic> chatThreadUpdate({
    required String familyUid,
    required String hkUid,
    required String senderUid,
    required String text,
    String? familyName,
    String? hkName,
  }) {
    return {
      'familyUid': familyUid,
      'hkUid': hkUid,
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      // The recipient gets one more unread; the sender has read everything.
      unreadFamilyField: senderUid == hkUid ? FieldValue.increment(1) : 0,
      unreadHkField: senderUid == familyUid ? FieldValue.increment(1) : 0,
      // Names shown in each side's message list
      if (familyName != null && familyName.isNotEmpty) 'familyName': familyName,
      if (hkName != null && hkName.isNotEmpty) 'hkName': hkName,
    };
  }

  // ── Own display name (for chat threads) ──────────────────────────────────
  Future<String?> getFamilyName(String uid) async =>
      (await getFamilyProfile(uid))?['fullName'] as String?;

  Future<String?> getHkName(String uid) async =>
      (await getHkProfile(uid))?['fullName'] as String?;

  Stream<QuerySnapshot> getMessages(String familyUid, String hkUid) {
    final chatId = _chatId(familyUid, hkUid);
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }

  // NOTE: sorted client-side to avoid a Firestore composite index
  Future<List<Map<String, dynamic>>> getFamilyChats(String familyUid) async {
    final snap = await _db.collection('chats')
        .where('familyUid', isEqualTo: familyUid)
        .get();
    return sortNewestFirst(snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<List<Map<String, dynamic>>> getHkChats(String hkUid) async {
    final snap = await _db.collection('chats')
        .where('hkUid', isEqualTo: hkUid)
        .get();
    return sortNewestFirst(snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // ── Unread badge ──────────────────────────────────────────────────────────
  // Live total of unread messages across all of this user's chats.
  Stream<int> unreadCount(String uid, {required bool isFamily}) {
    return _db
        .collection('chats')
        .where(isFamily ? 'familyUid' : 'hkUid', isEqualTo: uid)
        .snapshots()
        .map((snap) => sumUnread(snap.docs.map((d) => d.data()),
            isFamily ? unreadFamilyField : unreadHkField));
  }

  // Housekeeper's chats, live (for the home screen notifications).
  Stream<List<Map<String, dynamic>>> watchHkChats(String hkUid) {
    return _db
        .collection('chats')
        .where('hkUid', isEqualTo: hkUid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  static int sumUnread(Iterable<Map<String, dynamic>> chats, String field) =>
      chats.fold(0, (sum, c) {
        final n = (c[field] as num?)?.toInt() ?? 0;
        return sum + (n > 0 ? n : 0);
      });

  static List<Map<String, dynamic>> sortNewestFirst(
      List<Map<String, dynamic>> chats, {String field = 'lastMessageAt'}) {
    int millis(Map<String, dynamic> c) =>
        (c[field] as Timestamp?)?.millisecondsSinceEpoch ?? 0;
    return chats..sort((a, b) => millis(b).compareTo(millis(a)));
  }

  Future<void> markChatRead(String familyUid, String hkUid, bool isFamily) async {
    final chatId = _chatId(familyUid, hkUid);
    await _db.collection('chats').doc(chatId).update({
      isFamily ? unreadFamilyField : unreadHkField: 0,
    });
  }

  // ── Password reset ────────────────────────────────────────────────────────
  Future<void> updatePassword(String uid, String newPassword) async {
    // Password is stored as email/password auth — update via Firebase Auth
    // Called after OTP verification confirms identity
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

}