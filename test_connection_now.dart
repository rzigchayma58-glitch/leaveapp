// 🔍 TEST DE CONNECTIVITÉ IMMÉDIAT
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> testAllConnections() async {
  print('🔍 TEST DE CONNECTIVITÉ - TOUTES LES OPTIONS');
  print('=' * 50);
  
  final urls = [
    'http://localhost:3000/api/flutter/test',
    'http://10.0.2.2:3000/api/flutter/test',
    'http://10.148.173.19:3000/api/flutter/test',
    'http://127.0.0.1:3000/api/flutter/test',
  ];
  
  for (final url in urls) {
    print('\n🌐 Test: $url');
    try {
      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 5));
      print('✅ Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('🎉 CETTE URL FONCTIONNE !');
        print('📋 Réponse: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur: $e');
    }
  }
}

Future<void> main() async {
  await testAllConnections();
  
  print('\n📱 INSTRUCTIONS SELON VOTRE CONFIGURATION :');
  print('=' * 50);
  print('🔧 Si vous utilisez un ÉMULATEUR ANDROID :');
  print('   Utilisez: http://10.0.2.2:3000/api');
  print('');
  print('📱 Si vous utilisez un APPAREIL PHYSIQUE :');
  print('   Utilisez: http://10.148.173.19:3000/api');
  print('');
  print('🖥️ Si vous testez sur DESKTOP/WEB :');
  print('   Utilisez: http://localhost:3000/api');
}