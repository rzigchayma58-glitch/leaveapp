// 🚀 TEST RAPIDE - Création demande de congé avec votre compte existant
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('🔥 TEST RAPIDE DEMANDE DE CONGÉ');
  print('=' * 40);
  
  const baseUrl = 'http://10.148.173.19:3000/api';
  
  // Login avec votre compte existant
  print('\n🔐 Connexion avec votre compte...');
  String? token;
  int? userId;
  
  try {
    final authResponse = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usernameOrEmail': 'chaimaa.rz@xtensus.com',
        'password': 'chaimaa123'
      }),
    );
    
    if (authResponse.statusCode == 200) {
      final data = jsonDecode(authResponse.body);
      token = data['accessToken'];
      userId = data['user']['id'];
      print('✅ Connecté ! User ID: $userId');
    } else {
      print('❌ Erreur login: ${authResponse.body}');
      return;
    }
  } catch (e) {
    print('❌ Backend inaccessible: $e');
    print('💡 Démarrez votre backend Spring Boot d\'abord !');
    return;
  }

  // Test types de congé  
  print('\n📋 Types de congé disponibles...');
  try {
    final typesResponse = await http.get(
      Uri.parse('$baseUrl/conge-types'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (typesResponse.statusCode == 200) {
      final types = jsonDecode(typesResponse.body);
      print('✅ Types trouvés: ${types.length}');
      for (var type in types) {
        print('   - ID: ${type['id']}, Nom: ${type['name']}');
      }
    } else {
      print('❌ Pas de types trouvés: ${typesResponse.body}');
    }
  } catch (e) {
    print('❌ Erreur types: $e');
  }

  // Test création demande SIMPLE
  print('\n🚀 Test création demande SIMPLE...');
  try {
    final tomorrow = DateTime.now().add(Duration(days: 7));
    final dayAfter = tomorrow.add(Duration(days: 1));
    
    final simpleRequest = {
      'requesterId': userId,
      'startDate': formatDate(tomorrow),
      'endDate': formatDate(dayAfter),
      'reason': 'Test depuis Flutter - ${DateTime.now()}',
    };
    
    print('   Données: $simpleRequest');
    
    final response = await http.post(
      Uri.parse('$baseUrl/leave-requests'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(simpleRequest),
    );
    
    print('   Status: ${response.statusCode}');
    print('   Réponse: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('🎉 SUCCÈS ! Demande créée !');
      
      // Vérifier dans MySQL
      print('\n🔍 Vérification des demandes...');
      final checkResponse = await http.get(
        Uri.parse('$baseUrl/leave-requests/requester/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (checkResponse.statusCode == 200) {
        final requests = jsonDecode(checkResponse.body);
        print('✅ Demandes en BD: ${requests.length}');
        for (var req in requests) {
          print('   - ID: ${req['id']}, Status: ${req['status']}, Dates: ${req['startDate']} -> ${req['endDate']}');
        }
      }
    } else {
      print('❌ ÉCHEC: ${response.body}');
    }
    
  } catch (e) {
    print('❌ Erreur création: $e');
  }
}

String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}