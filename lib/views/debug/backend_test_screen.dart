// 🔥 ÉCRAN DE TEST BACKEND INTÉGRÉ DANS L'APP FLUTTER
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/api_config.dart';
import '../../services/auth_service.dart';
import '../../services/leave_service.dart';

class BackendTestScreen extends StatefulWidget {
  const BackendTestScreen({Key? key}) : super(key: key);

  @override
  State<BackendTestScreen> createState() => _BackendTestScreenState();
}

class _BackendTestScreenState extends State<BackendTestScreen> {
  List<TestResult> results = [];
  bool isRunningTests = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tests Backend'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Boutons de contrôle
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isRunningTests ? null : _runAllTests,
                    icon: isRunningTests 
                        ? const SizedBox(
                            width: 16, 
                            height: 16, 
                            child: CircularProgressIndicator(strokeWidth: 2)
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(isRunningTests ? 'Tests en cours...' : 'Lancer tous les tests'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _clearResults,
                  child: const Text('Effacer'),
                ),
              ],
            ),
          ),
          
          // Info backend
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📡 Configuration Backend:', 
                          style: TextStyle(fontWeight: FontWeight.bold)),
                Text('URL: ${ApiConfig.baseUrl}'),
                Text('Test URL: ${ApiConfig.baseUrl.replaceAll('/api', '')}/api/flutter/test'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Résultats des tests
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      result.success ? Icons.check_circle : Icons.error,
                      color: result.success ? Colors.green : Colors.red,
                    ),
                    title: Text(result.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(result.message),
                        if (result.details != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            result.details!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    isThreeLine: result.details != null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runAllTests() async {
    setState(() {
      isRunningTests = true;
      results.clear();
    });

    await _testBasicConnectivity();
    await _testAuthentication();
    await _testLeaveService();
    await _testLeaveTypes();
    await _testUserRequests();

    setState(() {
      isRunningTests = false;
    });
  }

  void _clearResults() {
    setState(() {
      results.clear();
    });
  }

  Future<void> _testBasicConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl.replaceAll('/api', '')}/api/flutter/test')
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        _addResult(TestResult(
          title: '📡 Connectivité Backend',
          message: 'Serveur accessible',
          success: true,
          details: 'Status: ${response.statusCode}\nRéponse: ${response.body}',
        ));
      } else {
        _addResult(TestResult(
          title: '📡 Connectivité Backend',
          message: 'Erreur HTTP ${response.statusCode}',
          success: false,
          details: response.body,
        ));
      }
    } catch (e) {
      _addResult(TestResult(
        title: '📡 Connectivité Backend',
        message: 'Serveur non accessible',
        success: false,
        details: e.toString(),
      ));
    }
  }

  Future<void> _testAuthentication() async {
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      final user = await AuthService.getStoredUser();
      
      if (isLoggedIn && user != null) {
        _addResult(TestResult(
          title: '🔐 Authentification',
          message: 'Utilisateur connecté',
          success: true,
          details: 'User: ${user.firstName} ${user.lastName}\nID: ${user.id}\nEmail: ${user.email}',
        ));
      } else {
        _addResult(TestResult(
          title: '🔐 Authentification',
          message: 'Aucun utilisateur connecté',
          success: false,
          details: 'Connectez-vous d\'abord pour tester les endpoints protégés',
        ));
      }
    } catch (e) {
      _addResult(TestResult(
        title: '🔐 Authentification',
        message: 'Erreur de vérification',
        success: false,
        details: e.toString(),
      ));
    }
  }

  Future<void> _testLeaveService() async {
    try {
      final leaveService = LeaveService();
      final isConnected = await leaveService.testConnection();
      
      _addResult(TestResult(
        title: '🔗 Service Leave',
        message: isConnected ? 'Connexion OK' : 'Connexion échouée',
        success: isConnected,
        details: 'Test du service de gestion des congés',
      ));
    } catch (e) {
      _addResult(TestResult(
        title: '🔗 Service Leave',
        message: 'Erreur du service',
        success: false,
        details: e.toString(),
      ));
    }
  }

  Future<void> _testLeaveTypes() async {
    try {
      final leaveService = LeaveService();
      final leaveTypes = await leaveService.getLeaveTypes();
      
      _addResult(TestResult(
        title: '📋 Types de congé',
        message: 'Récupérés avec succès',
        success: true,
        details: 'Nombre de types: ${leaveTypes.length}\n${leaveTypes.map((t) => '${t.id}: ${t.name}').join('\n')}',
      ));
    } catch (e) {
      _addResult(TestResult(
        title: '📋 Types de congé',
        message: 'Erreur de récupération',
        success: false,
        details: e.toString(),
      ));
    }
  }

  Future<void> _testUserRequests() async {
    try {
      final user = await AuthService.getStoredUser();
      if (user == null) {
        _addResult(TestResult(
          title: '📝 Demandes utilisateur',
          message: 'Utilisateur non connecté',
          success: false,
          details: 'Connectez-vous pour tester ce endpoint',
        ));
        return;
      }

      final leaveService = LeaveService();
      final requests = await leaveService.getUserRequests(user.id);
      
      _addResult(TestResult(
        title: '📝 Demandes utilisateur',
        message: 'Récupérées avec succès',
        success: true,
        details: 'Nombre de demandes: ${requests.length}',
      ));
    } catch (e) {
      _addResult(TestResult(
        title: '📝 Demandes utilisateur',
        message: 'Erreur de récupération',
        success: false,
        details: e.toString(),
      ));
    }
  }

  void _addResult(TestResult result) {
    setState(() {
      results.add(result);
    });
  }
}

class TestResult {
  final String title;
  final String message;
  final bool success;
  final String? details;

  TestResult({
    required this.title,
    required this.message,
    required this.success,
    this.details,
  });
}