import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/theme_service.dart';
import '../auth/login/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  String _getInitials(String firstName, String lastName) {
    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthViewModel>(context, listen: false).logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'Déconnexion',
                style: TextStyle(color: AppConstants.rejectedColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          AppConstants.employeeProfile,
          style: TextStyle(
            color: ThemeColors.textColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ThemeColors.appBarColor(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: AppConstants.primaryOrange,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          final user = authViewModel.currentUser;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar et nom
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          user != null ? _getInitials(user.firstName, user.lastName) : 'U',
                          style: const TextStyle(
                            color: AppConstants.whiteColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.fullName ?? 'Utilisateur',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeColors.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Développeuse Mobile',
                      style: TextStyle(
                        fontSize: 14,
                        color: ThemeColors.secondaryTextColor(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Informations
                _buildInfoSection(context, [
                  _buildInfoItem('Matricule', user?.employeeId ?? ''),
                  _buildInfoItem('Département', user?.department ?? ''),
                  _buildInfoItem('Email', user?.email ?? '', isEmail: true),
                ]),

                const SizedBox(height: 24),

                // Options
                _buildOptionsList(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isEmail = false}) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.secondaryTextColor(context),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isEmail ? AppConstants.primaryOrange : ThemeColors.textColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return Column(
            children: [
              _buildOptionItem(
                context,
                Icons.dark_mode,
                AppConstants.darkMode,
                trailing: Switch(
                  value: themeService.isDarkMode,
                  onChanged: (value) async {
                    await themeService.toggleTheme();
                  },
                  activeColor: AppConstants.primaryOrange,
                ),
              ),
              Divider(height: 1, color: ThemeColors.dividerColor(context)),
              _buildOptionItem(
                context,
                Icons.info,
                AppConstants.aboutApp,
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              Divider(height: 1, color: ThemeColors.dividerColor(context)),
              _buildOptionItem(
                context,
                Icons.logout,
                AppConstants.logout,
                color: AppConstants.rejectedColor,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    IconData icon,
    String title, {
    Widget? trailing,
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? ThemeColors.textColor(context),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: color ?? ThemeColors.textColor(context),
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: ThemeColors.iconColor(context),
                )
              : null),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('À propos'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('XCongés'),
              SizedBox(height: 8),
              Text('Version 1.0.0'),
              SizedBox(height: 8),
              Text('Application de gestion des congés pour Xtensus'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}