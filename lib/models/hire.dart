import 'package:cloud_firestore/cloud_firestore.dart';

// A family hiring a housekeeper through the app. Stored at
// hires/{familyUid}_{hkUid} (one per pair); firestore.rules checks it before
// a review is allowed.
class Hire {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const declined = 'declined';
  static const cancelled = 'cancelled';

  // Families can review this long after the start date.
  // firestore.rules has the same 3 days.
  static const reviewWait = Duration(days: 3);

  final String familyUid;
  final String hkUid;
  final String familyName;
  final String hkName;
  final DateTime startDate;
  final int monthlySalary;
  final String status;
  final String? cancelledBy;

  const Hire({
    required this.familyUid,
    required this.hkUid,
    this.familyName = '',
    this.hkName = '',
    required this.startDate,
    required this.monthlySalary,
    required this.status,
    this.cancelledBy,
  });

  factory Hire.fromMap(Map<String, dynamic> d) => Hire(
        familyUid: d['familyUid'] as String? ?? '',
        hkUid: d['hkUid'] as String? ?? '',
        familyName: d['familyName'] as String? ?? '',
        hkName: d['hkName'] as String? ?? '',
        startDate: (d['startDate'] as Timestamp?)?.toDate() ?? DateTime(2000),
        monthlySalary: (d['monthlySalary'] as num?)?.toInt() ?? 0,
        status: d['status'] as String? ?? pending,
        cancelledBy: d['cancelledBy'] as String?,
      );

  bool get isPending => status == pending;
  bool get isAccepted => status == accepted;

  // A declined or cancelled hire doesn't block a new request.
  bool get isOpen => isPending || isAccepted;

  // Pending requests can always be withdrawn; accepted hires only before
  // the start date.
  bool canCancel(DateTime now) =>
      isPending || (isAccepted && now.isBefore(startDate));

  DateTime get reviewOpensAt => startDate.add(reviewWait);

  bool canReview(DateTime now) => isAccepted && !now.isBefore(reviewOpensAt);

  // The Hire button only appears once both sides have sent a message, so a
  // hire can't be the first thing that happens in a chat.
  static bool bothHaveMessaged(
      Iterable<Map<String, dynamic>> messages, String familyUid, String hkUid) {
    var family = false, hk = false;
    for (final m in messages) {
      if (m['kind'] != null) continue; // hire notices don't count
      if (m['senderUid'] == familyUid) family = true;
      if (m['senderUid'] == hkUid) hk = true;
    }
    return family && hk;
  }
}
