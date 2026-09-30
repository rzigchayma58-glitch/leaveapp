// 🔍 TEST CONNECTIVITÉ ONPLUS CPH2727
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> testOnPlusConnection() async {
  print('📱 TEST CONNECTIVITÉ ONPLUS CPH2727');
  print('=' * 40);
  
  // Toutes les URLs possibles pour votre OnePlus
  final testUrls = [
    'http://192.168.1.100:3000/api/flutter/test',
    'http://192.168.0.100:3000/api/flutter/test', 
    'http://10.148.173.19:3000/api/flutter/test',
    'http://172.16.0.1:3000/api/flutter/test',
    'http://10.0.0.1:3000/api/flutter/test',
  ];
  
  for (final url in testUrls) {
    print('\n🌐 Test: $url');
    try {
      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 5));
      print('✅ Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('🎉 CETTE URL FONCTIONNE SUR VOTRE ONPLUS !');
        print('📋 Réponse: ${response.body}');
        
        // Test login immédiat
        await testLoginWithThisUrl(url.replaceAll('/flutter/test', ''));
      }
    } catch (e) {
      print('❌ Échec: ${e.toString().substring(0, 50)}...');
    }
  }
  
  print('\n💡 SI AUCUNE URL NE FONCTIONNE :');
  print('1. Vérifiez que PC et OnePlus sont sur même WiFi');
  print('2. Trouvez votre vraie IP avec: ipconfig /all');
  print('3. Vérifiez firewall Windows/antivirus');
  print('4. Testez backend depuis PC: curl http://localhost:3000/api/flutter/test');
}

Future<void> testLoginWithThisUrl(String baseUrl) async {
  print('\n🔐 Test login avec: $baseUrl');
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usernameOrEmail': 'aa.bb@xtensus.com',
        'password': '123456',
      }),
    ).timeout(Duration(seconds: 10));
    
    print('📡 Login Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ LOGIN MARCHE ! Token: ${data['accessToken'].toString().substring(0, 20)}...');
      print('👤 User: ${data['user']['firstName']} ${data['user']['lastName']}');
      
      print('\n🎯 UTILISEZ CETTE URL DANS VOTRE ApiConfig :');
      print('static const String baseUrl = \'$baseUrl\';');
    } else {
      print('❌ Login échoué: ${response.body}');
    }
  } catch (e) {
    print('❌ Erreur login: $e');
  }
}

Future<void> main() async {
  await testOnPlusConnection();
}