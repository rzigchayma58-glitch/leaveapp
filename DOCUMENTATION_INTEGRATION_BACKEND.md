# 📋 Documentation d'Intégration - XCongés Flutter ↔ Spring Boot API
## Application Mobile Flutter avec Backend Spring Boot

### 🎯 Vue d'ensemble

Cette documentation détaille l'intégration entre l'application mobile Flutter **XCongés** et l'API Spring Boot existante. L'application mobile doit s'adapter aux endpoints et formats de données du backend déjà déployé.

**🔗 API Backend**: `http://localhost:8080`  
**🎨 Frontend**: Flutter 3.11+ avec Provider (MVVM)  
**🔐 Authentification**: JWT Bearer Token  
**📱 Version**: 1.0.0+1

---

## 🏗️ Architecture d'Intégration

### **Stack Existant Backend**
- **Framework** : Spring Boot 3.4.1 avec Java 17
- **Authentification** : JWT Bearer Token
- **Base de données** : (à préciser selon votre config)
- **CORS** : Configuré pour `localhost:4200` (à adapter pour mobile)

### **Stack Flutter Mobile**
- **Framework** : Flutter 3.11+ (Dart)
- **État** : Provider (MVVM Pattern)
- **HTTP Client** : À implémenter avec `http` package
- **Stockage local** : SharedPreferences pour token/cache
- **Fichiers** : file_picker, image_picker

---

## � Authentification JWT

### **POST /api/auth/login** ✅ *API Existante*
Authentification utilisateur avec username ou email

**Request Body** (format backend):
```json
{
  "usernameOrEmail": "string",
  "password": "string"
}
```

**Response Backend (200)**:
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "tokenType": "Bearer",
  "expiresIn": 3600000,
  "user": {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "EMPLOYEE",
    "status": "ACTIVE",
    "enabled": true,
    "department": {
      "id": 1,
      "name": "IT"
    },
    "position": {
      "id": 1,
      "name": "Developer"
    },
    "manager": {
      "id": 2,
      "firstName": "Jane",
      "lastName": "Manager"
    }
  }
}
```

**🔧 Adaptation Flutter Required:**
L'app Flutter doit adapter son modèle `User` pour correspondre à la structure backend:

```dart
// Modèle User Flutter à adapter
class User {
  final int id;                    // était String dans la doc originale
  final String username;           // nouveau champ du backend
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;            // EMPLOYEE|MANAGER|HR|ADMIN
  final String status;            // ACTIVE|INACTIVE|SUSPENDED
  final bool enabled;
  final Department? department;    // objet avec id + name
  final Position? position;       // objet avec id + name  
  final Manager? manager;         // objet avec id + firstName + lastName
}

enum UserRole {
  employee,  // -> EMPLOYEE
  manager,   // -> MANAGER  
  hr,        // -> HR
  admin      // -> ADMIN
}
```

### **GET /api/auth/me** ✅ *API Existante*
Informations utilisateur connecté

**Headers Required:**
```http
Authorization: Bearer {accessToken}
```

**🔄 Flutter Integration:**
```dart
class AuthService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  Future<LoginResponse?> login(String emailOrUsername, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usernameOrEmail': emailOrUsername,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    }
    return null;
  }
  
  Future<User?> getCurrentUser() async {
    final token = await getStoredToken();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }
}
```

---

## 📝 API Gestion des Demandes de Congé

### **POST /api/leave-requests** ✅ *API Existante*
Création d'une nouvelle demande

**Headers Required:**
```http
Authorization: Bearer {accessToken}
Content-Type: application/json
```

**Request Body (Format Backend):**
```json
{
  "leaveTypeId": 1,
  "startDate": "2024-12-01",
  "endDate": "2024-12-05", 
  "reason": "Vacances familiales",
  "medicalCertificateRequired": false
}
```

**🔧 Mapping Flutter → Backend:**
```dart
// Modèle Flutter à adapter
class LeaveRequestDto {
  final int leaveTypeId;        // Mapping du type de congé Flutter
  final String startDate;      // Format YYYY-MM-DD
  final String endDate;        // Format YYYY-MM-DD  
  final String reason;         // Correspond au comment Flutter
  final bool medicalCertificateRequired;
}

