import 'package:flutter/material.dart';
import 'package:health_ai/Model/user_model.dart';
import 'package:health_ai/core/secure_storage.dart';
import 'package:health_ai/Screens/auth/login_screen.dart';
import 'package:health_ai/Screens/scanner_screen.dart';
import 'package:health_ai/Screens/profile_screen.dart';
import 'package:health_ai/Screens/history_screen.dart';
import 'package:health_ai/l10n/generated/app_localizations.dart';
import 'package:health_ai/widgets/loader.dart';

import '../theme.dart';
import '../widgets/AnimatedSearchBox.dart';
import '../widgets/confirm_action_card.dart';

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
    _searchController.addListener(() {
      setState(() {});
    });
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
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppLoader();
    }

    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;
    final imageUrl = _user?.profilePicture;

    return WillPopScope(
      onWillPop: () async {
        showConfirmCard(
          context,
          message: t.exitApp,
          onConfirm: () {
            Navigator.of(context).pop();
          },
        );
        return false;
      },
      child: Scaffold(
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
                  _user!.email,
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
                ),
              ),
            ),
          ],
        ),

        // ---------- BODY ----------
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _searchBar(colors, t),
              const SizedBox(height: 32),
              _actionColumn(context, colors, t),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- SEARCH BAR ----------
  Widget _searchBar(AppColors colors, AppLocalizations t) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          TextField(
            controller: _searchController,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
            ),
            cursorColor: colors.textPrimary,
            textInputAction: TextInputAction.search,
            onSubmitted: _onSearch,
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.overlay,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: colors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_searchController.text.isEmpty)
            Positioned(
              left: 56,
              child: IgnorePointer(
                child: RotatingHintText(
                  texts: [
                    t.searchMed,
                    t.searchIngredients,
                    t.searchProducts,
                  ],
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------- BIG VERTICAL ACTION BUTTONS ----------
  Widget _actionColumn(
      BuildContext context,
      AppColors colors,
      AppLocalizations t,
      ) {
    return Column(
      children: [
        _bigActionButton(
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
        const SizedBox(height: 20),
        _bigActionButton(
          icon: Icons.history,
          label: t.history,
          colors: colors,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanListScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _bigActionButton({
    required IconData icon,
    required String label,
    required AppColors colors,
    required VoidCallback onTap,
  }) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 260, // 👈 reduced width (tweak: 240–280)
          height: 110,
          decoration: BoxDecoration(
            color: colors.actionButton,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: colors.textPrimary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
