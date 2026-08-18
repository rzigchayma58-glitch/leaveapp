import 'package:flutter/material.dart';
import '../models/leave_request.dart';
import '../models/user.dart';
import '../services/manager_service.dart';
import '../services/local_notification_service.dart';

class ManagerViewModel extends ChangeNotifier {
  final ManagerService _managerService = ManagerService();
  LocalNotificationService? _notificationService;

  List<LeaveRequest> _pendingRequests = [];
  Map<String, User> _employeeCache = {};
  Map<String, int> _statistics = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<LeaveRequest> get pendingRequests => _pendingRequests;
  Map<String, int> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setNotificationService(LocalNotificationService service) {
    _notificationService = service;
  }

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

  // Initialiser les données
  void initialize() {
    _managerService.initializeTestData();
    loadPendingRequests();
    loadStatistics();
  }

  // Charger les demandes en attente
  void loadPendingRequests() {
    _setLoading(true);
    _setError(null);

    try {
      _pendingRequests = _managerService.getPendingRequests();
      
      // Pré-charger les informations des employés
      for (final request in _pendingRequests) {
        final employee = _managerService.getEmployeeInfo(request.userId);
        if (employee != null) {
          _employeeCache[request.userId] = employee;
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des demandes');
    } finally {
      _setLoading(false);
    }
  }

  // Charger les statistiques
  void loadStatistics() {
    _statistics = _managerService.getManagerStatistics();
    notifyListeners();
  }

  // Obtenir les informations d'un employé
  User? getEmployeeInfo(String userId) {
    if (_employeeCache.containsKey(userId)) {
      return _employeeCache[userId];
    }
    
    final employee = _managerService.getEmployeeInfo(userId);
    if (employee != null) {
      _employeeCache[userId] = employee;
    }
    return employee;
  }

  // Approuver une demande
  Future<bool> approveRequest({
    required String requestId,
    required String managerId,
    String? comment,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _managerService.approveRequest(
        requestId: requestId,
        managerId: managerId,
        managerComment: comment,
      );

      if (success) {
        // Trouver la demande pour obtenir l'ID utilisateur
        final request = _pendingRequests.firstWhere((req) => req.id == requestId);
        final employee = getEmployeeInfo(request.userId);
        
        // Envoyer une notification à l'employé
        if (_notificationService != null && employee != null) {
          await _notificationService!.notifyRequestApproved(
            userId: request.userId,
            requestType: request.displayTitle,
            dates: request.displayPeriod,
          );
        }

        // Recharger les données
        loadPendingRequests();
        loadStatistics();
      } else {
        _setError('Impossible d\'approuver la demande');
      }

      return success;
    } catch (e) {
      _setError('Erreur lors de l\'approbation');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refuser une demande
  Future<bool> rejectRequest({
    required String requestId,
    required String managerId,
    String? comment,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _managerService.rejectRequest(
        requestId: requestId,
        managerId: managerId,
        managerComment: comment,
      );

      if (success) {
        // Trouver la demande pour obtenir l'ID utilisateur
        final request = _pendingRequests.firstWhere((req) => req.id == requestId);
        final employee = getEmployeeInfo(request.userId);
        
        // Envoyer une notification à l'employé
        if (_notificationService != null && employee != null) {
          await _notificationService!.notifyRequestRejected(
            userId: request.userId,
            requestType: request.displayTitle,
            dates: request.displayPeriod,
            reason: comment,
          );
        }

        // Recharger les données
        loadPendingRequests();
        loadStatistics();
      } else {
        _setError('Impossible de refuser la demande');
      }

      return success;
    } catch (e) {
      _setError('Erreur lors du refus');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Obtenir une demande spécifique
  LeaveRequest? getRequest(String requestId) {
    return _managerService.getRequest(requestId);
  }
}