// Mapping des types de congés Flutter vers IDs backend
Map<LeaveNature, int> leaveTypeMapping = {
  LeaveNature.annual: 1,       // Congé annuel
  LeaveNature.exceptional: 2,  // Congé exceptionnel
  LeaveNature.sick: 3,         // Congé maladie  
  LeaveNature.other: 4,        // Autre motif
};
```

### **GET /api/leave-requests** ✅ *API Existante*
Récupération de toutes les demandes (HR/Admin)

### **GET /api/leave-requests/requester/{userId}** ✅ *API Existante*
Demandes d'un employé spécifique

**🔄 Flutter Integration:**
```dart
class LeaveService {
  Future<List<LeaveRequest>> getUserRequests(int userId) async {
    final token = await getStoredToken();
    final response = await http.get(
      Uri.parse('$baseUrl/leave-requests/requester/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => LeaveRequest.fromBackendJson(json)).toList();
    }
    return [];
  }
}
```

### **GET /api/leave-requests/approver/{managerId}** ✅ *API Existante*
Demandes à approuver (Manager/HR/Admin uniquement)

### **PATCH /api/leave-requests/{id}/approve** ✅ *API Existante*
Approbation d'une demande

**Request Body:**
```json
{
  "comments": "Approuvé - bon voyage !"
}
```

### **PATCH /api/leave-requests/{id}/reject** ✅ *API Existante*
Refus d'une demande

**Request Body:**
```json
{
  "comments": "Refusé - période trop chargée",
  "reason": "WORKLOAD_CONFLICT"
}
```

### **PUT /api/leave-requests/{id}** ✅ *API Existante*
Modification d'une demande

---

## 👥 API Gestion des Utilisateurs

### **GET /api/users** ✅ *API Existante*
Liste de tous les utilisateurs (HR/Admin)

### **GET /api/users/{id}** ✅ *API Existante*
Utilisateur par ID

### **GET /api/users/role/{role}** ✅ *API Existante*
Utilisateurs par rôle (EMPLOYEE|MANAGER|HR|ADMIN)

### **GET /api/users/{managerId}/team** ✅ *API Existante*
Équipe d'un manager

### **POST /api/users** ✅ *API Existante*
Création d'un utilisateur (HR/Admin)

**Request Body:**
```json
{
  "username": "newuser",
  "email": "newuser@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+33123456789",
  "hireDate": "2024-01-15",
  "role": "EMPLOYEE",
  "managerId": 2,
  "departmentId": 1,
  "positionId": 1
}
```

---

## 🏢 API Départements

### **GET /api/departments** ✅ *API Existante*
### **GET /api/departements** ✅ *Alias Français*
Liste des départements

### **POST /api/departments** ✅ *API Existante*
### **POST /api/departements** ✅ *Alias Français*
Création département (HR/Admin)

**Request Body:**
```json
{
  "name": "Développement",
  "description": "Équipe de développement logiciel"
}
```

---

## 📄 API Certificats Médicaux

### **POST /api/certificats-medicaux-v2/televerser/{congeDemandeId}** ✅ *API Existante*
Upload certificat médical

**Headers:**
```http
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Form Data:**
- `file`: Fichier PDF ou image

**🔄 Flutter Integration:**
```dart
Future<bool> uploadMedicalCertificate(int requestId, File file) async {
  final token = await getStoredToken();
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/certificats-medicaux-v2/televerser/$requestId'),
  );
  
  request.headers['Authorization'] = 'Bearer $token';
  request.files.add(await http.MultipartFile.fromPath('file', file.path));
  
  final response = await request.send();
  return response.statusCode == 200;
}
```

### **GET /api/certificats-medicaux-v2/telecharger/{id}** ✅ *API Existante*
Téléchargement certificat

---

## 💰 API Soldes de Congé

### **GET /api/leave-balances/user/{userId}** ✅ *API Existante*
Solde de congés d'un utilisateur

**Response:**
```json
{
  "id": 1,
  "userId": 1,
  "leaveTypeId": 1,
  "totalDays": 25,
  "usedDays": 5,
  "remainingDays": 20,
  "year": 2024
}
```

**🔧 Adaptation Flutter:**
```dart
class LeaveBalance {
  final int id;
  final int userId;
  final int leaveTypeId;
  final int totalDays;
  final int usedDays;
  final int remainingDays;
  final int year;
  
  // Propriété calculée pour compatibilité avec l'UI Flutter existante
  int get availableDays => remainingDays;
  
  factory LeaveBalance.fromBackendJson(Map<String, dynamic> json) {
    return LeaveBalance(
      id: json['id'],
      userId: json['userId'],
      leaveTypeId: json['leaveTypeId'],
      totalDays: json['totalDays'],
      usedDays: json['usedDays'],
      remainingDays: json['remainingDays'],
      year: json['year'],
    );
  }
}
```

---

## 🔧 Adaptations Flutter Requises

### **1. Modèles de Données à Adapter**

#### **User Model - Adaptation majeure requise**
```dart
// AVANT (modèle Flutter actuel)
class User {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String employeeId;
  final String department;
  final UserRole role;
}

// APRÈS (adapté au backend Spring Boot)
class User {
  final int id;                    // Int au lieu de String
  final String username;           // Nouveau champ requis
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;            // Nouveau champ optionnel
  final String? hireDate;         // Nouveau champ optionnel
  final UserRole role;            // Enum à adapter
  final UserStatus status;        // Nouveau champ
  final bool enabled;             // Nouveau champ
  final Department? department;    // Objet au lieu de String
  final Position? position;       // Nouveau champ
  final Manager? manager;         // Nouveau champ

  factory User.fromBackendJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      hireDate: json['hireDate'],
      role: _parseRole(json['role']),
      status: _parseStatus(json['status']),
      enabled: json['enabled'] ?? true,
      department: json['department'] != null 
        ? Department.fromJson(json['department']) 
        : null,
      position: json['position'] != null 
        ? Position.fromJson(json['position']) 
        : null,
      manager: json['manager'] != null 
        ? Manager.fromJson(json['manager']) 
        : null,
    );
  }

  static UserRole _parseRole(String role) {
    switch (role) {
      case 'EMPLOYEE': return UserRole.employee;
      case 'MANAGER': return UserRole.manager;
      case 'HR': return UserRole.hr;
      case 'ADMIN': return UserRole.admin;
      default: return UserRole.employee;
    }
  }

  static UserStatus _parseStatus(String status) {
    switch (status) {
      case 'ACTIVE': return UserStatus.active;
      case 'INACTIVE': return UserStatus.inactive;
      case 'SUSPENDED': return UserStatus.suspended;
      default: return UserStatus.active;
    }
  }
}

enum UserRole { employee, manager, hr, admin }
enum UserStatus { active, inactive, suspended }

class Department {
  final int id;
  final String name;
  final String? description;
  
  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class Position {
  final int id;
  final String name;
  
  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Manager {
  final int id;
  final String firstName;
  final String lastName;
  
  String get fullName => '$firstName $lastName';
  
  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
}
```

#### **LeaveRequest Model - Adaptation majeure requise**
```dart
// Nouveau modèle adapté au backend
class LeaveRequest {
  final int? id;                   // Int au lieu de String
  final int userId;                // Int au lieu de String
  final int leaveTypeId;          // Nouveau - référence au type via ID
  final String startDate;         // Format YYYY-MM-DD
  final String? endDate;          // Format YYYY-MM-DD
  final String? reason;           // Équivalent du comment Flutter
  final bool? medicalCertificateRequired;
  final LeaveRequestStatus status;
  final DateTime createdAt;
  final String? approverComments; // Commentaires du manager
  final String? rejectionReason;  // Raison du refus
  final DateTime? processedAt;    // Date traitement

  // Propriétés calculées pour compatibilité UI existante
  LeaveType get type => _getFlutterType(leaveTypeId);
  LeaveNature? get nature => _getFlutterNature(leaveTypeId);
  String? get comment => reason;
  
  // Mapping types backend → Flutter
  static LeaveType _getFlutterType(int leaveTypeId) {
    // À adapter selon votre configuration backend
    if (leaveTypeId == 99) return LeaveType.absence; // Si vous avez un type "absence"
    return LeaveType.leave; // La plupart sont des congés
  }
  
  static LeaveNature _getFlutterNature(int leaveTypeId) {
    switch (leaveTypeId) {
      case 1: return LeaveNature.annual;
      case 2: return LeaveNature.exceptional;
      case 3: return LeaveNature.sick;
      case 4: return LeaveNature.other;
      default: return null;
    }
  }

  factory LeaveRequest.fromBackendJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      userId: json['userId'] ?? json['requesterId'],
      leaveTypeId: json['leaveTypeId'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      reason: json['reason'],
      medicalCertificateRequired: json['medicalCertificateRequired'],
      status: _parseStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      approverComments: json['approverComments'],
      rejectionReason: json['rejectionReason'],
      processedAt: json['processedAt'] != null 
        ? DateTime.parse(json['processedAt']) 
        : null,
    );
  }

  Map<String, dynamic> toBackendJson() {
    return {
      'leaveTypeId': leaveTypeId,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
      'medicalCertificateRequired': medicalCertificateRequired ?? false,
    };
  }
}
```

### **2. Service d'Authentification Adapté**
```dart
class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Pour émulateur Android
  
  Future<LoginResponse?> login(String emailOrUsername, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usernameOrEmail': emailOrUsername, // Format backend
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Adapter la réponse au format attendu par Flutter
        final loginResponse = LoginResponse(
          accessToken: data['accessToken'],
          tokenType: data['tokenType'],
          expiresIn: data['expiresIn'],
          user: User.fromBackendJson(data['user']),
        );
        
        // Stocker le token
        await _storeAuthData(loginResponse);
        return loginResponse;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<void> _storeAuthData(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', response.accessToken);
    await prefs.setString('token_type', response.tokenType);
    await prefs.setInt('expires_in', response.expiresIn);
    await prefs.setString('user_data', jsonEncode(response.user.toJson()));
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}

class LoginResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final User user;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });
}
```

### **3. Service de Gestion des Congés Adapté**
```dart
class LeaveService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  Future<List<LeaveRequest>> getUserRequests(int userId) async {
    final token = await AuthService().getStoredToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/leave-requests/requester/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => LeaveRequest.fromBackendJson(json)).toList();
    }
    
    throw Exception('Échec de récupération des demandes');
  }

  Future<bool> submitRequest(LeaveRequest request) async {
    final token = await AuthService().getStoredToken();
    
    final response = await http.post(
      Uri.parse('$baseUrl/leave-requests'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toBackendJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<LeaveBalance>> getUserBalance(int userId) async {
    final token = await AuthService().getStoredToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/leave-balances/user/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Le backend peut retourner un seul objet ou une liste
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((json) => LeaveBalance.fromBackendJson(json)).toList();
      } else {
        return [LeaveBalance.fromBackendJson(data)];
      }
    }
    
    return [];
  }
}
```

### **4. Configuration Réseau**
```dart
// Configuration pour développement local
class ApiConfig {
  // Pour émulateur Android
  static const String baseUrlAndroid = 'http://10.0.2.2:8080/api';
  
  // Pour émulateur iOS
  static const String baseUrlIOS = 'http://127.0.0.1:8080/api';
  
  // Pour appareil physique (remplacer par IP locale)
  static const String baseUrlDevice = 'http://192.168.1.100:8080/api';
  
  static String get baseUrl {
    if (Platform.isAndroid) {
      return baseUrlAndroid;
    } else if (Platform.isIOS) {
      return baseUrlIOS;  
    } else {
      return baseUrlDevice;
    }
  }
}
```

---

## 🔄 Guide de Migration

### **Étape 1: Mise à Jour des Dépendances**
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0              # Pour les appels API
  shared_preferences: ^2.2.2 # Stockage token (déjà présent)
  provider: ^6.1.2           # État management (déjà présent)
```

### **Étape 2: Adaptation des Modèles**
1. ✅ Mettre à jour le modèle `User` 
2. ✅ Mettre à jour le modèle `LeaveRequest`
3. ✅ Créer les nouveaux modèles `Department`, `Position`, `Manager`
4. ✅ Adapter les énumérations

### **Étape 3: Services HTTP**
1. ✅ Remplacer les services mock par des appels HTTP réels
2. ✅ Implémenter la gestion des erreurs HTTP
3. ✅ Ajouter la gestion des tokens JWT

### **Étape 4: Interface Utilisateur**
1. ✅ Adapter les formulaires aux nouveaux champs
2. ✅ Mettre à jour les écrans de profil
3. ✅ Adapter l'affichage des demandes

### **Étape 5: Tests et Validation**
1. ✅ Tester l'authentification
2. ✅ Tester la création de demandes
3. ✅ Tester l'upload de certificats
4. ✅ Valider l'affichage des données

---

## 🗄️ Modèles de Base de Données

### **Table: users**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    department VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'employee',
    manager_id UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### **Table: leave_requests**
```sql
CREATE TABLE leave_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    type VARCHAR(20) NOT NULL CHECK (type IN ('leave', 'absence')),
    nature VARCHAR(20) CHECK (nature IN ('annual', 'exceptional', 'sick', 'other')),
    start_date DATE NOT NULL,
    end_date DATE,
    start_time TIME,
    end_time TIME,
    comment TEXT,
    working_days INTEGER,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    manager_id UUID REFERENCES users(id),
    manager_comment TEXT,
    processed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### **Table: leave_attachments**
```sql
CREATE TABLE leave_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES leave_requests(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_type VARCHAR(50) NOT NULL,
    file_size INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### **Table: notifications**
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    data JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### **Table: user_balances**
```sql
CREATE TABLE user_balances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    year INTEGER NOT NULL,
    annual_days INTEGER DEFAULT 25,
    used_annual_days INTEGER DEFAULT 0,
    carry_over_days INTEGER DEFAULT 0,
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, year)
);
```

---

## 🔐 Sécurité et Authentification

### **JWT Token Structure**
```json
{
  "sub": "user-uuid",
  "email": "user@domain.com",
  "role": "employee|manager|admin",
  "department": "string",
  "iat": 1692345600,
  "exp": 1692432000
}
```

### **Middleware d'Authorization**
```javascript
// Vérification rôles
function requireRole(roles) {
    return (req, res, next) => {
        if (!roles.includes(req.user.role)) {
            return res.status(403).json({
                success: false,
                error: { code: 'FORBIDDEN', message: 'Accès refusé' }
            });
        }
        next();
    };
}

