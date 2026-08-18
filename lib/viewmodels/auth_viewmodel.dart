import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _authService.currentUser;
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final success = await _authService.login(email, password);
      if (!success) {
        _setError('Email ou mot de passe incorrect');
      }
      return success;
    } catch (e) {
      _setError('Une erreur est survenue. Veuillez réessayer.');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> register(User user) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final success = await _authService.register(user);
      if (!success) {
        _setError('Impossible de créer le compte');
      }
      return success;
    } catch (e) {
      if (e.toString().contains('Email already exists')) {
        _setError('Cet email est déjà utilisé');
      } else {
        _setError('Une erreur est survenue. Veuillez réessayer.');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final success = await _authService.resetPassword(email);
      if (!success) {
        _setError('Impossible d\'envoyer le lien de réinitialisation');
      }
      return success;
    } catch (e) {
      if (e.toString().contains('Email not found')) {
        _setError('Aucun compte associé à cet email');
      } else {
        _setError('Une erreur est survenue. Veuillez réessayer.');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  void logout() {
    _authService.logout();
    notifyListeners();
  }
}