import 'package:flutter/material.dart';
import '../../services/leave_service.dart';
import '../../services/auth_service.dart';
import '../../core/theme_colors.dart';

class DebugLeaveTypesScreen extends StatefulWidget {
  const DebugLeaveTypesScreen({Key? key}) : super(key: key);

  @override
  State<DebugLeaveTypesScreen> createState() => _DebugLeaveTypesScreenState();
}

class _DebugLeaveTypesScreenState extends State<DebugLeaveTypesScreen> {
  List<String> _logs = [];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
    print(message);
  }

  Future<void> _testLeaveTypes() async {
    setState(() {
      _logs.clear();
      _isLoading = true;
    });

    _addLog('🔍 DÉBUT TEST TYPES DE CONGÉ');
    
    try {
      // Test 1: Vérifier l'authentification
      final user = await AuthService.getStoredUser();
      final token = await AuthService.getStoredToken();
      
      _addLog('👤 Utilisateur: ${user?.firstName ?? "Non connecté"}');
      _addLog('🔑 Token: ${token != null ? "✅ Présent" : "❌ Manquant"}');
      
      if (token == null) {
        _addLog('❌ ERREUR: Pas de token d\'authentification');
        return;
      }

      // Test 2: Appel de l'API
      _addLog('📡 Appel API getLeaveTypes()...');
      
      final leaveService = LeaveService();
      final types = await leaveService.getLeaveTypes();
      
      _addLog('✅ SUCCESS: ${types.length} types récupérés');
      
      // Test 3: Détail des types
      for (final type in types) {
        _addLog('📋 Type ${type.id}: "${type.name}" (actif: ${type.isActive})');
      }
      
    } catch (e) {
      _addLog('❌ ERREUR: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _logs.clear();
      _isLoading = true;
    });

    _addLog('🔍 DÉBUT TEST CONNEXION BACKEND');
    
    try {
      final leaveService = LeaveService();
      final isConnected = await leaveService.testConnection();
      
      _addLog(isConnected ? '✅ Backend accessible' : '❌ Backend inaccessible');
      
    } catch (e) {
      _addLog('❌ ERREUR CONNEXION: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(context),
      appBar: AppBar(
        title: const Text('Debug - Types de Congé'),
        backgroundColor: ThemeColors.appBarColor(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Boutons de test
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testConnection,
                    icon: const Icon(Icons.wifi),
                    label: const Text('Test Connexion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testLeaveTypes,
                    icon: const Icon(Icons.list),
                    label: const Text('Test Types'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Indicateur de chargement
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            
            // Logs
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'LOGS DE DEBUG:',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_logs.isEmpty && !_isLoading)
                        const Text(
                          'Aucun log - Appuyez sur un bouton pour tester',
                          style: TextStyle(color: Colors.grey),
                        )
                      else
                        ...(_logs.map((log) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            log,
                            style: TextStyle(
                              color: log.contains('❌') ? Colors.red :
                                     log.contains('✅') ? Colors.green :
                                     log.contains('📡') ? Colors.blue :
                                     Colors.white,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ))),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bouton clear
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _logs.clear()),
                icon: const Icon(Icons.clear),
                label: const Text('Effacer Logs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}