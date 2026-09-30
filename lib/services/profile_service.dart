// 📱 SERVICE DE GESTION DU PROFIL AVEC STOCKAGE LOCAL
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import 'auth_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  static const String _profileDataKey = 'user_profile_data';
  static const String _profilePhotoKey = 'user_profile_photo_path';

  Future<String> _dataKey() async {
    final user = await AuthService.getStoredUser();
    return '${_profileDataKey}_${user?.id ?? 0}';
  }

  Future<String> _photoKey() async {
    final user = await AuthService.getStoredUser();
    return '${_profilePhotoKey}_${user?.id ?? 0}';
  }

  // 📸 GESTION DE LA PHOTO DE PROFIL

  /// Changer la photo de profil (caméra ou galerie)
  Future<String?> changeProfilePhoto({bool fromCamera = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null) return null;

      // Sauvegarder l'image localement
      final savedPath = await _saveImageLocally(image);
      
      if (savedPath != null) {
        // Sauvegarder le chemin dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(await _photoKey(), savedPath);
        
        print('✅ Photo de profil sauvegardée: $savedPath');
        return savedPath;
      }

      return null;
    } catch (e) {
      print('❌ Erreur changement photo: $e');
      return null;
    }
  }

  /// Sauvegarder l'image dans le dossier local de l'app
  Future<String?> _saveImageLocally(XFile image) async {
    try {
      // Obtenir le répertoire local de l'app
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory profileDir = Directory('${appDir.path}/profile');
      
      // Créer le dossier s'il n'existe pas
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // Nom unique basé sur timestamp
      final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String localPath = '${profileDir.path}/$fileName';

      // Copier l'image
      final File localFile = await File(image.path).copy(localPath);
      
      return localFile.path;
    } catch (e) {
      print('❌ Erreur sauvegarde image: $e');
      return null;
    }
  }

  /// Récupérer le chemin de la photo de profil sauvegardée
  Future<String?> getProfilePhotoPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var photoPath = prefs.getString(await _photoKey());
      photoPath ??= prefs.getString(_profilePhotoKey);

      if (photoPath != null && await File(photoPath).exists()) {
        return photoPath;
      }

      return null;
    } catch (e) {
      print('❌ Erreur récupération photo: $e');
      return null;
    }
  }

  /// Supprimer la photo de profil
  Future<bool> removeProfilePhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var photoPath = prefs.getString(await _photoKey());
      photoPath ??= prefs.getString(_profilePhotoKey);

      if (photoPath != null) {
        final file = File(photoPath);
        if (await file.exists()) {
          await file.delete();
        }
        await prefs.remove(await _photoKey());
        await prefs.remove(_profilePhotoKey);
      }

      return true;
    } catch (e) {
      print('❌ Erreur suppression photo: $e');
      return false;
    }
  }

  // 👤 GESTION DES DONNÉES DE PROFIL

  /// Sauvegarder les modifications de profil localement
  Future<bool> updateProfileLocally({
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    DateTime? birthDate,
    String? email,
    String? position,
    String? department,
  }) async {
    try {
      // Récupérer le profil actuel
      final currentUser = await AuthService.getStoredUser();
      if (currentUser == null) return false;

      // Récupérer les données de profil existantes ou créer nouvelles
      final profileData = await getLocalProfileData() ?? <String, dynamic>{};

      // Mettre à jour avec les nouvelles données
      final updatedProfile = {
        'userId': currentUser.id,
        'firstName': firstName ?? currentUser.firstName,
        'lastName': lastName ?? currentUser.lastName,
        'email': email ?? currentUser.email,
        'phone': phone ?? profileData['phone'] ?? '',
        'address': address ?? profileData['address'] ?? '',
        'position': position ?? profileData['position'] ?? '',
        'department': department ?? profileData['department'] ?? '',
        'birthDate': birthDate?.toIso8601String() ?? profileData['birthDate'],
        'lastModified': DateTime.now().toIso8601String(),
        'syncedToBackend': false,
      };

      // Sauvegarder dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(await _dataKey(), jsonEncode(updatedProfile));

      final stored = await AuthService.getStoredUser();
      if (stored != null) {
        await AuthService.updateStoredUser(
          stored.copyWith(
            firstName: updatedProfile['firstName'] as String?,
            lastName: updatedProfile['lastName'] as String?,
            email: updatedProfile['email'] as String?,
            department: updatedProfile['department'] as String?,
            position: updatedProfile['position'] as String?,
            phone: updatedProfile['phone'] as String?,
            address: updatedProfile['address'] as String?,
            birthDate: birthDate ?? stored.birthDate,
          ),
        );
      }

      print('✅ Profil mis à jour (poste: $position, département: $department)');
      return true;

    } catch (e) {
      print('❌ Erreur mise à jour profil: $e');
      return false;
    }
  }

  /// Récupérer les données de profil locales
  Future<Map<String, dynamic>?> getLocalProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var profileJson = prefs.getString(await _dataKey());
      profileJson ??= prefs.getString(_profileDataKey);
      
      if (profileJson != null) {
        return jsonDecode(profileJson);
      }
      
      return null;
    } catch (e) {
      print('❌ Erreur récupération profil local: $e');
      return null;
    }
  }

  /// Récupérer le profil complet (données + photo)
  Future<LocalUserProfile?> getCompleteLocalProfile() async {
    try {
      final currentUser = await AuthService.getStoredUser();
      if (currentUser == null) return null;

      final profileData = await getLocalProfileData();
      final photoPath = await getProfilePhotoPath();

      return LocalUserProfile(
        id: currentUser.id,
        username: currentUser.username,
        email: profileData?['email'] ?? currentUser.email,
        firstName: profileData?['firstName'] ?? currentUser.firstName,
        lastName: profileData?['lastName'] ?? currentUser.lastName,
        role: currentUser.role,
        phone: profileData?['phone'] ?? currentUser.phone,
        address: profileData?['address'] ?? currentUser.address,
        position: profileData?['position'] ?? currentUser.position,
        department: profileData?['department'] ?? currentUser.department,
        birthDate: profileData?['birthDate'] != null
            ? DateTime.tryParse(profileData!['birthDate'].toString())
            : currentUser.birthDate,
        profilePhotoPath: photoPath,
        lastModified: profileData?['lastModified'] != null
            ? DateTime.parse(profileData!['lastModified'])
            : null,
        hasLocalChanges: profileData?['syncedToBackend'] != true,
      );

    } catch (e) {
      print('❌ Erreur récupération profil complet: $e');
      return null;
    }
  }

  // 🔄 SYNCHRONISATION FUTURE AVEC LE BACKEND

  /// Marquer les données comme synchronisées
  Future<void> markAsSynced() async {
    try {
      final profileData = await getLocalProfileData();
      if (profileData != null) {
        profileData['syncedToBackend'] = true;
        profileData['lastSynced'] = DateTime.now().toIso8601String();
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(await _dataKey(), jsonEncode(profileData));
      }
    } catch (e) {
      print('❌ Erreur marquage sync: $e');
    }
  }

  /// Vérifier s'il y a des modifications non synchronisées
  Future<bool> hasUnsyncedChanges() async {
    final profileData = await getLocalProfileData();
    return profileData?['syncedToBackend'] != true;
  }

  /// Nettoyer les données locales
  Future<void> clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(await _dataKey());
      await removeProfilePhoto();
      
      print('✅ Données locales nettoyées');
    } catch (e) {
      print('❌ Erreur nettoyage: $e');
    }
  }
}

// 📋 MODÈLE POUR LE PROFIL LOCAL ÉTENDU
class LocalUserProfile {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? phone;
  final String? address;
  final String? position;
  final String? department;
  final DateTime? birthDate;
  final String? profilePhotoPath;
  final DateTime? lastModified;
  final bool hasLocalChanges;

  LocalUserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phone,
    this.address,
    this.position,
    this.department,
    this.birthDate,
    this.profilePhotoPath,
    this.lastModified,
    this.hasLocalChanges = false,
  });

  String get fullName => '$firstName $lastName';
  
  bool get hasProfilePhoto => profilePhotoPath != null;
  
  File? get profilePhotoFile => profilePhotoPath != null 
      ? File(profilePhotoPath!) 
      : null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toString(),
      'phone': phone,
      'address': address,
      'position': position,
      'department': department,
      'birthDate': birthDate?.toIso8601String(),
      'profilePhotoPath': profilePhotoPath,
      'lastModified': lastModified?.toIso8601String(),
      'hasLocalChanges': hasLocalChanges,
    };
  }
}