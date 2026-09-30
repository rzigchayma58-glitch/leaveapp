import 'package:flutter/material.dart';
import '../models/leave_request.dart';
import '../models/user.dart';
import '../services/leave_service.dart';
import '../services/auth_service.dart';
import '../services/api_config.dart';
import '../services/local_notification_service.dart';

class ManagerViewModel extends ChangeNotifier {
  final LeaveService _leaveService = LeaveService();
  LocalNotificationService? _notificationService;

  List<LeaveRequestResponse> _allRequests = [];
  List<LeaveRequest> _pendingRequests = [];
  final Map<String, UserProfile> _employeeCache = {};
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

  Future<void> initialize() async {
    await loadPendingRequests();
  }

  Future<void> loadPendingRequests() async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await AuthService.getStoredUser();
      if (user == null) {
        _setError('Utilisateur non connecté');
        _pendingRequests = [];
        return;
      }

      _allRequests = await _leaveService.getTeamRequests(user.id);
      _employeeCache.clear();
      for (final request in _allRequests) {
        _employeeCache[request.requester.id.toString()] = request.toEmployeeProfile();
      }

      // Toutes les demandes en attente visibles par un responsable
      // (assignées ou non). On exclut seulement ses propres demandes.
      final inbox = _allRequests
          .where((r) => r.requester.id != user.id)
          .toList();

      _pendingRequests = inbox
          .where((r) => r.status == LeaveRequestStatus.pending)
          .map((r) => r.toUiRequest())
          .toList();

      _statistics = {
        'pending': inbox.where((r) => r.status == LeaveRequestStatus.pending).length,
        'approved': inbox.where((r) => r.status == LeaveRequestStatus.approved).length,
        'rejected': inbox.where((r) => r.status == LeaveRequestStatus.rejected).length,
        'total': inbox.length,
      };
      print('👔 Manager ${user.id}: ${_pendingRequests.length} demandes en attente / ${inbox.length} au total');
      notifyListeners();
    } catch (e) {
      _setError(e is ApiException ? e.message : 'Erreur lors du chargement des demandes');
    } finally {
      _setLoading(false);
    }
  }

  void loadStatistics() {
    notifyListeners();
  }

  UserProfile? getEmployeeInfo(String userId) {
    return _employeeCache[userId];
  }

  Future<bool> approveRequest({
    required String requestId,
    required String managerId,
    String? comment,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final id = int.tryParse(requestId);
      var approverId = int.tryParse(managerId);
      approverId ??= (await AuthService.getStoredUser())?.id;
      if (id == null) {
        _setError('Demande invalide');
        return false;
      }
      if (approverId == null) {
        _setError('Responsable non identifié');
        return false;
      }

      LeaveRequest? request;
      for (final item in _pendingRequests) {
        if (item.id == requestId) {
          request = item;
          break;
        }
      }

      final success = await _applyDecision(
        requestId: id,
        approve: true,
        comment: comment,
        approverId: approverId,
      );

      if (success) {
        if (_notificationService != null && request != null) {
          await _notificationService!.notifyRequestApproved(
            userId: request.userId,
            requestType: request.displayTitle,
            dates: request.displayPeriod,
          );
        }
        await loadPendingRequests();
      }
      return success;
    } catch (e) {
      _setError(_humanizeDecisionError(e, approving: true));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rejectRequest({
    required String requestId,
    required String managerId,
    String? comment,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final id = int.tryParse(requestId);
      var approverId = int.tryParse(managerId);
      approverId ??= (await AuthService.getStoredUser())?.id;
      if (id == null) {
        _setError('Demande invalide');
        return false;
      }
      if (approverId == null) {
        _setError('Responsable non identifié');
        return false;
      }

      LeaveRequest? request;
      for (final item in _pendingRequests) {
        if (item.id == requestId) {
          request = item;
          break;
        }
      }

      final success = await _applyDecision(
        requestId: id,
        approve: false,
        comment: comment ?? 'Refusé',
        approverId: approverId,
      );

      if (success) {
        if (_notificationService != null && request != null) {
          await _notificationService!.notifyRequestRejected(
            userId: request.userId,
            requestType: request.displayTitle,
            dates: request.displayPeriod,
            reason: comment,
          );
        }
        await loadPendingRequests();
      }
      return success;
    } catch (e) {
      _setError(_humanizeDecisionError(e, approving: false));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  LeaveRequest? getRequest(String requestId) {
    try {
      return _pendingRequests.firstWhere((req) => req.id == requestId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _applyDecision({
    required int requestId,
    required bool approve,
    required int? approverId,
    String? comment,
  }) async {
    try {
      return approve
          ? await _leaveService.approveRequest(requestId, comment, approverId: approverId)
          : await _leaveService.rejectRequest(
              requestId,
              comment ?? 'Refusé',
              'OTHER',
              approverId: approverId,
            );
    } catch (e) {
      final raw = (e is ApiException ? e.message : e.toString()).toLowerCase();
      final canTakeOver = raw.contains('no assigned approver') ||
          raw.contains('assigned approver');
      if (!canTakeOver) rethrow;

      LeaveRequestResponse? original;
      for (final item in _allRequests) {
        if (item.id == requestId) {
          original = item;
          break;
        }
      }
      if (original == null) rethrow;

      print('🔄 Reprise de la demande $requestId par le responsable connecté...');
      final newId = await _leaveService.createRequest(
        requesterId: original.requester.id,
        leaveTypeId: original.leaveType.id,
        startDate: DateTime.parse(original.startDate),
        endDate: DateTime.parse(original.endDate),
        reason: original.reason,
      );
      if (newId == null || newId <= 0) rethrow;

      final decided = approve
          ? await _leaveService.approveRequest(newId, comment, approverId: approverId)
          : await _leaveService.rejectRequest(
              newId,
              comment ?? 'Refusé',
              'OTHER',
              approverId: approverId,
            );
      if (decided) {
        try {
          await _leaveService.deleteRequest(requestId);
        } catch (deleteError) {
          print('⚠️ Ancienne demande $requestId non supprimée: $deleteError');
        }
      }
      return decided;
    }
  }

  String _humanizeDecisionError(dynamic error, {required bool approving}) {
    final raw = error is ApiException ? error.message : error.toString();
    final lower = raw.toLowerCase();
    if (lower.contains('leave balance not found')) {
      return 'Impossible d\'approuver : solde de congé manquant dans MySQL (leave_balances).';
    }
    if (lower.contains('no assigned approver') || lower.contains('assigned approver')) {
      return 'La demande n\'a pas pu être rattachée à votre compte. Réessayez.';
    }
    return raw;
  }
}
