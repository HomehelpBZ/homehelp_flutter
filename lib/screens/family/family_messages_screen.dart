import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../models/housekeeper.dart';
import '../../services/user_service.dart';
import 'family_chat_screen.dart';
import 'family_auth_screen.dart';

class FamilyMessagesScreen extends StatefulWidget {
  final bool isGuest;
  const FamilyMessagesScreen({super.key, this.isGuest = false});

  @override
  State<FamilyMessagesScreen> createState() => _FamilyMessagesScreenState();
}

class _FamilyMessagesScreenState extends State<FamilyMessagesScreen> {
  late final _svc = UserService(); // lazy: guests never touch Firebase
  List<Map<String, dynamic>> _chats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (!widget.isGuest) _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => _loading = false); return; }
    List<Map<String, dynamic>> chats = [];
    try {
      chats = await _svc.getFamilyChats(uid);
    } catch (e) {
      debugPrint('getFamilyChats failed: $e');
    }
    if (mounted) setState(() { _chats = chats; _loading = false; });
  }

  String _formatTime(dynamic ts) {
    if (ts == null) return '';
    try {
      final dt = (ts as dynamic).toDate() as DateTime;
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) {
        final h = dt.hour.toString().padLeft(2, '0');
        final m = dt.minute.toString().padLeft(2, '0');
        return '$h:$m';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else {
        return '${dt.day}/${dt.month}';
      }
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 14),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(alignment: Alignment.topRight, child: LangToggleButton()),
                  const SizedBox(height: 6),
                  Text(s.messages,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(s.familyMessagesSubtitle,
                      style: const TextStyle(color: Color(0xAAFFFFFF), fontSize: 12)),
                ],
              ),
            ),
          ),
          Expanded(
            child: widget.isGuest
                ? const GuestMessagesPrompt()
                : _loading
                ? const Center(child: CircularProgressIndicator())
                : _chats.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.message_outlined, size: 44, color: AppTheme.grey200),
                            const SizedBox(height: 14),
                            Text(s.noMessages,
                                style: const TextStyle(fontSize: 13, color: AppTheme.grey400)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _chats.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 0, color: Color(0xFFEEEEEE)),
                        itemBuilder: (context, i) {
                          final chat = _chats[i];
                          final hkName = chat['hkName'] as String? ?? '';
                          final hkId = chat['hkUid'] as String? ?? '';
                          final lastMsg = chat['lastMessage'] as String? ?? '';
                          final unread = (chat[UserService.unreadFamilyField] as num?)?.toInt() ?? 0;
                          final time = _formatTime(chat['lastMessageAt']);
                          final initials = hkName.split(' ')
                              .where((w) => w.isNotEmpty).take(2)
                              .map((w) => w[0].toUpperCase()).join();
                          final hk = Housekeeper(
                            id: hkId, name: hkName, initials: initials,
                            location: '', yearsExperience: 0,
                            salaryMin: 0, salaryMax: 0,
                            rating: 0, reviewCount: 0,
                            skills: [], languages: [], arrangement: '',
                            availableDays: [], education: '', bio: '',
                          );
                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            onTap: () async {
                              final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                              await _svc.markChatRead(uid, hkId, true);
                              if (context.mounted) {
                                await Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => FamilyChatScreen(hk: hk)));
                                _load(); // refresh unread on return
                              }
                            },
                            leading: HkAvatar(initials: initials, color: AppTheme.primary),
                            title: Text(hkName,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.grey800)),
                            subtitle: Text(lastMsg,
                                style: const TextStyle(fontSize: 12, color: AppTheme.grey600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(time,
                                    style: const TextStyle(fontSize: 11, color: AppTheme.grey400)),
                                const SizedBox(height: 4),
                                if (unread > 0)
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                        color: AppTheme.primary,
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: Text('$unread',
                                          style: const TextStyle(
                                              color: Colors.white, fontSize: 10)),
                                    ),
                                  )
                                else
                                  const SizedBox(width: 18, height: 18),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
// ── Guest prompt: messaging needs an account ─────────────────────────────────
// Fills the Messages tab for guests, or shows as a sheet (see below).
class GuestMessagesPrompt extends StatelessWidget {
  final bool inSheet; // close the sheet before opening sign-in / sign-up
  const GuestMessagesPrompt({super.key, this.inSheet = false});

  void _open(BuildContext context, Widget screen) {
    final navigator = Navigator.of(context);
    if (inSheet) navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final content = Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: inSheet ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 68, height: 68,
            decoration: const BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.lock_outline, size: 34, color: AppTheme.primary),
          ),
          const SizedBox(height: 16),
          Text(s.guestMessagesTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.grey800),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(s.guestMessagesSubtitle,
              style: const TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _open(context, const FamilySignInScreen()),
              child: Text(s.signInBtn),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _open(context, const FamilySignUpScreen()),
              child: Text(s.createAccount),
            ),
          ),
        ],
      ),
    );
    return inSheet
        ? SafeArea(child: SingleChildScrollView(child: content))
        : Center(child: content);
  }
}

// Shown when a guest tries to message, e.g. from a housekeeper's profile.
Future<void> showGuestMessagesSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true, // size to content, not half the screen
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => const GuestMessagesPrompt(inSheet: true),
  );
}
