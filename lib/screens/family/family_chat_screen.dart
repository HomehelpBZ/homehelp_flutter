import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../models/housekeeper.dart';
import '../../services/user_service.dart';
import '../../models/hire.dart';
import '../../services/hire_service.dart';
import '../../widgets/hire_widgets.dart';
import 'review_flow_screen.dart';
import 'hire_form_screen.dart';

class FamilyChatScreen extends StatefulWidget {
  final Housekeeper hk;
  const FamilyChatScreen({super.key, required this.hk});

  @override
  State<FamilyChatScreen> createState() => _FamilyChatScreenState();
}

class _FamilyChatScreenState extends State<FamilyChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _svc = UserService();
  bool _sending = false;
  String? _familyName;
  late final Stream<QuerySnapshot> _messages;
  Stream<Hire?>? _hire;
  Stream<Map<String, dynamic>?>? _review;
  // The Hire button only shows once both sides have written something.
  bool _bothMessaged = false;

  String get _familyUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _messages = _svc.getMessages(_familyUid, widget.hk.id);
    _svc
        .getFamilyName(_familyUid)
        .then((name) => _familyName = name, onError: (_) {});
    if (_familyUid.isNotEmpty) {
      _markRead();
      _hire = HireService().watchHire(_familyUid, widget.hk.id);
      _review = _svc.watchReview(_familyUid, widget.hk.id);
    }
  }

  String get _firstName => widget.hk.name.split(' ').first;

  void _openHireForm() => Navigator.push(context,
      MaterialPageRoute(builder: (_) => HireFormScreen(hk: widget.hk)));

  Future<void> _cancelHire(Hire hire) async {
    final s = LanguageProvider.strings(context);
    final ok = await showConfirmDialog(
      context,
      title: s.cancelHireTitle,
      body: '${hireSummaryText(hire, s)}\n\n${s.cancelHireNote}',
      confirmLabel: s.yesCancel,
      cancelLabel: s.keepIt,
      destructive: true,
    );
    if (!ok) return;
    try {
      await HireService().cancel(
        familyUid: _familyUid,
        hkUid: widget.hk.id,
        byUid: _familyUid,
        noticeText: s.noticeHireCancelled,
      );
    } catch (e) {
      debugPrint('Cancel hire failed: $e');
      if (mounted) showErrorToast(context, s.errGeneric);
    }
  }

  // Edit the review (only offered within UserService.editWindow).
  void _editReview(Map<String, dynamic> review) => Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => ReviewFlowScreen(hk: widget.hk, existing: review)));

  // Status strip above the message box; nothing until a hire is requested.
  Widget _hireBar(Hire? hire, s) {
    if (hire == null || !hire.isOpen) return const SizedBox.shrink();
    final summary = hireSummaryText(hire, s);
    if (hire.isPending) {
      return HireStatusBar(
        icon: Icons.hourglass_top,
        title: s.hirePendingFamily(_firstName),
        subtitle: summary,
        actions: [hireBarButton(s.cancelRequest, () => _cancelHire(hire))],
      );
    }
    final now = DateTime.now();
    if (hire.canCancel(now)) {
      return HireStatusBar(
        icon: Icons.handshake_outlined,
        title: s.hiredFamily(_firstName),
        subtitle: summary,
        actions: [hireBarButton(s.cancelHire, () => _cancelHire(hire))],
      );
    }
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _review,
      builder: (context, snap) {
        final review = snap.data;
        if (review != null) {
          if (review['removed'] == true) {
            return HireStatusBar(
              icon: Icons.info_outline,
              title: s.reviewRemovedNote,
              subtitle: summary,
            );
          }
          final stars = (review['starRating'] as num?)?.toInt() ?? 0;
          final editable = UserService.canEdit(
              review['createdAt'] as Timestamp?, DateTime.now());
          return HireStatusBar(
            icon: Icons.star,
            title:
                '${s.youReviewed(_firstName)}  ${'★' * stars}${'☆' * (5 - stars)}',
            subtitle: summary,
            actions: [
              if (editable)
                hireBarButton(s.editReview, () => _editReview(review)),
            ],
          );
        }
        if (hire.canReview(now)) {
          return HireStatusBar(
            icon: Icons.handshake_outlined,
            title: s.hiredFamily(_firstName),
            subtitle: summary,
            actions: [
              hireBarButton(
                  s.writeReview,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ReviewFlowScreen(hk: widget.hk))),
                  primary: true),
            ],
          );
        }
        return HireStatusBar(
          icon: Icons.handshake_outlined,
          title: s.hiredFamily(_firstName),
          subtitle: '$summary\n'
              '${s.reviewOpensOn(_firstName, formatDate(hire.reviewOpensAt))}',
        );
      },
    );
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    // Guests can browse but must sign in to message.
    if (_familyUid.isEmpty) {
      showErrorToast(
          context, LanguageProvider.strings(context).errSignInToMessage);
      return;
    }
    setState(() => _sending = true);
    _controller.clear();
    try {
      await _svc.sendMessage(
        familyUid: _familyUid,
        hkUid: widget.hk.id,
        senderUid: _familyUid,
        text: text,
        familyName: _familyName,
        hkName: widget.hk.name,
      );
    } catch (e) {
      debugPrint(
          'sendMessage failed (family=$_familyUid hk=${widget.hk.id}): $e');
      // Put the text back so it isn't lost, and tell the user.
      if (mounted) {
        if (_controller.text.isEmpty) _controller.text = text;
        showErrorToast(
            context, LanguageProvider.strings(context).errMessageNotSent);
      }
      return;
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Clear this side's unread count (no-op if the chat doesn't exist yet).
  void _markRead() {
    _svc.markChatRead(_familyUid, widget.hk.id, true).catchError((_) {});
  }

  @override
  void dispose() {
    if (_familyUid.isNotEmpty) _markRead(); // messages received while open
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return StreamBuilder<Hire?>(
      stream: _hire,
      builder: (context, hireSnap) {
        final hire = hireSnap.data;
        // A declined or cancelled hire can be requested again.
        final showHireBtn = _bothMessaged && (hire == null || !hire.isOpen);
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            actions: [
              if (showHireBtn)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: OutlinedButton.icon(
                    onPressed: _openHireForm,
                    icon: const Icon(Icons.handshake_outlined, size: 14),
                    label: Text(s.hireBtn),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      textStyle: const TextStyle(fontSize: 12),
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
              const LangToggleButton(),
            ],
            title: Row(children: [
              HkAvatar(
                  initials: widget.hk.initials,
                  color: Colors.white.withOpacity(0.25),
                  size: 36,
                  fontSize: 12),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.hk.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500)),
                      const Text('HomeHelp',
                          style: TextStyle(
                              color: Color(0xAAFFFFFF), fontSize: 11)),
                    ]),
              ),
            ]),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _messages,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snap.data?.docs ?? [];
                    final both = Hire.bothHaveMessaged(
                        docs.map((d) => d.data() as Map<String, dynamic>),
                        _familyUid,
                        widget.hk.id);
                    if (both != _bothMessaged) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _bothMessaged = both);
                      });
                    }
                    if (docs.isEmpty) {
                      return Center(
                        child: Text(s.noMessages,
                            style: const TextStyle(
                                fontSize: 13, color: AppTheme.grey400)),
                      );
                    }
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        _scrollController
                            .jumpTo(_scrollController.position.maxScrollExtent);
                      }
                    });
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final data = docs[i].data() as Map<String, dynamic>;
                        final notice =
                            hireNoticeLabel(data['kind'] as String?, s);
                        if (notice != null)
                          return HireNoticeChip(label: notice);
                        final isMe = data['senderUid'] == _familyUid;
                        final text = data['text'] as String? ?? '';
                        final time =
                            _formatTime(data['createdAt'] as Timestamp?);
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? AppTheme.primary
                                        : const Color(0xFFF0F0F0),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(14),
                                      topRight: const Radius.circular(14),
                                      bottomLeft:
                                          Radius.circular(isMe ? 14 : 4),
                                      bottomRight:
                                          Radius.circular(isMe ? 4 : 14),
                                    ),
                                  ),
                                  child: Text(text,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: isMe
                                              ? Colors.white
                                              : AppTheme.grey800,
                                          height: 1.5)),
                                ),
                                const SizedBox(height: 3),
                                Text(time,
                                    style: const TextStyle(
                                        fontSize: 10, color: AppTheme.grey400)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              _hireBar(hire, s),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(color: Color(0xFFEEEEEE), width: 0.5)),
                ),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: s.typeMessage,
                        hintStyle: const TextStyle(color: AppTheme.grey400),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                          color: AppTheme.primary, shape: BoxShape.circle),
                      child: _sending
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send,
                              color: Colors.white, size: 16),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}
