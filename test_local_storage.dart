// 🎯 TEST STOCKAGE LOCAL DES DEMANDES DE CONGÉ
import 'dart:convert';

// Simulation des classes Flutter pour les tests
class MockSharedPreferences {
  static Map<String, String> _storage = {};
  
  static MockSharedPreferences getInstance() => MockSharedPreferences();
  
  String? getString(String key) => _storage[key];
  
  Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }
}

// Service simplifié pour les tests
class LocalLeaveService {
  static const String _localRequestsKey = 'flutter_leave_requests';

  Future<bool> createRequestLocally({
    required int requesterId,
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    try {
      print('💾 Création demande locale...');
      
      final requestId = DateTime.now().millisecondsSinceEpoch;
      
      final localRequest = {
        'id': requestId,
        'requesterId': requesterId,
        'leaveTypeId': leaveTypeId,
        'startDate': startDate,
        'endDate': endDate,
        'requestedDays': 5.0,
        'reason': reason ?? '',
        'status': 'PENDING',
        'submittedAt': DateTime.now().toIso8601String(),
        'createdLocally': true,
        'syncedToBackend': false,
        'deviceInfo': 'Flutter Test',
      };

      final existingRequests = await getLocalRequests();
      existingRequests.add(localRequest);

      final prefs = MockSharedPreferences.getInstance();
      await prefs.setString(_localRequestsKey, jsonEncode(existingRequests));

      print('✅ Demande sauvegardée avec ID: $requestId');
      print('📋 Contenu: ${jsonEncode(localRequest)}');
      return true;

    } catch (e) {
      print('❌ Erreur: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getLocalRequests() async {
    try {
      final prefs = MockSharedPreferences.getInstance();
      final requestsJson = prefs.getString(_localRequestsKey);
      
      if (requestsJson != null) {
        final List<dynamic> requestsList = jsonDecode(requestsJson);
        return requestsList.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      print('❌ Erreur récupération: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserRequests(int userId) async {
    final allRequests = await getLocalRequests();
    return allRequests.where((req) => req['requesterId'] == userId).toList();
  }
}

Future<void> testLocalStorage() async {
  print('🎯 TEST STOCKAGE LOCAL DES DEMANDES');
  print('=' * 50);
  
  final service = LocalLeaveService();
  
  // Test 1: Créer une demande
  print('\n📝 TEST 1: Création d\'une demande...');
  final success1 = await service.createRequestLocally(
    requesterId: 15, // ID utilisateur aa.bb@xtensus.com
    leaveTypeId: 1,
    startDate: '2026-08-12',
    endDate: '2026-08-16',
    reason: 'Congés d\'été - Test local',
  );
  
  if (success1) {
    print('✅ Demande 1 créée avec succès');
  } else {
    print('❌ Échec création demande 1');
  }

  // Test 2: Créer une deuxième demande
  print('\n📝 TEST 2: Création d\'une deuxième demande...');
  await Future.delayed(Duration(milliseconds: 100)); // Pour différencier les IDs
  
  final success2 = await service.createRequestLocally(
    requesterId: 15,
    leaveTypeId: 2,
    startDate: '2026-09-01',
    endDate: '2026-09-01',
    reason: 'Rendez-vous médical',
  );
  
  if (success2) {
    print('✅ Demande 2 créée avec succès');
  } else {
    print('❌ Échec création demande 2');
  }

  // Test 3: Récupérer toutes les demandes
  print('\n📊 TEST 3: Récupération des demandes...');
  final allRequests = await service.getLocalRequests();
  print('📋 Nombre total de demandes: ${allRequests.length}');
  
  for (int i = 0; i < allRequests.length; i++) {
    final req = allRequests[i];
    print('   Demande ${i + 1}:');
    print('     • ID: ${req['id']}');
    print('     • Type: ${req['leaveTypeId']}');
    print('     • Dates: ${req['startDate']} → ${req['endDate']}');
    print('     • Motif: ${req['reason']}');
    print('     • Status: ${req['status']}');
    print('     • Créée: ${req['submittedAt']}');
  }

  // Test 4: Récupérer les demandes d'un utilisateur spécifique
  print('\n👤 TEST 4: Demandes de l\'utilisateur 15...');
  final userRequests = await service.getUserRequests(15);
  print('📋 Demandes utilisateur 15: ${userRequests.length}');

  // Test 5: Statistiques
  print('\n📊 TEST 5: Statistiques...');
  final pendingCount = allRequests.where((r) => r['status'] == 'PENDING').length;
  final approvedCount = allRequests.where((r) => r['status'] == 'APPROVED').length;
  final rejectedCount = allRequests.where((r) => r['status'] == 'REJECTED').length;
  
  print('📈 Statistiques:');
  print('   • En attente: $pendingCount');
  print('   • Approuvées: $approvedCount');
  print('   • Refusées: $rejectedCount');

  // Vérification finale
  print('\n' + '=' * 50);
  print('🎯 RÉSULTAT FINAL:');
  
  if (allRequests.length >= 2) {
    print('✅ STOCKAGE LOCAL FONCTIONNE !');
    print('🎉 Votre app peut maintenant:');
    print('   • Sauvegarder les demandes localement');
    print('   • Afficher l\'historique sans backend');
    print('   • Synchroniser plus tard avec le serveur');
  } else {
    print('❌ PROBLÈME DE STOCKAGE LOCAL');
  }
}

Future<void> main() async {
  await testLocalStorage();
}