// Vérification propriétaire ressource
function requireOwnershipOrManager(req, res, next) {
    const resourceUserId = req.params.userId || req.body.userId;
    
    if (req.user.id === resourceUserId || 
        req.user.role === 'manager' || 
        req.user.role === 'admin') {
        return next();
    }
    
    return res.status(403).json({
        success: false,
        error: { code: 'FORBIDDEN', message: 'Accès refusé à cette ressource' }
    });
}
```

---

## 📱 Notifications Push (FCM)

### **Configuration Firebase**
1. Configurer projet Firebase avec FCM
2. Intégrer SDK Android/iOS dans l'app Flutter
3. Gérer tokens de devices côté backend

### **Envoi Notifications Automatiques**
```javascript
// Lors de l'approbation/refus d'une demande
async function sendRequestStatusNotification(request, status) {
    const user = await getUserById(request.userId);
    const deviceTokens = await getDeviceTokens(user.id);
    
    const notification = {
        title: status === 'approved' ? 'Demande approuvée ✅' : 'Demande refusée ❌',
        body: `Votre ${request.type === 'leave' ? 'congé' : 'autorisation d\'absence'} du ${formatDate(request.startDate)} a été ${status === 'approved' ? 'approuvé' : 'refusé'}`,
        data: {
            requestId: request.id,
            type: `request${status.charAt(0).toUpperCase() + status.slice(1)}`,
            actionUrl: `/leave-requests/${request.id}`
        }
    };
    
    await sendToMultipleDevices(deviceTokens, notification);
    
    // Sauvegarder aussi en base pour l'historique
    await createNotification({
        userId: user.id,
        title: notification.title,
        message: notification.body,
        type: `request${status.charAt(0).toUpperCase() + status.slice(1)}`,
        data: notification.data
    });
}
```

---

## ⚡ Performance et Optimisation

### **Caching Strategy**
- **Redis** : Cache des soldes utilisateurs (TTL 1h)
- **Database** : Index sur `user_id`, `status`, `created_at`
- **Files** : CDN pour stockage/livraison pièces jointes

### **Rate Limiting**
```javascript
// Limites par endpoint
const rateLimits = {
    '/api/leave-requests': { requests: 10, window: '15m' },
    '/api/files/upload': { requests: 5, window: '5m' },
    '/api/auth/login': { requests: 5, window: '15m' }
};
```

### **Pagination Standard**
- Limite par défaut : 20 items
- Maximum : 100 items  
- Métadonnées : `current`, `total`, `pages`

---

## 🧪 Tests et Validation

### **Endpoints de Test**
```bash
# Authentification
POST /api/auth/login
{
  "email": "test@xtensus.com",
  "password": "test123456"
}

