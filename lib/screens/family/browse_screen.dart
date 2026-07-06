import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../models/housekeeper.dart';
import '../../l10n/language_provider.dart';
import '../welcome_screen.dart';
import 'hk_detail_screen.dart';
import 'filters_screen.dart';
import 'saved_screen.dart';
import 'family_settings_screen.dart';

class BrowseScreen extends StatefulWidget {
  final bool showBackButton;
  const BrowseScreen({super.key, this.showBackButton = true});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _activeChip = 'all';
  final Set<String> _saved = {};
  int _tab = 0;

  List<Housekeeper> get _filtered {
    return sampleHousekeepers.where((hk) {
      final q = _query.toLowerCase();
      final matchesQuery = q.isEmpty ||
          hk.name.toLowerCase().contains(q) ||
          hk.skills.any((s) => s.toLowerCase().contains(q));
      final matchesChip = _activeChip == 'all' ||
          (_activeChip == 'cooking' && hk.skills.any((s) => s.toLowerCase().contains('cook'))) ||
          (_activeChip == 'cleaning' && hk.skills.any((s) => s.toLowerCase().contains('clean'))) ||
          (_activeChip == 'childcare' && hk.skills.any((s) => s.toLowerCase().contains('child'))) ||
          (_activeChip == 'live-in' && hk.arrangement == 'live-in') ||
          (_activeChip == 'live-out' && hk.arrangement == 'live-out');
      return matchesQuery && matchesChip;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final results = _filtered;

    return Scaffold(
      body: Column(
        children: [
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
                      // Back button — only shown when not inside bottom nav
                      if (widget.showBackButton)
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(children: const [
                            Icon(Icons.arrow_back, color: Colors.white70, size: 18),
                            SizedBox(width: 4),
                            Text('Back', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ]),
                        )
                      else
                        const SizedBox(),
                      Row(
                        children: [
                          const LangToggleButton(),
                          const SizedBox(width: 4),
                          // Saved
                          IconButton(
                            icon: Stack(
                              children: [
                                const Icon(Icons.favorite_border, color: Colors.white),
                                if (_saved.isNotEmpty)
                                  Positioned(
                                    right: 0, top: 0,
                                    child: Container(
                                      width: 8, height: 8,
                                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                    ),
                                  ),
                              ],
                            ),
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) =>
                                    SavedScreen(savedIds: _saved, housekeepers: sampleHousekeepers))),
                          ),
                          // Settings
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, color: Colors.white),
                            onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const FamilySettingsScreen())),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(s.findHousekeeper,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 10),
                  // Search bar
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: s.searchHint,
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                              onPressed: () { setState(() => _query = ''); _searchController.clear(); },
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _FilterChip(label: s.filterAll, value: 'all', active: _activeChip,
                    onTap: (v) => setState(() => _activeChip = v)),
                _FilterChip(label: s.filterFilters, value: 'filters', active: _activeChip,
                    onTap: (_) => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const FiltersScreen()))),
                _FilterChip(label: s.filterCooking, value: 'cooking', active: _activeChip,
                    onTap: (v) => setState(() => _activeChip = v)),
                _FilterChip(label: s.filterCleaning, value: 'cleaning', active: _activeChip,
                    onTap: (v) => setState(() => _activeChip = v)),
                _FilterChip(label: s.filterChildcare, value: 'childcare', active: _activeChip,
                    onTap: (v) => setState(() => _activeChip = v)),
                _FilterChip(label: s.filterLiveIn, value: 'live-in', active: _activeChip,
                    onTap: (v) => setState(() => _activeChip = v)),
                _FilterChip(label: s.filterLiveOut, value: 'live-out', active: _activeChip,
                    onTap: (v) => setState(() => _activeChip = v)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(s.housekeepersFound(results.length),
                  style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
            ),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 40, color: AppTheme.grey200),
                        const SizedBox(height: 12),
                        Text(s.noResultsTitle,
                            style: const TextStyle(fontSize: 13, color: AppTheme.grey400)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final hk = results[i];
                      return _HkCard(
                        hk: hk,
                        isSaved: _saved.contains(hk.id),
                        birrLabel: s.birrPerMonth,
                        yrsLabel: s.yrs,
                        onSaveToggle: () => setState(() {
                          _saved.contains(hk.id) ? _saved.remove(hk.id) : _saved.add(hk.id);
                        }),
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => HkDetailScreen(hk: hk))),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String active;
  final ValueChanged<String> onTap;

  const _FilterChip({required this.label, required this.value, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOn = active == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isOn ? AppTheme.primary : Colors.white,
          border: Border.all(color: isOn ? AppTheme.primary : AppTheme.grey200, width: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: isOn ? FontWeight.w500 : FontWeight.normal,
                color: isOn ? Colors.white : AppTheme.grey600)),
      ),
    );
  }
}

class _HkCard extends StatelessWidget {
  final Housekeeper hk;
  final bool isSaved;
  final String birrLabel;
  final String yrsLabel;
  final VoidCallback onSaveToggle;
  final VoidCallback onTap;

  const _HkCard({
    required this.hk, required this.isSaved, required this.birrLabel,
    required this.yrsLabel, required this.onSaveToggle, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HkAvatar(initials: hk.initials, color: AppTheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(hk.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
                          Text('${hk.salaryMin.toStringAsFixed(0)} $birrLabel',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${hk.location} · ${hk.yearsExperience} $yrsLabel · ${hk.arrangement}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
                      const SizedBox(height: 5),
                      Row(children: [
                        StarRating(rating: hk.rating, reviewCount: hk.reviewCount),
                        const SizedBox(width: 6),
                        if (hk.isVerified) const VerifiedBadge(),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onSaveToggle,
                  child: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: isSaved ? Colors.red : AppTheme.grey200,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 5, runSpacing: 5,
              children: hk.skills.take(3).map((skill) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  border: Border.all(color: AppTheme.grey200, width: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(skill, style: const TextStyle(fontSize: 10, color: AppTheme.grey600)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
