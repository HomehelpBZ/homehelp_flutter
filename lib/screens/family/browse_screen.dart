import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../services/user_service.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../welcome_screen.dart';
import 'hk_detail_screen.dart';
import 'filters_screen.dart';
import 'saved_screen.dart';
import 'family_settings_screen.dart';
import '../../models/housekeeper.dart';

class BrowseScreen extends StatefulWidget {
  final bool showBackButton;
  const BrowseScreen({super.key, this.showBackButton = true});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _searchController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _query = '';
  String _activeChip = 'all';
  final Set<String> _saved = {};
  List<Map<String, dynamic>> _housekeepers = [];
  bool _isLoading = true;
  final _svc = UserService();

  @override
  void initState() {
    super.initState();
    _loadHousekeepers();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final ids = await _svc.getFavoriteIds(uid);
    if (mounted) setState(() => _saved.addAll(ids));
  }

  Future<void> _toggleSave(String hkId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_saved.contains(hkId)) {
      await _svc.removeFavorite(uid, hkId);
      if (mounted) setState(() => _saved.remove(hkId));
    } else {
      await _svc.addFavorite(uid, hkId);
      if (mounted) setState(() => _saved.add(hkId));
    }
  }

  void _loadHousekeepers() async {
    try {
      final snap = await _db
          .collection('housekeeperProfiles')
          .where('verificationStatus', isEqualTo: 'approved')
          .get();

      if (mounted) {
        setState(() {
          _housekeepers = snap.docs
              .map((d) => {'id': d.id, ...d.data()})
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    return _housekeepers.where((hk) {
      final q = _query.toLowerCase();
      final name = (hk['fullName'] as String? ?? '').toLowerCase();
      final skills = (hk['skills'] as List?)?.cast<String>() ?? [];
      final areas = (hk['preferredAreas'] as List?)?.cast<String>() ?? [];
      final arrangement =
          (hk['availability']?['arrangement'] as String? ?? '')
              .toLowerCase();

      final matchesQuery = q.isEmpty ||
          name.contains(q) ||
          skills.any((s) => s.toLowerCase().contains(q)) ||
          areas.any((a) => a.toLowerCase().contains(q));

      final matchesChip = _activeChip == 'all' ||
          (_activeChip == 'cooking' &&
              skills.any((s) => s.toLowerCase().contains('cook'))) ||
          (_activeChip == 'cleaning' &&
              skills.any((s) => s.toLowerCase().contains('clean'))) ||
          (_activeChip == 'childcare' &&
              skills.any((s) => s.toLowerCase().contains('child'))) ||
          (_activeChip == 'live-in' && arrangement.contains('livein')) ||
          (_activeChip == 'live-out' && arrangement.contains('liveout'));

      return matchesQuery && matchesChip;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Translate a skill from English to current language
  String _translateSkill(String skill, List<String> enSkills, List<String> amSkills, bool isAmharic) {
    if (!isAmharic) return skill;
    final idx = enSkills.indexOf(skill);
    if (idx >= 0 && idx < amSkills.length) return amSkills[idx];
    return skill; // Return as-is if not found
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final results = _filtered;

    return Scaffold(
      body: Column(
        children: [
          // Navy header
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.showBackButton)
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(children: const [
                            Icon(Icons.arrow_back,
                                color: Colors.white70, size: 18),
                            SizedBox(width: 4),
                            Text('Back',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13)),
                          ]),
                        )
                      else
                        const SizedBox(),
                      Row(children: [
                        const LangToggleButton(),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Stack(children: [
                            const Icon(Icons.favorite_border,
                                color: Colors.white),
                            if (_saved.isNotEmpty)
                              Positioned(
                                right: 0, top: 0,
                                child: Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle),
                                ),
                              ),
                          ]),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SavedScreen())),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined,
                              color: Colors.white),
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const FamilySettingsScreen())),
                        ),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(s.findHousekeeper,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: s.searchHint,
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.55)),
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.white70, size: 20),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 10),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white70, size: 18),
                              onPressed: () {
                                setState(() => _query = '');
                                _searchController.clear();
                              },
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            child: Row(children: [
              _FilterChip(
                  label: s.filterAll,
                  value: 'all',
                  active: _activeChip,
                  onTap: (v) => setState(() => _activeChip = v)),
              _FilterChip(
                  label: s.filterFilters,
                  value: 'filters',
                  active: _activeChip,
                  onTap: (_) => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const FiltersScreen()))),
              _FilterChip(
                  label: s.filterCooking,
                  value: 'cooking',
                  active: _activeChip,
                  onTap: (v) => setState(() => _activeChip = v)),
              _FilterChip(
                  label: s.filterCleaning,
                  value: 'cleaning',
                  active: _activeChip,
                  onTap: (v) => setState(() => _activeChip = v)),
              _FilterChip(
                  label: s.filterChildcare,
                  value: 'childcare',
                  active: _activeChip,
                  onTap: (v) => setState(() => _activeChip = v)),
              _FilterChip(
                  label: s.filterLiveIn,
                  value: 'live-in',
                  active: _activeChip,
                  onTap: (v) => setState(() => _activeChip = v)),
              _FilterChip(
                  label: s.filterLiveOut,
                  value: 'live-out',
                  active: _activeChip,
                  onTap: (v) => setState(() => _activeChip = v)),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _isLoading
                    ? 'Loading...'
                    : s.housekeepersFound(results.length),
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.grey600)),
            ),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary))
                : results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off,
                                size: 40, color: AppTheme.grey200),
                            const SizedBox(height: 12),
                            Text(
                              _housekeepers.isEmpty
                                  ? 'No approved housekeepers yet'
                                  : s.noResultsTitle,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.grey400)),
                            if (_housekeepers.isEmpty) ...[
                              const SizedBox(height: 6),
                              const Text(
                                'Check back soon — profiles are being reviewed',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.grey400),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _loadHousekeepers(),
                        color: AppTheme.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16),
                          itemCount: results.length,
                          itemBuilder: (context, i) {
                            final hk = results[i];
                            final uid = hk['id'] as String;
                            final name =
                                hk['fullName'] as String? ?? '';
                            final skills = (hk['skills'] as List?)
                                    ?.cast<String>() ??
                                [];
                            final areas =
                                (hk['preferredAreas'] as List?)
                                        ?.cast<String>() ??
                                    [];
                            final arrangement =
                                hk['availability']?['arrangement']
                                        as String? ??
                                    '';
                            final salary =
                                hk['rates']?['monthlyRate']
                                        as String? ??
                                    '0';
                            final region =
                                hk['region'] as String? ?? '';
                            final experience =
                                hk['experienceYears'] as String? ??
                                    '';
                            final isSaved = _saved.contains(uid);

                            // Translate skills (handles both En→Am and Am→En)
                            final enSkills = ['Traditional Ethiopian cooking', 'Modern / international cooking', 'Baking and pastries', 'General house cleaning', 'Laundry and ironing', 'Grocery shopping and errands', 'Childcare / babysitting', 'Caring for elderly'];
                            final amSkills = ['ባህላዊ የኢትዮጵያ ምግብ ማብሰል', 'ዘመናዊ / አለምዓቀፍ ምግብ ማብሰል', 'ዳቦ ማዘጋጀት', 'ቤት ማጽዳት', 'ልብስ ማጠብ እና ማደርያ', 'ገበያ ወጥቶ ማምጣት', 'ህፃናት ተንከባካቢ', 'አረጋውያን ተንከባካቢ'];
                            final translatedSkills = skills.map((sk) {
                              final skT = sk.trim();
                              final enIdx = enSkills.indexWhere((e) => e.trim() == skT);
                              final amIdx = amSkills.indexWhere((e) => e.trim() == skT);
                              if (s.isAmharic && enIdx >= 0) return amSkills[enIdx];
                              if (!s.isAmharic && amIdx >= 0) return enSkills[amIdx];
                              return sk;
                            }).toList();

                            // Translate experience (handles both directions)
                            final enExp = ['No experience', 'Less than 1 year', '1 – 3 years', '4 – 6 years', '7+ years'];
                            final amExp = ['ልምድ የለም', 'ከ1 ዓመት በታች', '1 – 3 ዓመት', '4 – 6 ዓመት', '7+ ዓመት'];
                            final expTrimmed = experience.trim();
                            final enExpIdx = enExp.indexWhere((e) => e.trim() == expTrimmed);
                            final amExpIdx = amExp.indexWhere((e) => e.trim() == expTrimmed);
                            final displayExperience = s.isAmharic && enExpIdx >= 0
                                ? amExp[enExpIdx]
                                : !s.isAmharic && amExpIdx >= 0
                                    ? enExp[amExpIdx]
                                    : experience;

                            // Translate area names
                            final enAreas = ['Bole', 'Kirkos', 'Lideta', 'Yeka', 'Arada', 'Addis Ketema', 'Gulele', 'Kolfe Keranio', 'Nifas Silk-Lafto', 'Akaky Kaliti', 'Lemi Kura'];
                            final amAreas = ['ቦሌ', 'ቅርቆስ', 'ልደታ', 'የካ', 'አራዳ', 'አዲስ ከተማ', 'ጉለሌ', 'ቆልፌ ቀራኒዮ', 'ንፋስ ስልክ ላፍቶ', 'አቃቂ ቃሊቲ', 'ለሚ ኩራ'];
                            final firstArea = areas.isNotEmpty ? areas.first : region;
                            final enAreaIdx = enAreas.indexOf(firstArea);
                            final amAreaIdx = amAreas.indexOf(firstArea);
                            final displayArea = s.isAmharic && enAreaIdx >= 0
                                ? amAreas[enAreaIdx]
                                : !s.isAmharic && amAreaIdx >= 0
                                    ? enAreas[amAreaIdx]
                                    : firstArea;

                            return _HkFirestoreCard(
                              uid: uid,
                              name: name,
                              initials: _getInitials(name),
                              skills: translatedSkills,
                              displayArea: displayArea,
                              displayExperience: displayExperience,
                              areas: areas,
                              arrangement: arrangement,
                              salary: salary,
                              region: region,
                              experience: experience,
                              isSaved: isSaved,
                              birrLabel: s.birrPerMonth,
                              onSaveToggle: () => _toggleSave(uid),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => HkDetailScreen(uid: uid)),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _HkFirestoreCard extends StatelessWidget {
  final String uid;
  final String name;
  final String initials;
  final List<String> skills;
  final List<String> areas;
  final String arrangement;
  final String salary;
  final String region;
  final String experience;
  final bool isSaved;
  final String birrLabel;
  final VoidCallback onSaveToggle;
  final VoidCallback onTap;
  final String displayArea;
  final String displayExperience;

  const _HkFirestoreCard({
    required this.uid,
    required this.name,
    required this.initials,
    required this.skills,
    required this.areas,
    required this.arrangement,
    required this.salary,
    required this.region,
    required this.experience,
    required this.isSaved,
    required this.birrLabel,
    required this.onSaveToggle,
    required this.onTap,
    required this.displayArea,
    required this.displayExperience,
  });

  @override
  Widget build(BuildContext context) {
    final isAmharic = LanguageProvider.strings(context).isAmharic;
    final displayArrangement = arrangement == 'livein'
        ? (isAmharic ? 'አዳሪ' : 'Live-in')
        : arrangement == 'liveout'
            ? (isAmharic ? 'ተመላላሽ' : 'Live-out')
            : arrangement == 'either'
                ? (isAmharic ? 'ሁለቱም' : 'Either')
                : arrangement;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.grey200, width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HkAvatar(initials: initials, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.grey800)),
                          Text('$salary $birrLabel',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                          '$displayArea · $displayExperience',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.grey600)),
                      const SizedBox(height: 5),
                      Row(children: [
                        const VerifiedBadge(),
                      ]),
                    ]),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onSaveToggle,
                child: Icon(
                  isSaved
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color:
                      isSaved ? Colors.red : AppTheme.grey400,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: skills
                .take(3)
                .map((skill) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        border: Border.all(
                            color: AppTheme.grey200, width: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(skill,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.grey600)),
                    ))
                .toList(),
          ),
        ]),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String active;
  final ValueChanged<String> onTap;
  const _FilterChip(
      {required this.label,
      required this.value,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOn = active == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isOn ? AppTheme.primary : Colors.white,
          border: Border.all(
              color: isOn ? AppTheme.primary : AppTheme.grey200,
              width: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isOn ? FontWeight.w500 : FontWeight.normal,
                color: isOn ? Colors.white : AppTheme.grey600)),
      ),
    );
  }
}