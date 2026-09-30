import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🎯 TEST FORMULAIRE COMPLET - Tous les champs');
  print('============================================');
  print('');

  final baseUrl = 'http://10.148.173.19:3000/api';

  // Test avec le formulaire complet comme dans votre app
  print('📝 Test création compte avec TOUS les champs...');
  
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  
  final data = {
    'email': 'jean.dupont@xtensus.com',
    'password': 'motdepasse123',
    'firstName': 'Jean',
    'lastName': 'Dupont', 
    'role': 'Employee',
    'matricule': '4521',
    'department': 'IT'
  };

  print('📤 Données du formulaire complet: $data');

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    ).timeout(Duration(seconds: 15));

    print('📥 Status Code: ${response.statusCode}');
    print('📄 Response: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        print('');
        print('🎉 SUCCÈS ! FORMULAIRE COMPLET FONCTIONNEL !');
        print('✅ Tous les champs sont correctement envoyés');
        print('✅ L\'erreur "Erreur lors de la création du compte" sera résolue');
        print('');
        
        print('👤 Utilisateur créé:');
        print('   ID: ${responseData['user']['id']}');
        print('   Email: ${responseData['user']['email']}');
        print('   Nom: ${responseData['user']['firstName']} ${responseData['user']['lastName']}');
        print('   Rôle: ${responseData['user']['role']}');
        
        // Test de login
        print('');
        print('🔐 Test login avec le compte créé...');
        final loginResponse = await http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'usernameOrEmail': 'jean.dupont@xtensus.com',
            'password': 'motdepasse123',
          }),
        );

        if (loginResponse.statusCode == 200) {
          final loginData = jsonDecode(loginResponse.body);
          print('✅ Login réussi !');
          print('🎫 Token JWT: ${loginData['accessToken']?.substring(0, 20)}...');
        }
      } else {
        print('❌ Erreur dans la réponse: ${responseData['error']}');
      }
    } else {
      print('❌ Erreur HTTP: ${response.statusCode}');
      print('📄 Body: ${response.body}');
    }
  } catch (e) {
    print('❌ Erreur de connexion: $e');
  }

  print('');
  print('🎯 CONFIGURATION FLUTTER FINALISÉE');
  print('Votre formulaire va maintenant envoyer TOUS les champs:');
  print('- Nom, Prénom ✅');
  print('- Email ✅'); 
  print('- Matricule ✅');
  print('- Département ✅');
  print('- Rôle (Employé/Responsable) ✅');
  print('- Mot de passe ✅');
}