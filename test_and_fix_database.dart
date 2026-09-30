// 🔧 TEST ET CORRECTION AUTOMATIQUE DE LA BASE DE DONNÉES
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('🔧 DIAGNOSTIC ET CORRECTION BASE DE DONNÉES');
  print('=' * 60);
  
  const baseUrl = 'http://10.148.173.19:3000/api';
  
  // Étape 1: Authentification
  print('\n🔐 1. Authentification...');
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
      print('✅ Authentification réussie - User ID: $userId');
    } else {
      print('❌ Authentification échouée');
      return;
    }
  } catch (e) {
    print('❌ Erreur authentification: $e');
    return;
  }

  // Étape 2: Diagnostic des endpoints
  print('\n🔍 2. Diagnostic des endpoints...');
  await diagnoseEndpoints(token!);
  
  // Étape 3: Tentative de création avec différents formats
  print('\n🚀 3. Tests de création avec différents formats...');
  await testDifferentFormats(token, userId!);
  
  // Étape 4: Suggestions pour corriger le backend
  print('\n💡 4. Suggestions de correction...');
  showFixSuggestions();
}

Future<void> diagnoseEndpoints(String token) async {
  final endpoints = [
    '/conge-types',
    '/leave-types', 
    '/leave-types/all',
    '/api/conge-types',
    '/api/leave-types',
  ];
  
  for (String endpoint in endpoints) {
    try {
      final url = endpoint.startsWith('/api') 
          ? 'http://10.148.173.19:3000$endpoint'
          : 'http://10.148.173.19:3000/api$endpoint';
          
      print('   Testant: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      print('   Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('   ✅ Données trouvées: ${data.length} éléments');
        for (var item in data) {
          print('     - ID: ${item['id']}, Nom: ${item['name'] ?? item['nom'] ?? 'N/A'}');
        }
      } else {
        print('   ❌ Erreur: ${response.body}');
      }
    } catch (e) {
      print('   ❌ Exception: $e');
    }
    print('');
  }
}

Future<void> testDifferentFormats(String token, int userId) async {
  final startDate = DateTime.now().add(Duration(days: 7));
  final endDate = startDate.add(Duration(days: 1));
  
  // Format 1: Standard avec leaveTypeId
  await testCreateFormat(token, userId, 'Format Standard', {
    'requesterId': userId,
    'leaveTypeId': 1,
    'startDate': formatDate(startDate),
    'endDate': formatDate(endDate),
    'reason': 'Test format standard',
  });
  
  // Format 2: Avec leaveType au lieu de leaveTypeId
  await testCreateFormat(token, userId, 'Format avec leaveType', {
    'requesterId': userId,
    'leaveType': {'id': 1},
    'startDate': formatDate(startDate),
    'endDate': formatDate(endDate),
    'reason': 'Test format leaveType object',
  });
  
  // Format 3: Avec typeId
  await testCreateFormat(token, userId, 'Format avec typeId', {
    'requesterId': userId,
    'typeId': 1,
    'startDate': formatDate(startDate),
    'endDate': formatDate(endDate),
    'reason': 'Test format typeId',
  });
  
  // Format 4: Avec des strings pour les IDs
  await testCreateFormat(token, userId, 'Format avec string IDs', {
    'requesterId': userId.toString(),
    'leaveTypeId': '1',
    'startDate': formatDate(startDate),
    'endDate': formatDate(endDate),
    'reason': 'Test format string IDs',
  });
  
  // Format 5: Format minimal
  await testCreateFormat(token, userId, 'Format minimal', {
    'requesterId': userId,
    'startDate': formatDate(startDate),
    'endDate': formatDate(endDate),
  });
}

Future<void> testCreateFormat(String token, int userId, String formatName, Map<String, dynamic> data) async {
  try {
    print('   🔧 Test: $formatName');
    print('   Données: $data');
    
    final response = await http.post(
      Uri.parse('http://10.148.173.19:3000/api/leave-requests'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    
    print('   Status: ${response.statusCode}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('   ✅ SUCCÈS ! Format trouvé !');
      final responseData = jsonDecode(response.body);
      print('   Réponse: $responseData');
      return;
    } else {
      print('   ❌ Échec: ${response.body}');
    }
  } catch (e) {
    print('   ❌ Exception: $e');
  }
  print('');
}

void showFixSuggestions() {
  print('''
💡 SUGGESTIONS POUR CORRIGER LE BACKEND:

🔍 Problème identifié: 
   - L'endpoint /api/conge-types fonctionne et retourne des types
   - Mais l'endpoint /api/leave-requests ne trouve pas ces types
   - Il y a probablement une incohérence dans les tables MySQL

🔧 Solutions possibles:

1. VÉRIFIER LES TABLES MYSQL:
   ```sql
   SHOW TABLES LIKE '%leave%';
   SHOW TABLES LIKE '%conge%';
   SELECT * FROM conge_types;
   SELECT * FROM leave_types; -- Cette table existe-t-elle ?
   ```

2. SI LA TABLE leave_types N'EXISTE PAS:
   ```sql
   CREATE TABLE leave_types (
     id BIGINT PRIMARY KEY,
     name VARCHAR(255),
     description TEXT,
     max_days INT DEFAULT 30
   );
   
   INSERT INTO leave_types (id, name, description, max_days) VALUES 
   (1, 'Congé annuel', 'Congé payé annuel', 30),
   (2, 'Autorisation d\'absence', 'Absence courte durée', 1);
   ```

3. VÉRIFIER LA TABLE DES DEMANDES:
   ```sql
   DESCRIBE conge_demandes;
   -- La colonne leaveTypeId existe-t-elle ?
   -- Y a-t-il une contrainte foreign key vers leave_types ?
   ```

4. DANS VOTRE CODE SPRING BOOT:
   - Vérifiez que l'entité LeaveType pointe vers la bonne table
   - Vérifiez le repository LeaveTypeRepository
   - Assurez-vous que la relation LeaveRequest -> LeaveType est correcte

🎯 PROCHAINE ÉTAPE:
   Exécutez ces requêtes SQL et corrigez les incohérences,
   puis relancez ce test pour vérifier que tout fonctionne.
  ''');
}

String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}