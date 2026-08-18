import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  // Simuler une base de données d'utilisateurs
  final List<User> _users = [];

  Future<bool> login(String email, String password) async {
    try {
      // Simulation d'un délai de réseau
      await Future.delayed(const Duration(seconds: 1));
      
      // Vérifier les informations d'identification
      final user = _users.firstWhere(
        (u) => u.email == email && u.password == password,
        orElse: () => throw Exception('Invalid credentials'),
      );
      
      _currentUser = user;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(User user) async {
    try {
      // Simulation d'un délai de réseau
      await Future.delayed(const Duration(seconds: 1));
      
      // Vérifier si l'email existe déjà
      final existingUser = _users.where((u) => u.email == user.email);
      if (existingUser.isNotEmpty) {
        throw Exception('Email already exists');
      }
      
      // Ajouter l'utilisateur avec un ID généré
      final newUser = user.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
      _users.add(newUser);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      // Simulation d'un délai de réseau
      await Future.delayed(const Duration(seconds: 1));
      
      // Vérifier si l'email existe
      final existingUser = _users.where((u) => u.email == email);
      if (existingUser.isNotEmpty) {
        // En production, ici on enverrait un email de réinitialisation
        return true;
      } else {
        throw Exception('Email not found');
      }
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
  }

  bool get isLoggedIn => _currentUser != null;
}