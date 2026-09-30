# 🔍 VÉRIFICATION ENDPOINTS SPRING BOOT

## 📡 **ENDPOINTS REQUIS PAR FLUTTER**

### 1. **Types de congé**
```
GET /api/leave-types
```
**Réponse attendue :**
```json
[
  {
    "id": 1,
    "name": "Congé annuel",
    "description": "Congé payé annuel",
    "is_active": true
  },
  {
    "id": 2,
    "name": "Congé maladie", 
    "description": "Congé pour maladie",
    "is_active": true
  }
]
```

### 2. **Créer demande de congé**
```
POST /api/leave-requests
```
**Body requis :**
```json
{
  "requesterId": 15,
  "leaveTypeId": 1,
  "startDate": "2026-09-29",
  "endDate": "2026-10-04",
  "requestedDays": 4.0,
  "reason": "Demande de congé"
}
```

### 3. **Récupérer demandes utilisateur**
```
GET /api/leave-requests/requester/{userId}
```

## 🔧 **TESTS MANUELS À FAIRE**

1. **Test endpoint types** :
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     http://10.186.31.19:3000/api/leave-types
```

2. **Test création demande** :
```bash
curl -X POST \
     -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"requesterId":15,"leaveTypeId":1,"startDate":"2026-09-29","endDate":"2026-10-04","requestedDays":4.0}' \
     http://10.186.31.19:3000/api/leave-requests
```

## ✅ **VÉRIFICATIONS NÉCESSAIRES**

1. **Table `leave_types` existe** avec IDs 1, 2, 3, 4
2. **Controller Spring Boot** mappe bien `/api/leave-types`
3. **Méthode POST** accepte le format JSON Flutter
4. **Foreign key** entre `leave_requests.leaveTypeId` et `leave_types.id`

## 🚨 **SI ENDPOINTS DIFFÉRENTS**

Si votre Spring Boot utilise d'autres endpoints, modifiez dans Flutter :
- `lib/services/leave_service.dart` ligne ~20 : endpoint types
- `lib/services/leave_service.dart` ligne ~60 : endpoint création

## 🎯 **PROCHAINE ÉTAPE**

1. **Exécutez** le script `CORRECTION_URGENTE_LEAVE_TYPES.sql`
2. **Vérifiez** que les endpoints Spring Boot fonctionnent
3. **Recompilez** l'app Flutter : `flutter build apk --debug`
4. **Testez** une nouvelle demande de congé