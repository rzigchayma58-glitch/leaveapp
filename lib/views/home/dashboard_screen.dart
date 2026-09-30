import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../core/saas_design.dart';
import '../../core/animations.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/leave_viewmodel.dart';
import '../manager/manager_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<LeaveViewModel>(context, listen: false).loadUserData(user.id ?? 'user1');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(context),
      body: Column(
        children: [
          // Header moderne avec dégradé
          _buildModernHeader(),
          // Contenu avec animations
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SaaSDesign.spacing20),
              child: Column(
                children: [
                  const SizedBox(height: SaaSDesign.spacing16),
                  _buildBalanceCard(),
                  const SizedBox(height: SaaSDesign.spacing24),
                  _buildQuickActions(),
                  const SizedBox(height: SaaSDesign.spacing24),
                  _buildStatsCards(),
                  const SizedBox(height: SaaSDesign.spacing24),
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final user = authViewModel.currentUser;
        final firstName = user?.firstName ?? 'Utilisateur';
        final displayName = firstName.length > 12 ? firstName.substring(0, 12) + '...' : firstName;
        return SaaSHeader(
          title: 'Bonjour $displayName !',
          subtitle: user?.isManager == true
              ? 'Espace responsable — gérez les demandes de votre équipe'
              : 'Gérez vos congés simplement',
          actions: [
            if (user?.isManager == true)
              Container(
                margin: const EdgeInsets.only(right: SaaSDesign.spacing8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManagerDashboardScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                  tooltip: 'Espace Responsable',
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
              ),
              child: IconButton(
                onPressed: () {
                  Provider.of<LeaveViewModel>(context, listen: false).refresh();
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Actualiser',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBalanceCard() {
    return Consumer<LeaveViewModel>(
      builder: (context, leaveViewModel, child) {
        return SlideAndFadeAnimation(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(SaaSDesign.spacing24),
            decoration: BoxDecoration(
              gradient: SaaSDesign.primaryGradient,
              borderRadius: BorderRadius.circular(SaaSDesign.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: SaaSDesign.primaryOrange.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(SaaSDesign.spacing12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: SaaSDesign.spacing12),
                    const Text(
                      'Solde Disponible',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SaaSDesign.spacing20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${leaveViewModel.availableBalance}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: SaaSDesign.spacing8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'jours',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final isManager = authViewModel.currentUser?.isManager == true;
        return SlideAndFadeAnimation(
          index: 1,
          child: SaaSCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Actions Rapides',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: SaaSDesign.spacing16),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedSaaSButton(
                        text: 'Nouveau',
                        icon: Icons.add,
                        backgroundColor: SaaSDesign.primaryOrange,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: SaaSDesign.spacing12),
                    Expanded(
                      child: AnimatedSaaSButton(
                        text: 'Historique',
                        icon: Icons.history,
                        backgroundColor: SaaSDesign.primaryOrange,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                if (isManager) ...[
                  const SizedBox(height: SaaSDesign.spacing12),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedSaaSButton(
                      text: 'Espace responsable',
                      icon: Icons.admin_panel_settings,
                      backgroundColor: SaaSDesign.primaryOrange,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManagerDashboardScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return Consumer<LeaveViewModel>(
      builder: (context, leaveViewModel, child) {
        final stats = leaveViewModel.statistics;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 60) / 3,
                child: SaaSStatsCard(
                  title: 'Attente',
                  value: '${stats['pending'] ?? 0}',
                  icon: Icons.schedule,
                  color: SaaSDesign.warning,
                  animationIndex: 2,
                ),
              ),
              const SizedBox(width: SaaSDesign.spacing12),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 60) / 3,
                child: SaaSStatsCard(
                  title: 'Validés',
                  value: '${stats['approved'] ?? 0}',
                  icon: Icons.check_circle,
                  color: SaaSDesign.success,
                  animationIndex: 3,
                ),
              ),
              const SizedBox(width: SaaSDesign.spacing12),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 60) / 3,
                child: SaaSStatsCard(
                  title: 'Refusés',
                  value: '${stats['rejected'] ?? 0}',
                  icon: Icons.cancel,
                  color: SaaSDesign.error,
                  animationIndex: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return SlideAndFadeAnimation(
      index: 5,
      child: SaaSCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Activité Récente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Voir tout
                  },
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: SaaSDesign.spacing16),
            SaaSListItem(
              leading: Container(
                padding: const EdgeInsets.all(SaaSDesign.spacing8),
                decoration: BoxDecoration(
                  color: SaaSDesign.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: SaaSDesign.success,
                  size: 20,
                ),
              ),
              title: 'Congé approuvé',
              subtitle: '15-20 Mai 2024 • 5 jours',
              trailing: const SaaSBadge(
                text: 'Approuvé',
                backgroundColor: SaaSDesign.success,
                textColor: Colors.white,
              ),
            ),
            SaaSListItem(
              leading: Container(
                padding: const EdgeInsets.all(SaaSDesign.spacing8),
                decoration: BoxDecoration(
                  color: SaaSDesign.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                ),
                child: const Icon(
                  Icons.schedule,
                  color: SaaSDesign.warning,
                  size: 20,
                ),
              ),
              title: 'En attente de validation',
              subtitle: '10-12 Juin 2024 • 2 jours',
              trailing: const SaaSBadge(
                text: 'En attente',
                backgroundColor: SaaSDesign.warning,
                textColor: Colors.white,
              ),
              animationIndex: 1,
            ),
          ],
        ),
      ),
    );
  }

}