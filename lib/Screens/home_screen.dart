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
        MaterialPageRoute(builder: (_) => LoginScreen()),
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
      return AppLoader();
    }

    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;
    final imageUrl = _user?.profilePicture;

    return WillPopScope(
      onWillPop: () async {
        showConfirmCard(
          context,
          message: t.exitApp, // ✅ localized
          onConfirm: () {
            Navigator.of(context).pop(); // exits app
          },
        );
        return false; // block default back
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
                    MaterialPageRoute(builder: (_) => ProfileScreen()),
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
      ),
    );
  }

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
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          // ---------- Animated background text ----------
          if (_searchController.text.isEmpty)
            Positioned(
              left: 56,
              child: IgnorePointer(
                child: RotatingHintText(
                  texts: [t.searchMed,
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
              MaterialPageRoute(builder: (_) => ScannerScreen()),
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
              MaterialPageRoute(builder: (_) =>  HistoryScreen()),
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
