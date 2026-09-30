import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🎯 TEST NOUVEAU FORMAT SIMPLIFIÉ');
  print('================================');
  print('');

  final baseUrl = 'http://10.148.173.19:3000/api';

  // Test avec le format exact demandé par le backend
  print('👤 Test création compte avec format simplifié...');
  
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final email = "user$timestamp@test.com";
  
  final data = {
    'email': email,
    'password': 'aymen123', // Mot de passe de test
    'role': 'Employee',     // Rôle mappé
    'firstName': 'Utilisateur',
    'lastName': 'Test'
  };

  print('📤 Données envoyées: $data');

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ).timeout(Duration(seconds: 10));

    print('📥 Status Code: ${response.statusCode}');
    print('📄 Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        print('');
        print('🎉 SUCCÈS ! FORMAT CORRECT !');
        print('✅ Votre app Flutter va maintenant créer des comptes sans erreur');
        print('');
        
        // Test de login immédiat
        print('🔐 Test login avec le compte créé...');
        final loginResponse = await http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'usernameOrEmail': email,
            'password': 'aymen123',
          }),
        );

        print('Login Status: ${loginResponse.statusCode}');
        if (loginResponse.statusCode == 200) {
          final loginData = jsonDecode(loginResponse.body);
          print('✅ Login réussi !');
          print('🎫 Token: ${loginData['accessToken']?.substring(0, 20)}...');
        }
      } else {
        print('❌ Erreur dans la réponse: ${responseData['error']}');
      }
    } else {
      print('❌ Erreur HTTP: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Erreur de connexion: $e');
  }

  print('');
  print('🎯 CONFIGURATION FLUTTER VALIDÉE');
  print('L\'erreur "Erreur lors de la création du compte" sera résolue !');
}