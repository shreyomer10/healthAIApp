import 'package:flutter/material.dart';
import 'package:health_ai/Model/user_model.dart';
import 'package:health_ai/core/secure_storage.dart';
import 'package:health_ai/Screens/auth/login_screen.dart';
import 'package:health_ai/screens/scanner_screen.dart';
import 'package:health_ai/screens/profile_screen.dart';
import 'package:health_ai/screens/history_screen.dart';
import 'package:health_ai/l10n/generated/app_localizations.dart';
import '../theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final user = await SecureStorage.getUser();

    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() {
      _user = user;
      _loading = false;
    });
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    debugPrint("SEARCH QUERY => $query");
    // TODO: API call
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;
    final imageUrl = _user?.profilePicture;

    print('user RESPONSE => ${_user?.profilePicture}');

    return Scaffold(
      backgroundColor: colors.background,

      // ---------- APP BAR ----------
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
                _user!.email, // 🔥 dynamic user
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
              child: CircleAvatar(
                radius: 18,
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl)
                    : const AssetImage('assets/nobg.png') as ImageProvider,
              )
            ),
          ),
        ],
      ),

      // ---------- BODY ----------
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            _searchBar(colors, t),
            const SizedBox(height: 32),
            _actionRow(context, colors, t),
          ],
        ),
      ),
    );
  }

  // ---------- SEARCH BAR ----------
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

  // ---------- ACTION BUTTONS ----------
  Widget _actionRow(
      BuildContext context,
      AppColors colors,
      AppLocalizations t,
      ) {
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
