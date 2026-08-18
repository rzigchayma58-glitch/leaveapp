import 'package:flutter/material.dart';
import '../models/leave_request.dart';
import '../services/leave_service.dart';
import '../services/local_notification_service.dart';

class LeaveViewModel extends ChangeNotifier {
  final LeaveService _leaveService = LeaveService();
  LocalNotificationService? _notificationService;
  
  bool _isLoading = false;
  String? _errorMessage;
  List<LeaveRequest> _requests = [];
  Map<String, int> _statistics = {};
  int _availableBalance = 0;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<LeaveRequest> get requests => _requests;
  Map<String, int> get statistics => _statistics;
  int get availableBalance => _availableBalance;
  
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
  
  void setNotificationService(LocalNotificationService service) {
    _notificationService = service;
  }
  
  void loadUserData(String userId) {
    _requests = _leaveService.getRequestsForUser(userId);
    _statistics = _leaveService.getStatisticsForUser(userId);
    _availableBalance = _leaveService.getAvailableBalance(userId);
    notifyListeners();
  }
  
  Future<bool> submitRequest(LeaveRequest request) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final success = await _leaveService.submitRequest(request);
      if (success) {
        // Recharger les données après soumission
        loadUserData(request.userId);
        
        // Notification de confirmation de soumission
        await _notificationService?.notifyNewDecision(
          userId: request.userId,
          title: 'Demande soumise',
          message: 'Votre demande de ${_getLeaveTypeName(request.type)} a été soumise avec succès et est en attente d\'approbation.',
        );
        
      } else {
        _setError('Impossible d\'envoyer la demande');
      }
      return success;
    } catch (e) {
      _setError('Une erreur est survenue. Veuillez réessayer.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _getLeaveTypeName(LeaveType type) {
    switch (type) {
      case LeaveType.leave:
        return 'congé';
      case LeaveType.absence:
        return 'autorisation d\'absence';
    }
  }
  
  int calculateWorkingDays(DateTime startDate, DateTime endDate) {
    return _leaveService.calculateWorkingDays(startDate, endDate);
  }

  /// Valide le délai de préavis pour une demande
  bool isValidAdvanceNotice(LeaveType type, DateTime requestDate) {
    return _leaveService.isValidAdvanceNotice(type, requestDate);
  }

  /// Retourne le message d'erreur pour le délai de préavis
  String? getAdvanceNoticeError(LeaveType type, DateTime? requestDate) {
    return _leaveService.getAdvanceNoticeError(type, requestDate);
  }

  /// Calcule les heures restantes avant le délai minimum
  int getHoursUntilMinimum(LeaveType type, DateTime requestDate) {
    return _leaveService.getHoursUntilMinimum(type, requestDate);
  }

  /// Valide la durée d'une autorisation d'absence (max 2h)
  bool isValidAbsenceDuration(TimeOfDay startTime, TimeOfDay endTime) {
    return _leaveService.isValidAbsenceDuration(startTime, endTime);
  }

  /// Valide si l'heure de fin est après l'heure de début
  bool isValidTimeRange(TimeOfDay startTime, TimeOfDay endTime) {
    return _leaveService.isValidTimeRange(startTime, endTime);
  }

  /// Calcule la durée en minutes d'une autorisation d'absence
  int calculateAbsenceDurationMinutes(TimeOfDay startTime, TimeOfDay endTime) {
    return _leaveService.calculateAbsenceDurationMinutes(startTime, endTime);
  }

  /// Retourne le message d'erreur pour la durée d'absence
  String? getAbsenceDurationError(TimeOfDay? startTime, TimeOfDay? endTime) {
    return _leaveService.getAbsenceDurationError(startTime, endTime);
  }
}