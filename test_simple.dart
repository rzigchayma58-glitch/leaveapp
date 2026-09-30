import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔥 Test IMMÉDIAT Backend localhost:8080 avec adb reverse');
  
  try {
    // Test connexion basique
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:8080/api/auth/me'));
    final response = await request.close();
    print('✅ Backend accessible - Code: ${response.statusCode}');
    
    // Test login
    final loginRequest = await client.postUrl(Uri.parse('http://localhost:8080/api/auth/login'));
    loginRequest.headers.set('Content-Type', 'application/json');
    loginRequest.add(utf8.encode(jsonEncode({
      'usernameOrEmail': 'admin@test.com',
      'password': 'password123'
    })));
    
    final loginResponse = await loginRequest.close();
    final body = await loginResponse.transform(utf8.decoder).join();
    
    print('🔐 Login test - Code: ${loginResponse.statusCode}');
    print('📝 Réponse: ${body.substring(0, body.length > 200 ? 200 : body.length)}...');
    
    client.close();
    
  } catch (e) {
    print('❌ Erreur: $e');
    print('💡 Lancez d\'abord: adb reverse tcp:8080 tcp:8080');
  }
}