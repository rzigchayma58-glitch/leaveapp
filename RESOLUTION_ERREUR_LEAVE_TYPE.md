# 🔧 RÉSOLUTION ERREUR "Leave type not found with id: 1"

## 🚨 **PROBLÈME IDENTIFIÉ**

```
I/flutter (24038): ❌ Erreur serveur: 404
I/flutter (24038): 📡 Création Response: {"error":"Not Found","message":"Leave type not found with id: 1"...}
```

**CAUSE**: Ta base de données MySQL `rh_xtensus` n'a pas de types de congé avec l'ID 1.

## ✅ **SOLUTION RAPIDE (2 MINUTES)**

### 1️⃣ **Exécuter le Script SQL**

Ouvre ton client MySQL (phpMyAdmin, MySQL Workbench, ou ligne de commande) et exécute :

```sql
USE rh_xtensus;

INSERT INTO conge_types (id, nom, description, jours_max_par_an, necessite_justificatif, delai_minimum_heures, actif, created_at, updated_at) 
VALUES 
    (1, 'Congé annuel', 'Congés payés annuels', 30, FALSE, 72, TRUE, NOW(), NOW()),
    (2, 'Autorisation d\'absence', 'Autorisation d\'absence ponctuelle', 0, FALSE, 48, TRUE, NOW(), NOW()),
    (3, 'Congé maladie', 'Congé pour maladie', 365, TRUE, 0, TRUE, NOW(), NOW())
ON DUPLICATE KEY UPDATE nom = VALUES(nom), updated_at = NOW();
```

### 2️⃣ **Vérifier l'Insertion**

```sql
SELECT * FROM conge_types WHERE actif = TRUE;
```

**Résultat attendu** :
```
| id | nom                    | description                      | actif |
|----|------------------------|----------------------------------|-------|
| 1  | Congé annuel          | Congés payés annuels             | 1     |
| 2  | Autorisation d'absence | Autorisation d'absence ponctuelle| 1     |
| 3  | Congé maladie         | Congé pour maladie               | 1     |
```

### 3️⃣ **Relancer l'App Flutter**

1. **Recompiler** : `flutter build apk --debug`
2. **Installer** sur ton OnePlus CPH2727
3. **Tester** une nouvelle demande de congé

## 🎯 **MAPPING FLUTTER ↔ MYSQL**

| Flutter UI              | MySQL ID | Nom                    |
|-------------------------|----------|------------------------|
| Dropdown "Congé annuel" | 1        | Congé annuel          |
| Autorisation d'absence  | 2        | Autorisation d'absence |
| Dropdown "Congé maladie"| 3        | Congé maladie         |

## 📊 **VÉRIFICATION RAPIDE**

Si tu veux vérifier quels types existent dans ta base :

```sql
-- Voir tous les types
SELECT id, nom, actif FROM conge_types;

-- Voir seulement les actifs
SELECT id, nom FROM conge_types WHERE actif = TRUE;
```

## 🔄 **FLUX FONCTIONNEL APRÈS CORRECTION**

1. **Login** : `aa.bb@xtensus.com` / `123456` ✅
2. **Types chargés** : Depuis `GET /api/conge-types/actifs` ✅ 
3. **Dropdown populated** : Avec vrais types MySQL ✅
4. **Nouvelle demande** : `POST /api/leave-requests` avec bon ID ✅
5. **Sauvegarde MySQL** : Dans table `leave_requests` ✅

## 🎉 **RÉSULTAT ATTENDU**

Au lieu de :
```
❌ Leave type not found with id: 1
```

Tu auras :
```
✅ Demande enregistrée dans MySQL !
```

## ⚡ **SI PROBLÈME PERSISTE**

1. **Vérifie la table** : `DESC conge_types;`
2. **Check les IDs** : `SELECT id FROM conge_types WHERE actif = TRUE;`
3. **Teste l'endpoint** : `GET http://10.186.31.19:3000/api/conge-types/actifs`

---

**🎯 TL;DR: Exécute le script SQL → Relance Flutter → Ça marche !**