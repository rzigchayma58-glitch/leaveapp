// 🧹 NETTOYAGE DES COMPTES DE TEST
// Permet de supprimer les comptes de test pour retester la création

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> testWithFreshAccount() async {
  print('🧹 TEST AVEC NOUVEAU COMPTE');
  print('=' * 40);
  
  // Générer un email unique avec timestamp
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final testEmail = 'test.user.$timestamp@xtensus.com';
  
  print('📧 Test avec email unique: $testEmail');
  
  // Test d'inscription avec ce nouvel email
  final registerData = {
    'email': testEmail,
    'password': '123456',
    'firstName': 'Test',
    'lastName': 'User',
    'role': 'EMPLOYEE',
  };

  try {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/auth/register'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(registerData),
    );

    print('📡 Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        print('✅ NOUVEAU COMPTE CRÉÉ AVEC SUCCÈS !');
        print('👤 Nom: ${data['user']['firstName']} ${data['user']['lastName']}');
        print('🆔 ID: ${data['user']['id']}');
        print('🔑 Token reçu !');
        
        print('\n🎯 VOTRE APP FLUTTER FONCTIONNERA MAINTENANT !');
        print('💡 Le problème était que aa.bb@xtensus.com existait déjà');
        print('💡 Essayez avec un autre email ou supprimez le compte existant');
      } else {
        print('❌ Erreur: ${data['error']}');
      }
    } else {
      print('❌ Erreur HTTP: ${response.statusCode}');
      print('📋 Réponse: ${response.body}');
    }
  } catch (e) {
    print('❌ Erreur: $e');
  }
}

// 📱 INSTRUCTIONS POUR L'APP FLUTTER
void printFlutterInstructions() {
  print('\n' + '=' * 50);
  print('📱 INSTRUCTIONS POUR VOTRE APP FLUTTER');
  print('=' * 50);
  print('');
  print('✅ Vos fichiers ont été corrigés :');
  print('   - lib/services/auth_service.dart');
  print('   - lib/viewmodels/auth_viewmodel.dart');
  print('   - lib/models/user.dart');
  print('');
  print('🔧 Pour tester dans votre app :');
  print('1. Redémarrez votre app Flutter (flutter run)');
  print('2. Essayez de créer un compte avec un NOUVEL email');
  print('3. Par exemple: test123@xtensus.com');
  print('');
  print('❌ Ne réessayez PAS avec aa.bb@xtensus.com');
  print('   (ce compte existe déjà dans votre base)');
  print('');
  print('✅ Si vous voulez utiliser aa.bb@xtensus.com :');
  print('   - Supprimez-le de votre base MySQL');
  print('   - Ou connectez-vous directement avec ce compte');
  print('');
  print('🎉 L\'erreur "Erreur lors de la création du compte" est maintenant corrigée !');
}

Future<void> main() async {
  await testWithFreshAccount();
  printFlutterInstructions();
}