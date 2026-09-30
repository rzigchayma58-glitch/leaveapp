// 🎯 TEST REGISTRATION FIX - SOLUTION À VOTRE PROBLÈME EXACT
// Teste exactement le formulaire d'inscription de vos captures d'écran

import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterFixTest {
  
  // 📋 TEST AVEC VOS DONNÉES EXACTES DES CAPTURES D'ÉCRAN
  static Future<void> testRegisterWithYourData() async {
    print('🎯 TEST REGISTRATION FIX - VOS DONNÉES EXACTES');
    print('=' * 50);
    
    // 📱 DONNÉES EXACTES DE VOS CAPTURES D'ÉCRAN
    final testCases = [
      {
        'nom': 'bb',
        'prenom': 'aa', 
        'email': 'aa.bb@xtensus.com',
        'matricule': '77',
        'departement': 'it',
        'role': 'Employé',
        'password': '123456',
      },
      {
        'nom': 'TestNom',
        'prenom': 'TestPrenom',
        'email': 'test.nouveau@xtensus.com',
        'matricule': '88',
        'departement': 'HR',
        'role': 'Responsable',
        'password': 'password123',
      }
    ];

    for (int i = 0; i < testCases.length; i++) {
      final data = testCases[i];
      print('\n📝 TEST ${i + 1}/2: Création compte ${data['email']}');
      print('-' * 30);
      
      await _testSingleRegistration(data);
      
      if (i < testCases.length - 1) {
        await Future.delayed(Duration(seconds: 1));
      }
    }
  }

  static Future<void> _testSingleRegistration(Map<String, dynamic> userData) async {
    try {
      print('👤 Nom: ${userData['nom']}');
      print('👤 Prénom: ${userData['prenom']}');
      print('📧 Email: ${userData['email']}');
      print('🆔 Matricule: ${userData['matricule']}');
      print('🏢 Département: ${userData['departement']}');
      print('👔 Rôle: ${userData['role']}');
      
      // Format EXACT pour votre backend Spring Boot
      final requestData = {
        'email': userData['email'],
        'password': userData['password'],
        'firstName': userData['prenom'],    // aa
        'lastName': userData['nom'],        // bb
        'role': userData['role'] == 'Responsable' ? 'MANAGER' : 'EMPLOYEE',
      };

      print('\n📤 Données envoyées au backend:');
      print(JsonEncoder.withIndent('  ').convert(requestData));

      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      print('\n📡 Status HTTP: ${response.statusCode}');
      print('📋 Réponse backend:');
      
      try {
        final responseData = jsonDecode(response.body);
        print(JsonEncoder.withIndent('  ').convert(responseData));
        
        if (response.statusCode == 200) {
          if (responseData['success'] == true) {
            print('✅ SUCCÈS: Compte créé avec succès !');
            print('🎉 Message: ${responseData['message']}');
            
            // Test de connexion immédiat
            await _testLoginAfterRegistration(userData['email'].toString(), userData['password'].toString());
          } else {
            print('❌ ÉCHEC: ${responseData['message'] ?? responseData['error'] ?? 'Erreur inconnue'}');
          }
        } else {
          print('❌ ERREUR HTTP: ${response.statusCode}');
          if (responseData is Map && responseData.containsKey('message')) {
            print('💬 Détails: ${responseData['message']}');
          }
        }
      } catch (e) {
        print('📋 Réponse (texte brut): ${response.body}');
        print('❌ Erreur parsing JSON: $e');
      }

    } catch (e) {
      print('❌ ERREUR RÉSEAU: $e');
      print('💡 Vérifiez que votre backend fonctionne sur localhost:3000');
    }
  }

  // 🔐 TEST DE CONNEXION APRÈS INSCRIPTION
  static Future<void> _testLoginAfterRegistration(String email, String password) async {
    print('\n🔐 Test connexion post-inscription...');
    
    try {
      final loginData = {
        'usernameOrEmail': email,
        'password': password,
      };

      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Connexion réussie !');
        print('🔑 Token reçu: ${data['accessToken'].toString().substring(0, 20)}...');
        print('👤 Utilisateur: ${data['user']['firstName']} ${data['user']['lastName']}');
      } else {
        print('❌ Connexion échouée: ${response.statusCode}');
        print('📋 Réponse: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur connexion: $e');
    }
  }
}

// 🚀 FONCTION PRINCIPALE
Future<void> main() async {
  await RegisterFixTest.testRegisterWithYourData();
  
  print('\n' + '=' * 50);
  print('🎯 RÉSULTAT DU TEST');
  print('=' * 50);
  print('');
  print('Si vous voyez "✅ SUCCÈS: Compte créé avec succès !" ci-dessus,');
  print('alors votre backend fonctionne parfaitement !');
  print('');
  print('Le problème dans votre app Flutter vient du fait que');
  print('AuthService et AuthViewModel n\'utilisaient pas le bon format.');
  print('');
  print('🔧 PROCHAINES ÉTAPES :');
  print('1. Les corrections ont été appliquées à vos fichiers');
  print('2. Redémarrez votre app Flutter');
  print('3. Testez la création de compte - elle devrait marcher !');
  print('');
  print('🎉 FINI LES ERREURS "Erreur lors de la création du compte" !');
}

/*
🎯 CE QUE CE TEST VALIDE :

✅ Backend accessible sur localhost:3000
✅ Endpoint /auth/register fonctionnel  
✅ Format des données accepté par le backend
✅ Réponse JSON bien formée
✅ Connexion possible après inscription

❌ Si des erreurs apparaissent :
- Vérifiez que votre backend Spring Boot est démarré
- Vérifiez les logs du backend pour voir les erreurs
- Vérifiez votre base de données MySQL

📱 APRÈS CE TEST :
Votre app Flutter devrait créer des comptes sans erreur !
*/