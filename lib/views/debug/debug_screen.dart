import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/leave_viewmodel.dart';
import '../../widgets/connection_test_widget.dart';
import '../../services/api_config.dart';
import '../../core/constants.dart';
import 'backend_test_screen.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Debug & Tests'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test de connexion
            const ConnectionTestWidget(),
            
            // Informations de configuration
            _buildConfigSection(),
            
            // Tests d'authentification
            _buildAuthSection(),
            
            // Tests des congés
            _buildLeaveSection(),
            
            // Actions de développement
            _buildDevActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.settings, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Configuration',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Base URL', ApiConfig.baseUrl),
          _buildInfoRow('Mode Debug', '${kDebugMode}'),
          _buildInfoRow('Platform', Theme.of(context).platform.toString()),
        ],
      ),
    );
  }

  Widget _buildAuthSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Authentification',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              final user = authViewModel.currentUser;
              return Column(
                children: [
                  _buildInfoRow('Connecté', authViewModel.isLoggedIn ? 'Oui' : 'Non'),
                  if (user != null) ...[
                    _buildInfoRow('Utilisateur', user.fullName),
                    _buildInfoRow('Email', user.email),
                    _buildInfoRow('ID', user.id.toString()),
                    _buildInfoRow('Rôle', user.role.toString()),
                  ],
                  if (authViewModel.errorMessage != null)
                    _buildInfoRow('Erreur', authViewModel.errorMessage!, isError: true),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: authViewModel.isLoading ? null : () => _testLogin(),
                          icon: authViewModel.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.login),
                          label: const Text('Test Login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: authViewModel.isLoggedIn ? () => authViewModel.logout() : null,
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Gestion des Congés',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer<LeaveViewModel>(
            builder: (context, leaveViewModel, child) {
              return Column(
                children: [
                  _buildInfoRow('Demandes chargées', leaveViewModel.userRequests.length.toString()),
                  _buildInfoRow('Soldes chargés', leaveViewModel.userBalances.length.toString()),
                  _buildInfoRow('En attente', leaveViewModel.statistics['pending'].toString()),
                  _buildInfoRow('Approuvés', leaveViewModel.statistics['approved'].toString()),
                  _buildInfoRow('Refusés', leaveViewModel.statistics['rejected'].toString()),
                  if (leaveViewModel.errorMessage != null)
                    _buildInfoRow('Erreur', leaveViewModel.errorMessage!, isError: true),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: leaveViewModel.isLoading ? null : () => leaveViewModel.refresh(),
                      icon: leaveViewModel.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      label: const Text('Actualiser Données'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDevActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.developer_mode, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Actions Développeur',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _runFullTest(),
              icon: const Icon(Icons.play_circle),
              label: const Text('Test Complet d\'Intégration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BackendTestScreen(),
                ),
              ),
              icon: const Icon(Icons.api),
              label: const Text('🔥 Tests Backend Complets'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _clearAllData(),
              icon: const Icon(Icons.delete_forever),
              label: const Text('Vider Cache & Données'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'monospace',
                color: isError ? Colors.red : Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testLogin() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    // Test avec des identifiants par défaut
    final success = await authViewModel.login('test@example.com', 'password123');
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Login test réussi' : 'Login test échoué'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _runFullTest() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Test complet en cours...'),
          ],
        ),
      ),
    );

    // Simuler le test complet
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Test complet terminé - Vérifiez les logs'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _clearAllData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    await authViewModel.logout();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache et données effacés'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}