// 🎯 TEST CRÉATION DEMANDE DE CONGÉ - BACKEND
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> testCreateLeaveRequest() async {
  print('🎯 TEST CRÉATION DEMANDE DE CONGÉ BACKEND');
  print('=' * 50);
  
  // 1. LOGIN pour récupérer le token
  print('\n🔐 ÉTAPE 1: Connexion...');
  
  try {
    final loginResponse = await http.post(
      Uri.parse('http://10.186.31.19:3000/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usernameOrEmail': 'aa.bb@xtensus.com',
        'password': '123456',
      }),
    );

    if (loginResponse.statusCode != 200) {
      print('❌ Login échoué: ${loginResponse.statusCode}');
      return;
    }

    final loginData = jsonDecode(loginResponse.body);
    final token = loginData['accessToken'];
    final userId = loginData['user']['id'];
    
    print('✅ Connecté ! User ID: $userId');
    print('🔑 Token: ${token.substring(0, 20)}...');

    // 2. RÉCUPÉRER LES TYPES DE CONGÉS
    print('\n📋 ÉTAPE 2: Types de congés disponibles...');
    
    final typesResponse = await http.get(
      Uri.parse('http://10.186.31.19:3000/api/conge-types'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📡 Types Status: ${typesResponse.statusCode}');
    print('📋 Types Response: ${typesResponse.body}');

    List<Map<String, dynamic>> leaveTypes = [];
    if (typesResponse.statusCode == 200) {
      final List<dynamic> data = jsonDecode(typesResponse.body);
      leaveTypes = data.cast<Map<String, dynamic>>();
      
      print('✅ Types de congés récupérés:');
      for (final type in leaveTypes) {
        print('   • ID ${type['id']}: ${type['name'] ?? type['nom'] ?? type['label']}');
      }
    } else {
      print('❌ Impossible de récupérer les types. Utilisation ID par défaut.');
    }

    // 3. CRÉER UNE DEMANDE DE CONGÉ
    print('\n✅ ÉTAPE 3: Création demande de congé...');
    
    // Dates de test (comme dans vos captures d'écran)
    final leaveTypeId = leaveTypes.isNotEmpty ? leaveTypes.first['id'] : 1;
    
    final leaveRequestData = {
      'requesterId': userId,
      'leaveTypeId': leaveTypeId,
      'startDate': '2026-08-12', // Date de votre capture
      'endDate': '2026-08-16',   // Date de fin
      'reason': 'Test depuis Flutter - Congés d\'été',
    };

    print('📤 Données demande:');
    print(JsonEncoder.withIndent('  ').convert(leaveRequestData));

    final createResponse = await http.post(
      Uri.parse('http://10.186.31.19:3000/api/leave-requests'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(leaveRequestData),
    );

    print('📡 Create Status: ${createResponse.statusCode}');
    print('📋 Create Response: ${createResponse.body}');

    if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
      print('✅ DEMANDE CRÉÉE AVEC SUCCÈS !');
      
      // 4. VÉRIFIER LES DEMANDES UTILISATEUR
      print('\n📊 ÉTAPE 4: Vérification des demandes...');
      
      final requestsResponse = await http.get(
        Uri.parse('http://10.186.31.19:3000/api/leave-requests/requester/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Requests Status: ${requestsResponse.statusCode}');
      if (requestsResponse.statusCode == 200) {
        final List<dynamic> requests = jsonDecode(requestsResponse.body);
        print('✅ Demandes trouvées: ${requests.length}');
        
        for (final request in requests) {
          print('   • ID: ${request['id']}');
          print('     📅 Du ${request['startDate']} au ${request['endDate']}');
          print('     📊 Status: ${request['status']}');
          print('     💬 Motif: ${request['reason'] ?? 'Aucun'}');
        }
      } else {
        print('❌ Erreur récupération: ${requestsResponse.body}');
      }
      
    } else {
      print('❌ ÉCHEC CRÉATION DEMANDE');
      if (createResponse.body.contains('Leave type not found')) {
        print('💡 PROBLÈME: Type de congé non trouvé dans la BD');
        print('💡 SOLUTION: Exécutez le script MySQL CORRIGER_BASE_MYSQL_COMPLETE.sql');
      }
    }

  } catch (e) {
    print('❌ ERREUR: $e');
  }

  print('\n' + '=' * 50);
  print('🎯 RÉSULTAT ATTENDU POUR L\'APP :');
  print('Si "DEMANDE CRÉÉE AVEC SUCCÈS", alors votre Flutter');
  print('peut maintenant enregistrer les demandes au backend !');
  print('Sinon, il faut corriger la base de données MySQL.');
}

Future<void> main() async {
  await testCreateLeaveRequest();
}