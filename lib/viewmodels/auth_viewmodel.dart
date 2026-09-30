import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/api_config.dart';
import '../services/notification_service.dart';
import '../services/profile_service.dart';

class AuthViewModel extends ChangeNotifier {
  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;

  // Getters
  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;

  // Initialisation - vérifier si déjà connecté
  Future<void> initialize() async {
    _setLoading(true);
    
    try {
      final isAuthenticated = await AuthService.isLoggedIn();
      if (isAuthenticated) {
        final stored = await AuthService.getStoredUser();
        if (stored != null) {
          var user = stored;
          try {
            final remote = await AuthService.getCurrentUser();
            if (remote != null) {
              user = user.copyWith(
                firstName: remote.firstName,
                lastName: remote.lastName,
                email: remote.email,
                department: remote.department ?? user.department,
                position: remote.position ?? user.position,
                role: remote.role,
              );
            }
          } catch (_) {}

          final local = await ProfileService().getCompleteLocalProfile();
          if (local != null) {
            user = user.copyWith(
              firstName: local.firstName,
              lastName: local.lastName,
              department: local.department ?? user.department,
              position: local.position ?? user.position,
              phone: local.phone,
              address: local.address,
              birthDate: local.birthDate,
            );
          }

          await AuthService.updateStoredUser(user);
          _currentUser = user;
          _isLoggedIn = true;
          await NotificationService.showWelcome(firstName: user.firstName);
        }
      }
    } catch (e) {
      _setError('Erreur d\'initialisation: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Connexion
  Future<bool> login(String emailOrUsername, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final loginResponse = await AuthService.login(emailOrUsername, password);
      
      if (loginResponse != null) {
        _currentUser = loginResponse.user;
        final local = await ProfileService().getCompleteLocalProfile();
        if (local != null) {
          _currentUser = _currentUser!.copyWith(
            firstName: local.firstName,
            lastName: local.lastName,
            department: local.department ?? _currentUser!.department,
            position: local.position ?? _currentUser!.position,
            phone: local.phone,
            address: local.address,
            birthDate: local.birthDate,
          );
          await AuthService.updateStoredUser(_currentUser!);
        }
        _isLoggedIn = true;
        await NotificationService.showWelcome(
          firstName: _currentUser!.firstName,
        );
        _setLoading(false);
        return true;
      } else {
        _setError('Email ou mot de passe incorrect');
        return false;
      }
    } catch (e) {
      _setError(e is ApiException ? e.message : 'Erreur de connexion: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Inscription - VERSION CORRIGÉE POUR VOTRE BACKEND
  Future<bool> register({
    required String firstName,   // prénom (aa)
    required String lastName,    // nom (bb)
    required String email,       // aa.bb@xtensus.com
    required String password,    // mot de passe
    required String role,        // "Employé" ou "Responsable"
    String? matricule,           // 77 (optionnel)
    String? department,          // it (optionnel)
    String? username,            // pour compatibilité (ignoré)
    String? managerEmail,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔍 AuthViewModel: Tentative inscription pour $email (rôle: $role)');
      
      final result = await AuthService.register(
        nom: lastName,
        prenom: firstName,
        email: email,
        matricule: matricule ?? '',
        departement: department ?? '',
        role: role,
        password: password,
        managerEmail: managerEmail,
      );

      if (result['success'] == true) {
        print('✅ AuthViewModel: Inscription réussie, rôle backend=${result['role']}');

        // Persister le JWT + le rôle (MANAGER / EMPLOYEE) comme un vrai login
        final loginResponse = await AuthService.login(email, password);
        if (loginResponse != null) {
          _currentUser = loginResponse.user;
          _isLoggedIn = true;
        } else if (result['token'] != null && result['user'] is Map) {
          await AuthService.persistSession(
            token: result['token'].toString(),
            user: Map<String, dynamic>.from(result['user'] as Map),
          );
          _currentUser = UserProfile.fromBackendJson(
            Map<String, dynamic>.from(result['user'] as Map),
          );
          _isLoggedIn = true;
        }

        print('👤 Session: ${_currentUser?.email} / ${_currentUser?.displayRole} / manager=${_currentUser?.isManager}');
        await NotificationService.showWelcome(
          firstName: _currentUser?.firstName,
        );
        _setLoading(false);
        return true;
      } else {
        _setError(result['error'] ?? 'Erreur lors de la création du compte');
        return false;
      }
    } catch (e) {
      print('❌ AuthViewModel: Erreur inscription: $e');
      _setError('Erreur d\'inscription: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _setLoading(true);

    try {
      await AuthService.logout();
      _currentUser = null;
      _isLoggedIn = false;
      NotificationService.resetWelcome();
      _clearError();
    } catch (e) {
      _setError('Erreur de déconnexion: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await AuthService.forgotPassword(email);
      if (result['success'] == true) {
        _setLoading(false);
        return true;
      }
      _setError(result['error'] ?? 'Impossible d\'envoyer le lien');
      return false;
    } catch (e) {
      _setError(e is ApiException ? e.message : 'Erreur: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await AuthService.forgotPassword(email);
      if (result['success'] != true) {
        _setError(result['error'] ?? 'Impossible d\'envoyer le lien');
      }
      return result;
    } catch (e) {
      final message = e is ApiException ? e.message : 'Erreur: $e';
      _setError(message);
      return {'success': false, 'error': message};
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> confirmPasswordReset({
    required String email,
    required String newPassword,
    String? token,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await AuthService.confirmResetPassword(
        email: email,
        newPassword: newPassword,
        token: token,
      );
      if (result['success'] == true) return true;
      _setError(result['error'] ?? 'Réinitialisation impossible');
      return false;
    } catch (e) {
      _setError(e is ApiException ? e.message : 'Erreur: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualiser les informations utilisateur
  Future<void> refreshUser() async {
    try {
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      } else {
        // Token expiré, déconnecter
        await logout();
      }
    } catch (e) {
      _setError('Erreur de mise à jour du profil: $e');
    }
  }

  // Mise à jour du profil utilisateur
  void updateUserProfile(UserProfile updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
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

  // Validation des champs
  String? validateEmail(String email) {
    if (email.isEmpty) return 'Email requis';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Format email invalide';
    }
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'Mot de passe requis';
    if (password.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  String? validateName(String name) {
    if (name.isEmpty) return 'Champ requis';
    if (name.length < 2) return 'Minimum 2 caractères';
    return null;
  }

  String? validateUsername(String username) {
    if (username.isEmpty) return 'Nom d\'utilisateur requis';
    if (username.length < 3) return 'Minimum 3 caractères';
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(username)) {
      return 'Caractères autorisés: lettres, chiffres, ., _, -';
    }
    return null;
  }
}