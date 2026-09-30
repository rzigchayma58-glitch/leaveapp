import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../core/saas_design.dart';
import '../../core/animations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../services/theme_service.dart';
import '../auth/login/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileViewModel>(context, listen: false).initialize();
    });
  }

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
      body: Column(
        children: [
          // Header moderne
          _buildModernProfileHeader(),
          // Contenu avec animations
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SaaSDesign.spacing20),
              child: Column(
                children: [
                  const SizedBox(height: SaaSDesign.spacing16),
                  _buildProfileCard(),
                  const SizedBox(height: SaaSDesign.spacing24),
                  _buildInfoSection(),
                  const SizedBox(height: SaaSDesign.spacing24),
                  _buildOptionsSection(),
                  const SizedBox(height: SaaSDesign.spacing24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernProfileHeader() {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return SaaSHeader(
          title: 'Mon Profil 👤',
          subtitle: 'Gérez vos informations personnelles',
          showBackButton: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
                await Navigator.push(
                  context,
                  SaaSPageRoute(
                    child: const EditProfileScreen(),
                  ),
                );
                if (!mounted) return;
                await Provider.of<ProfileViewModel>(context, listen: false)
                    .loadLocalProfile();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileCard() {
    return Consumer2<AuthViewModel, ProfileViewModel>(
      builder: (context, authViewModel, profileViewModel, child) {
        final user = authViewModel.currentUser;
        final localProfile = profileViewModel.localProfile;
        final displayName = localProfile?.fullName ?? user?.fullName ?? 'Utilisateur';
        final first = localProfile?.firstName ?? user?.firstName ?? '';
        final last = localProfile?.lastName ?? user?.lastName ?? '';
        
        return SlideAndFadeAnimation(
          child: SaaSCard(
            child: Column(
              children: [
                Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: SaaSDesign.primaryGradient,
                            borderRadius: BorderRadius.circular(SaaSDesign.radiusLarge),
                            image: localProfile?.hasProfilePhoto == true
                                ? DecorationImage(
                                    image: FileImage(localProfile!.profilePhotoFile!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: localProfile?.hasProfilePhoto != true
                              ? Center(
                                  child: Text(
                                    first.isNotEmpty || last.isNotEmpty
                                        ? _getInitials(first, last)
                                        : 'U',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(SaaSDesign.spacing4),
                            decoration: BoxDecoration(
                              color: SaaSDesign.success,
                              borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                const SizedBox(height: SaaSDesign.spacing16),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: SaaSDesign.spacing4),
                Text(
                  user?.displayRole ?? 'Employé',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: SaaSDesign.spacing16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection() {
    return Consumer2<AuthViewModel, ProfileViewModel>(
      builder: (context, authViewModel, profileViewModel, child) {
        final user = authViewModel.currentUser;
        final local = profileViewModel.localProfile;
        final department = local?.department ?? user?.department ?? '—';
        final position = local?.position ?? user?.position ?? '—';
        final email = local?.email ?? user?.email ?? '';
        
        return SlideAndFadeAnimation(
          index: 1,
          child: SaaSCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informations Professionnelles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: SaaSDesign.spacing16),
                _buildModernInfoItem(
                  'Rôle',
                  user?.displayRole ?? 'Employé',
                  Icons.badge_outlined,
                  SaaSDesign.info,
                ),
                _buildModernInfoItem(
                  'Poste',
                  position,
                  Icons.work_outline,
                  SaaSDesign.primaryOrange,
                ),
                _buildModernInfoItem(
                  'Matricule',
                  user?.employeeId ?? '',
                  Icons.badge,
                  SaaSDesign.primaryOrange,
                ),
                _buildModernInfoItem(
                  'Département',
                  department,
                  Icons.business,
                  SaaSDesign.success,
                ),
                _buildModernInfoItem(
                  'Email',
                  email,
                  Icons.email,
                  SaaSDesign.warning,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernInfoItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SaaSDesign.spacing12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SaaSDesign.spacing8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: SaaSDesign.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return SlideAndFadeAnimation(
          index: 2,
          child: SaaSCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paramètres',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: SaaSDesign.spacing16),
                _buildModernOptionItem(
                  Icons.dark_mode,
                  'Mode Sombre',
                  'Basculer entre les thèmes',
                  trailing: Switch(
                    value: themeService.isDarkMode,
                    onChanged: (value) async {
                      await themeService.toggleTheme();
                    },
                    activeColor: SaaSDesign.primaryOrange,
                  ),
                ),
                _buildModernOptionItem(
                  Icons.info,
                  'À propos de l\'app',
                  'Informations sur XCongés',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildModernOptionItem(
                  Icons.logout,
                  'Déconnexion',
                  'Se déconnecter du compte',
                  color: SaaSDesign.error,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernOptionItem(
    IconData icon,
    String title,
    String subtitle, {
    Widget? trailing,
    Color? color,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: SaaSDesign.spacing8),
      child: SaaSListItem(
        leading: Container(
          padding: const EdgeInsets.all(SaaSDesign.spacing8),
          decoration: BoxDecoration(
            color: (color ?? SaaSDesign.primaryOrange).withOpacity(0.1),
            borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
          ),
          child: Icon(
            icon,
            color: color ?? SaaSDesign.primaryOrange,
            size: 20,
          ),
        ),
        title: title,
        subtitle: subtitle,
        trailing: trailing ?? (onTap != null 
            ? Icon(
                Icons.chevron_right,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
              )
            : null),
        onTap: onTap,
      ),
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