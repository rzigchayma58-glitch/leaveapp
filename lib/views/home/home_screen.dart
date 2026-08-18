import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../auth/login/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: AppConstants.whiteColor,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.account_circle, size: 28),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: AppConstants.greyColor),
                    SizedBox(width: 8),
                    Text('Déconnexion'),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    Provider.of<AuthViewModel>(context, listen: false).logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          final user = authViewModel.currentUser;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte de bienvenue
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppConstants.whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenue, ${user?.firstName ?? 'Utilisateur'} !',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.darkGreyColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (user != null) ...[
                        Text(
                          'Email: ${user.email}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppConstants.greyColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Matricule: ${user.employeeId}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppConstants.greyColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Département: ${user.department}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppConstants.greyColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Section des fonctionnalités
                const Text(
                  'Gestion des congés',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.darkGreyColor,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Placeholder pour les fonctionnalités futures
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildFeatureCard(
                        'Demander un congé',
                        Icons.event_available,
                        () {
                          // TODO: Implémenter la demande de congé
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité à venir...'),
                              backgroundColor: AppConstants.primaryOrange,
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        'Mes congés',
                        Icons.calendar_month,
                        () {
                          // TODO: Implémenter la visualisation des congés
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité à venir...'),
                              backgroundColor: AppConstants.primaryOrange,
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        'Solde congés',
                        Icons.account_balance_wallet,
                        () {
                          // TODO: Implémenter la visualisation du solde
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité à venir...'),
                              backgroundColor: AppConstants.primaryOrange,
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        'Historique',
                        Icons.history,
                        () {
                          // TODO: Implémenter l'historique
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fonctionnalité à venir...'),
                              backgroundColor: AppConstants.primaryOrange,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppConstants.primaryOrange,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.darkGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}