# Création demande
POST /api/leave-requests
{
  "type": "leave",
  "nature": "annual", 
  "startDate": "2026-09-01T00:00:00Z",
  "endDate": "2026-09-05T00:00:00Z",
  "workingDays": 5,
  "comment": "Vacances d'été"
}
```

### **Cas de Test Critiques**
1. **Validation délais** : Demande avec startDate < 72h
2. **Durée absence** : Autorisation > 2h  
3. **Solde insuffisant** : Demande dépassant solde disponible
4. **Upload fichier** : Fichier > 5MB ou type non autorisé
5. **Autorizations** : Accès ressources d'autres utilisateurs

---

## 📋 Checklist d'Implémentation

### **Phase 1 - APIs Essentielles** ✅
- [ ] Authentification (login, register, refresh)
- [ ] CRUD demandes de congés
- [ ] Upload/téléchargement fichiers
- [ ] Calcul soldes et statistiques

### **Phase 2 - Fonctionnalités Avancées** ⚙️
- [ ] API Manager (approbation/refus)
- [ ] Système notifications en base
- [ ] Validation avancée (jours fériés, règles métier)
- [ ] Audit trail et logs

### **Phase 3 - Production Ready** 🚀
- [ ] Notifications Push FCM
- [ ] Monitoring et métriques
- [ ] Backup et recovery
- [ ] Tests d'intégration complets
- [ ] Documentation API complète

---

## 🔗 Ressources Complémentaires

- **Swagger/OpenAPI** : Documentation interactive des APIs
- **Postman Collection** : Collection de tests pour tous les endpoints  
- **Database Migrations** : Scripts de création/migration des tables
- **Environment Variables** : Configuration déploiement (dev/staging/prod)

---

**💡 Cette documentation couvre tous les aspects d'intégration nécessaires pour connecter l'application Flutter XCongés avec un backend robuste. Les exemples de code et structures de données sont directement utilisables pour l'implémentation.**