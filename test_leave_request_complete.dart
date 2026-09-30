// 🎯 TEST COMPLET - DEMANDE DE CONGÉ AVEC BACKEND
// Teste l'intégration complète Flutter ↔ Spring Boot pour les demandes de congé

import 'dart:convert';
import 'package:http/http.dart' as http;

// 📋 Configuration identique à votre app
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}

class LeaveTestService {
  
  // 🔐 Login pour récupérer le token
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Connexion: $email');
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode({
          'usernameOrEmail': email,
          'password': password,
        }),
      );

      print('📡 Login Status: ${response.statusCode}');
      print('📋 Login Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'token': data['accessToken'],
          'user': data['user'],
        };
      }
      
      return {'success': false, 'error': 'Login failed'};
    } catch (e) {
      print('❌ Erreur login: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // 📋 Récupération des types de congés disponibles
  static Future<List<Map<String, dynamic>>> getLeaveTypes(String token) async {
    try {
      print('\n📋 Récupération des types de congés...');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/conge-types'),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Types Status: ${response.statusCode}');
      print('📋 Types Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      print('❌ Erreur types: $e');
      return [];
    }
  }

  // ✅ Création d'une demande de congé
  static Future<bool> createLeaveRequest({
    required String token,
    required int requesterId,
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    try {
      print('\n✅ Création demande de congé...');
      print('👤 Requester ID: $requesterId');
      print('📅 Dates: $startDate -> $endDate');
      print('🏷️ Type ID: $leaveTypeId');
      print('💬 Motif: ${reason ?? "Aucun"}');
      
      final requestData = {
        'requesterId': requesterId,
        'leaveTypeId': leaveTypeId,
        'startDate': startDate,
        'endDate': endDate,
        'reason': reason,
      };

      print('📋 Données envoyées: $requestData');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/leave-requests'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode(requestData),
      );

      print('📡 Create Status: ${response.statusCode}');
      print('📋 Create Response: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Erreur création: $e');
      return false;
    }
  }

  // 📊 Récupération des demandes utilisateur
  static Future<List<Map<String, dynamic>>> getUserRequests(
    String token, 
    int userId
  ) async {
    try {
      print('\n📊 Récupération des demandes utilisateur $userId...');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/leave-requests/requester/$userId'),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Requests Status: ${response.statusCode}');
      print('📋 Requests Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      print('❌ Erreur récupération: $e');
      return [];
    }
  }

  // 💰 Récupération du solde de congés
  static Future<List<Map<String, dynamic>>> getUserBalance(
    String token, 
    int userId
  ) async {
    try {
      print('\n💰 Récupération du solde utilisateur $userId...');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/leave-balances/user/$userId'),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Balance Status: ${response.statusCode}');
      print('📋 Balance Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      print('❌ Erreur solde: $e');
      return [];
    }
  }
}

// 🧪 FONCTION DE TEST COMPLÈTE
Future<void> testLeaveRequestComplete() async {
  print('🎯 TEST COMPLET - DEMANDES DE CONGÉ');
  print('=' * 50);

  // 🔐 ÉTAPE 1: Connexion
  print('\n🔐 ÉTAPE 1: Connexion utilisateur');
  final loginResult = await LeaveTestService.login(
    email: 'aa.bb@xtensus.com', // Votre compte de test
    password: '123456',
  );

  if (!loginResult['success']) {
    print('❌ ÉCHEC: Impossible de se connecter');
    print('💡 Vérifiez que votre backend est démarré sur localhost:3000');
    return;
  }

  final token = loginResult['token'];
  final user = loginResult['user'];
  final userId = user['id'];
  
  print('✅ Connexion réussie !');
  print('👤 Utilisateur: ${user['firstName']} ${user['lastName']}');
  print('🆔 ID: $userId');
  print('🔑 Token: ${token.toString().substring(0, 20)}...');

  // 📋 ÉTAPE 2: Récupération des types de congés
  print('\n📋 ÉTAPE 2: Types de congés disponibles');
  final leaveTypes = await LeaveTestService.getLeaveTypes(token);
  
  if (leaveTypes.isEmpty) {
    print('❌ ATTENTION: Aucun type de congé trouvé');
    print('💡 Vérifiez votre table conge_types ou leave_types');
    // On continue quand même avec un ID par défaut
  } else {
    print('✅ Types de congés récupérés:');
    for (final type in leaveTypes) {
      print('   • ID ${type['id']}: ${type['name'] ?? type['label'] ?? type['nom']}');
    }
  }

  // ✅ ÉTAPE 3: Création d'une demande de congé
  print('\n✅ ÉTAPE 3: Création d\'une nouvelle demande');
  
  // Utiliser le premier type disponible ou ID 1 par défaut
  final leaveTypeId = leaveTypes.isNotEmpty ? leaveTypes.first['id'] : 1;
  
  // Dates de test (semaine prochaine)
  final now = DateTime.now();
  final startDate = now.add(Duration(days: 7));
  final endDate = startDate.add(Duration(days: 4)); // 5 jours de congé
  
  final formatDate = (DateTime date) => 
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  final success = await LeaveTestService.createLeaveRequest(
    token: token,
    requesterId: userId,
    leaveTypeId: leaveTypeId,
    startDate: formatDate(startDate),
    endDate: formatDate(endDate),
    reason: 'Test de congé depuis Flutter - Intégration réussie !',
  );

  if (success) {
    print('✅ Demande créée avec succès !');
  } else {
    print('❌ ÉCHEC: Impossible de créer la demande');
    print('💡 Vérifiez votre table conge_demandes/leave_requests');
    print('💡 Vérifiez que le leaveTypeId existe dans votre BD');
  }

  // 📊 ÉTAPE 4: Vérification - Récupération des demandes
  print('\n📊 ÉTAPE 4: Vérification des demandes créées');
  final userRequests = await LeaveTestService.getUserRequests(token, userId);
  
  if (userRequests.isEmpty) {
    print('❌ Aucune demande trouvée pour cet utilisateur');
  } else {
    print('✅ Demandes trouvées: ${userRequests.length}');
    for (final request in userRequests) {
      print('   • ID: ${request['id']}');
      print('     📅 Période: ${request['startDate']} -> ${request['endDate']}');
      print('     📊 Status: ${request['status']}');
      print('     💬 Motif: ${request['reason'] ?? 'Aucun'}');
      print('     ⏰ Créé: ${request['submittedAt']}');
    }
  }

  // 💰 ÉTAPE 5: Vérification du solde
  print('\n💰 ÉTAPE 5: Solde de congés');
  final userBalance = await LeaveTestService.getUserBalance(token, userId);
  
  if (userBalance.isEmpty) {
    print('❌ Aucun solde trouvé pour cet utilisateur');
    print('💡 Vérifiez votre table leave_balances');
  } else {
    print('✅ Soldes de congés:');
    for (final balance in userBalance) {
      final leaveType = balance['leaveType'];
      print('   • ${leaveType['name']}:');
      print('     📊 Total: ${balance['totalDays']} jours');
      print('     ✅ Utilisés: ${balance['usedDays']} jours');
      print('     💰 Restants: ${balance['remainingDays']} jours');
    }
  }

  // 📊 RÉSUMÉ FINAL
  print('\n📊 RÉSUMÉ FINAL');
  print('=' * 30);
  print('✅ Connexion: ${loginResult['success'] ? 'OK' : 'ÉCHEC'}');
  print('✅ Types congés: ${leaveTypes.isNotEmpty ? 'OK' : 'ATTENTION'}');
  print('✅ Création demande: ${success ? 'OK' : 'ÉCHEC'}');
  print('✅ Récup. demandes: ${userRequests.isNotEmpty ? 'OK' : 'ATTENTION'}');
  print('✅ Solde congés: ${userBalance.isNotEmpty ? 'OK' : 'ATTENTION'}');

  if (success && userRequests.isNotEmpty) {
    print('\n🎉 INTÉGRATION LEAVE REQUEST COMPLÈTE !');
    print('🎯 Votre app peut maintenant gérer les demandes de congé !');
  } else {
    print('\n⚠️ PROBLÈMES DÉTECTÉS');
    print('💡 Vérifiez votre base de données MySQL');
    print('💡 Exécutez le script CORRIGER_BASE_MYSQL_COMPLETE.sql');
  }
}

// 🚀 LANCEMENT DU TEST
void main() async {
  await testLeaveRequestComplete();
}

/*
🎯 COMMENT UTILISER CE TEST :

1. Vérifiez que votre backend Spring Boot fonctionne sur localhost:3000
2. Lancez le test: dart run test_leave_request_complete.dart
3. Le test va :
   ✅ Se connecter avec aa.bb@xtensus.com / 123456
   ✅ Récupérer les types de congés disponibles 
   ✅ Créer une nouvelle demande de congé
   ✅ Vérifier que la demande est sauvegardée
   ✅ Afficher le solde de congés

4. Si tout fonctionne, votre intégration est parfaite ! 🎉
5. Si des erreurs apparaissent, elles vous indiquent quoi corriger dans MySQL.

📝 RÉSULTAT ATTENDU :
Si votre backend et votre base de données sont bien configurés,
vous devriez voir toutes les étapes marquées comme "OK" !
*/