import 'package:flutter/material.dart';
import '../theme.dart';
import 'scanner_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'package:health_ai/l10n/generated/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    debugPrint("SEARCH QUERY => $query");
    // 🔜 API call later
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,

      // ✅ PROPER APP BAR
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.welcome,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                "@shrey", // hardcoded for now
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/nobg.png'),
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 🔍 SEARCH BAR
            _searchBar(colors, t),

            const SizedBox(height: 32),

            // ⚡ ACTION BUTTONS
            _actionRow(context, colors, t),
          ],
        ),
      ),
    );
  }

  // ---------------- SEARCH BAR ----------------
  Widget _searchBar(AppColors colors, AppLocalizations t) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.overlay,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: colors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: colors.textPrimary),
              cursorColor: colors.textPrimary,
              textInputAction: TextInputAction.search,
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText: t.searchHint,
                hintStyle: TextStyle(color: colors.textSecondary),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- ACTION BUTTONS ----------------
  Widget _actionRow(
      BuildContext context, AppColors colors, AppLocalizations t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _actionButton(
          icon: Icons.qr_code_scanner,
          label: t.scan,
          colors: colors,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScannerScreen()),
            );
          },
        ),
        const SizedBox(width: 24),
        _actionButton(
          icon: Icons.history,
          label: t.history,
          colors: colors,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required AppColors colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.actionButton,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: colors.textPrimary, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
