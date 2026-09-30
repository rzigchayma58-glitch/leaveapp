// 🔍 TEST SPÉCIFIQUE CRÉATION DEMANDE DE CONGÉ
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('🔥 TEST CRÉATION DEMANDE DE CONGÉ');
  print('=' * 50);
  
  const baseUrl = 'http://10.148.173.19:3000/api';
  
  // Étape 1: Authentification
  print('\n🔐 1. Authentification...');
  String? token;
  int? userId;
  
  try {
    final loginData = {
      'usernameOrEmail': 'chaimaa.rz@xtensus.com',
      'password': 'chaimaa123'
    };
    
    final authResponse = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginData),
    );
    
    if (authResponse.statusCode == 200) {
      final data = jsonDecode(authResponse.body);
      token = data['accessToken'];
      userId = data['user']['id'];
      print('✅ Authentification réussie - User ID: $userId');
    } else {
      print('❌ Authentification échouée: ${authResponse.statusCode}');
      print('   Réponse: ${authResponse.body}');
      return;
    }
  } catch (e) {
    print('❌ Erreur authentification: $e');
    return;
  }
  
  // Étape 2: Vérifier les types de congé disponibles
  print('\n📋 2. Vérification des types de congé...');
  await checkLeaveTypes(token!);
  
  // Étape 3: Vérifier les demandes existantes
  print('\n📝 3. Vérification des demandes existantes...');
  await checkExistingRequests(token, userId!);
  
  // Étape 4: Créer une nouvelle demande
  print('\n🚀 4. Création d\'une nouvelle demande...');
  await createLeaveRequest(token, userId);
  
  // Étape 5: Vérifier à nouveau les demandes
  print('\n🔄 5. Vérification après création...');
  await checkExistingRequests(token, userId);
}

Future<void> checkLeaveTypes(String token) async {
  try {
    // Test plusieurs endpoints possibles
    final endpoints = [
      'http://10.148.173.19:3000/api/conge-types',
      'http://10.148.173.19:3000/api/leave-types',
    ];
    
    for (final endpoint in endpoints) {
      print('   Testant: $endpoint');
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('   Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final types = jsonDecode(response.body);
        print('✅ Types trouvés: ${types.length}');
        for (var type in types) {
          print('   - ID: ${type['id']}, Nom: ${type['name'] ?? type['nom'] ?? 'N/A'}');
        }
        return; // Sortir dès qu'on trouve les types
      } else {
        print('   Erreur: ${response.body}');
      }
    }
    
    print('❌ Aucun endpoint de types de congé ne fonctionne');
  } catch (e) {
    print('❌ Erreur types de congé: $e');
  }
}

Future<void> checkExistingRequests(String token, int userId) async {
  try {
    final response = await http.get(
      Uri.parse('http://10.148.173.19:3000/api/leave-requests/requester/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    print('   Status: ${response.statusCode}');
    print('   Réponse brute: ${response.body}');
    
    if (response.statusCode == 200) {
      final requests = jsonDecode(response.body);
      if (requests is List) {
        print('✅ Demandes trouvées: ${requests.length}');
        for (var request in requests) {
          print('   - ID: ${request['id']}, Status: ${request['status']}');
        }
      } else {
        print('⚠️ Format de réponse inattendu: ${requests.runtimeType}');
      }
    } else {
      print('❌ Erreur récupération demandes: ${response.body}');
    }
  } catch (e) {
    print('❌ Erreur check demandes: $e');
  }
}

Future<void> createLeaveRequest(String token, int userId) async {
  try {
    final startDate = DateTime.now().add(Duration(days: 7));
    final endDate = startDate.add(Duration(days: 2));
    
    final requestData = {
      'requesterId': userId,
      'leaveTypeId': 1, // On essaie avec l'ID 1
      'startDate': formatDate(startDate),
      'endDate': formatDate(endDate),
      'reason': 'Test création demande Flutter - ${DateTime.now()}',
    };
    
    print('   Données à envoyer:');
    print('   $requestData');
    
    final response = await http.post(
      Uri.parse('http://10.148.173.19:3000/api/leave-requests'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );
    
    print('   Status de réponse: ${response.statusCode}');
    print('   Réponse complète: ${response.body}');
    print('   Headers de réponse: ${response.headers}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Demande créée avec succès !');
      try {
        final responseData = jsonDecode(response.body);
        print('   Détails de la demande créée:');
        print('   ID: ${responseData['id'] ?? 'N/A'}');
        print('   Status: ${responseData['status'] ?? 'N/A'}');
        print('   Dates: ${responseData['startDate']} -> ${responseData['endDate']}');
      } catch (e) {
        print('   Impossible de parser la réponse JSON: $e');
      }
    } else {
      print('❌ Échec création demande');
      print('   Détails de l\'erreur: ${response.body}');
      
      // Essayons avec des IDs différents
      print('\n   🔄 Test avec d\'autres IDs de type de congé...');
      for (int typeId in [2, 3, 4]) {
        await tryCreateWithDifferentType(token, userId, typeId, startDate, endDate);
      }
    }
    
  } catch (e) {
    print('❌ Erreur création demande: $e');
  }
}

Future<void> tryCreateWithDifferentType(String token, int userId, int typeId, DateTime startDate, DateTime endDate) async {
  try {
    final requestData = {
      'requesterId': userId,
      'leaveTypeId': typeId,
      'startDate': formatDate(startDate),
      'endDate': formatDate(endDate),
      'reason': 'Test avec typeId $typeId',
    };
    
    print('     Essai avec leaveTypeId: $typeId');
    
    final response = await http.post(
      Uri.parse('http://10.148.173.19:3000/api/leave-requests'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );
    
    print('     Status: ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('     ✅ Succès avec typeId $typeId !');
    } else {
      print('     ❌ Échec: ${response.body}');
    }
  } catch (e) {
    print('     ❌ Erreur avec typeId $typeId: $e');
  }
}

String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}