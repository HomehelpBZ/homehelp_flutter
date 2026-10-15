import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hire.dart';
import 'user_service.dart';

// Hiring through the app: the family sends a request with a start date and
// monthly salary, and the housekeeper accepts or declines it. An accepted hire
// is what lets the family review the housekeeper (see firestore.rules).
class HireService {
  final _db = FirebaseFirestore.instance;
  final _users = UserService();

  // Same id format as reviews: one hire per family–housekeeper pair.
  static String hireId(String familyUid, String hkUid) => '${familyUid}_$hkUid';

  // Kinds of hire notice posted into the chat (message 'kind' field).
  static const noticeRequested = 'hireRequested';
  static const noticeAccepted = 'hireAccepted';
  static const noticeDeclined = 'hireDeclined';
  static const noticeCancelled = 'hireCancelled';

  DocumentReference<Map<String, dynamic>> _ref(String familyUid, String hkUid) =>
      _db.collection('hires').doc(hireId(familyUid, hkUid));

  Stream<Hire?> watchHire(String familyUid, String hkUid) {
    return _ref(familyUid, hkUid)
        .snapshots()
        .map((d) => d.exists ? Hire.fromMap(d.data()!) : null);
  }

  // Family sends a hire request. Replaces an earlier declined or cancelled one.
  Future<void> requestHire({
    required String familyUid,
    required String hkUid,
    required String familyName,
    required String hkName,
    required DateTime startDate,
    required int monthlySalary,
    required String noticeText,
  }) async {
    await _ref(familyUid, hkUid).set({
      'familyUid': familyUid,
      'hkUid': hkUid,
      'familyName': familyName,
      'hkName': hkName,
      'startDate': Timestamp.fromDate(startDate),
      'monthlySalary': monthlySalary,
      'status': Hire.pending,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _notice(familyUid, hkUid, familyUid, noticeRequested, noticeText,
        familyName: familyName);
  }

  // Housekeeper accepts or declines a pending request.
  Future<void> respond({
    required String familyUid,
    required String hkUid,
    required bool accept,
    required String noticeText,
  }) async {
    await _ref(familyUid, hkUid).update({
      'status': accept ? Hire.accepted : Hire.declined,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _notice(familyUid, hkUid, hkUid,
        accept ? noticeAccepted : noticeDeclined, noticeText);
  }

  // Either side cancels: a pending request, or an accepted hire before it starts.
  Future<void> cancel({
    required String familyUid,
    required String hkUid,
    required String byUid,
    required String noticeText,
  }) async {
    await _ref(familyUid, hkUid).update({
      'status': Hire.cancelled,
      'cancelledBy': byUid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _notice(familyUid, hkUid, byUid, noticeCancelled, noticeText);
  }

  // Posts a notice into the chat so the other side sees it (and gets an
  // unread badge). The hire is already saved, so a failure here is ignored.
  Future<void> _notice(String familyUid, String hkUid, String senderUid,
      String kind, String text, {String? familyName}) async {
    try {
      await _users.sendMessage(
        familyUid: familyUid,
        hkUid: hkUid,
        senderUid: senderUid,
        text: text,
        familyName: familyName,
        kind: kind,
      );
    } catch (_) {}
  }
}
