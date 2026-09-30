// 📱 VIEWMODEL POUR LA GESTION DU PROFIL AVEC SAUVEGARDE LOCALE
import 'package:flutter/material.dart';
import '../../services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  LocalUserProfile? _localProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  LocalUserProfile? get localProfile => _localProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUnsyncedChanges => _localProfile?.hasLocalChanges ?? false;

  // Initialisation
  Future<void> initialize() async {
    await loadLocalProfile();
  }

  // Charger le profil local complet
  Future<void> loadLocalProfile() async {
    _setLoading(true);
    
    try {
      _localProfile = await _profileService.getCompleteLocalProfile();
      _clearError();
    } catch (e) {
      _setError('Erreur de chargement du profil: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Changer la photo de profil
  Future<bool> changeProfilePhoto({bool fromCamera = false}) async {
    _setLoading(true);
    
    try {
      final photoPath = await _profileService.changeProfilePhoto(
        fromCamera: fromCamera,
      );
      
      if (photoPath != null) {
        // Recharger le profil pour mettre à jour l'affichage
        await loadLocalProfile();
        _clearError();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Erreur lors du changement de photo: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Supprimer la photo de profil
  Future<bool> removeProfilePhoto() async {
    _setLoading(true);
    
    try {
      final success = await _profileService.removeProfilePhoto();
      
      if (success) {
        await loadLocalProfile();
        _clearError();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Erreur lors de la suppression de photo: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mettre à jour les informations du profil
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    DateTime? birthDate,
    String? email,
    String? position,
    String? department,
  }) async {
    _setLoading(true);
    
    try {
      final success = await _profileService.updateProfileLocally(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
        birthDate: birthDate,
        email: email,
        position: position,
        department: department,
      );

      if (success) {
        // Recharger le profil mis à jour
        await loadLocalProfile();
        _clearError();
        return true;
      } else {
        _setError('Erreur lors de la mise à jour du profil');
        return false;
      }
    } catch (e) {
      _setError('Erreur de mise à jour: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Méthode combinée pour sauvegarder toutes les modifications
  Future<bool> saveAllChanges({
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    DateTime? birthDate,
    String? email,
    String? position,
    String? department,
  }) async {
    return await updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      address: address,
      birthDate: birthDate,
      email: email,
      position: position,
      department: department,
    );
  }

  // Afficher les options de changement de photo
  Future<void> showPhotoOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Changer la photo',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.orange),
              title: const Text('Prendre une photo'),
              onTap: () async {
                Navigator.pop(context);
                await changeProfilePhoto(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.orange),
              title: const Text('Choisir depuis la galerie'),
              onTap: () async {
                Navigator.pop(context);
                await changeProfilePhoto(fromCamera: false);
              },
            ),
            if (_localProfile?.hasProfilePhoto == true)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer la photo'),
                onTap: () async {
                  Navigator.pop(context);
                  await removeProfilePhoto();
                },
              ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // Validation des champs
  String? validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return null;
    
    // Validation basique du numéro de téléphone
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
    if (!phoneRegex.hasMatch(phone.trim())) {
      return 'Format de téléphone invalide';
    }
    
    return null;
  }

  String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) return 'Email requis';
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Format email invalide';
    }
    
    return null;
  }

  String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) return 'Champ requis';
    if (name.trim().length < 2) return 'Minimum 2 caractères';
    
    return null;
  }

  // Synchroniser avec le backend (futur)
  Future<void> syncWithBackend() async {
    if (!hasUnsyncedChanges) return;
    
    print('🔄 Synchronisation avec backend en attente...');
    // TODO: Implémenter la synchronisation avec le backend
    
    // Pour l'instant, marquer comme synchronisé localement
    await _profileService.markAsSynced();
    await loadLocalProfile();
  }

  // Helpers privés
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Nettoyage
  @override
  void dispose() {
    super.dispose();
  }
}