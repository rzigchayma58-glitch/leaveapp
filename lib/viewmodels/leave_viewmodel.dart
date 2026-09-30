import 'package:flutter/material.dart';
import '../models/leave_request.dart';
import '../models/user.dart';
import '../services/leave_service.dart';
import '../services/auth_service.dart';
import '../services/api_config.dart';
import '../services/file_upload_service.dart';
import 'dart:io';

class LeaveViewModel extends ChangeNotifier {
  final LeaveService _leaveService = LeaveService();
  
  List<LeaveRequestResponse> _userRequests = [];
  List<LeaveBalanceResponse> _userBalances = [];
  List<LeaveRequestResponse> _teamRequests = [];
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _attachmentWarning;
  String? get attachmentWarning => _attachmentWarning;
  
  // Getters
  List<LeaveRequestResponse> get userRequests => _userRequests;
  List<LeaveBalanceResponse> get userBalances => _userBalances;
  List<LeaveRequestResponse> get teamRequests => _teamRequests;
  List<LeaveRequestResponse> get requests => _userRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Statistiques pour compatibilité UI
  Map<String, int> get statistics => _leaveService.getStatisticsFromRequests(_userRequests);
  int get availableBalance => _leaveService.getTotalAvailableBalance(_userBalances);

  // Initialisation - charger toutes les données utilisateur
  Future<void> initialize() async {
    final user = await AuthService.getStoredUser();
    if (user != null) {
      await Future.wait([
        loadUserRequests(user.id),
        loadUserBalances(user.id),
      ]);
      
      // Si manager, charger aussi les demandes d'équipe
      if (user.isManager) {
        await loadTeamRequests(user.id);
      }
    }
  }

  Future<void> loadUserData(dynamic userId) async {
    int parsedId = userId is int ? userId : (int.tryParse(userId.toString()) ?? 1);
    await loadUserRequests(parsedId);
    await loadUserBalances(parsedId);
  }

  // Charger les demandes de l'utilisateur
  Future<void> loadUserRequests(int userId) async {
    _setLoading(true);
    
    try {
      _userRequests = await _leaveService.getUserRequests(userId);
      _clearError();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  // Charger les soldes de l'utilisateur
  Future<void> loadUserBalances(int userId) async {
    try {
      _userBalances = await _leaveService.getUserBalance(userId);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
  }

  // Charger les demandes d'équipe (Manager)
  Future<void> loadTeamRequests(int managerId) async {
    try {
      _teamRequests = await _leaveService.getTeamRequests(managerId);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
  }

  // Créer une nouvelle demande - DIRECTEMENT MYSQL
  Future<bool> createLeaveRequest({
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    LeaveType requestType = LeaveType.leave,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    List<AttachedFile> attachments = const [],
  }) async {
    _setLoading(true);
    
    try {
      final user = await AuthService.getStoredUser();
      if (user == null) {
        _setError('Utilisateur non connecté');
        return false;
      }

      final advanceError = _leaveService.getAdvanceNoticeError(requestType, startDate);
      if (advanceError != null) {
        _setError(advanceError);
        return false;
      }

      print('📤 Création demande MySQL...');

      String? finalReason = reason;
      if (attachments.isNotEmpty) {
        final names = attachments.map((a) => a.name).join(', ');
        finalReason = [
          if (reason != null && reason.trim().isNotEmpty) reason.trim(),
          'Pieces jointes: $names',
        ].join(' | ');
      }
      
      final createdId = await _leaveService.createRequest(
        requesterId: user.id,
        leaveTypeId: leaveTypeId,
        startDate: startDate,
        endDate: endDate,
        reason: finalReason,
        isAbsence: requestType == LeaveType.absence,
        startTime: startTime,
        endTime: endTime,
      );

      if (createdId != null) {
        print('✅ Demande enregistrée dans MySQL !');
        _attachmentWarning = null;
        if (createdId > 0 && attachments.isNotEmpty) {
          var uploadedCount = 0;
          for (final attachment in attachments) {
            final file = File(attachment.path);
            if (!file.existsSync()) {
              print('⚠️ Fichier introuvable: ${attachment.path}');
              continue;
            }
            final uploaded = await FileUploadService.uploadMedicalDocument(
              createdId,
              file,
              filename: attachment.name,
            );
            if (uploaded) uploadedCount++;
            print(uploaded
                ? '✅ Pièce jointe enregistrée: ${attachment.name}'
                : '⚠️ Pièce jointe refusée par le serveur: ${attachment.name}');
          }
          if (uploadedCount < attachments.length) {
            _attachmentWarning =
                'Demande enregistrée. Le fichier n\'est pas dans medical_documents : le serveur refuse l\'upload pour un employé (403). Le nom du fichier est dans leave_requests.reason.';
          }
        }
        await loadUserRequests(user.id);
        await loadUserBalances(user.id);
        _clearError();
        return true;
      } else {
        _setError('Impossible de créer la demande');
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Approuver une demande (Manager)
  Future<bool> approveRequest(int requestId, String? comments) async {
    _setLoading(true);
    
    try {
      final success = await _leaveService.approveRequest(requestId, comments);
      
      if (success) {
        // Recharger les demandes d'équipe
        final user = await AuthService.getStoredUser();
        if (user != null) {
          await loadTeamRequests(user.id);
        }
        _clearError();
        return true;
      } else {
        _setError('Erreur lors de l\'approbation');
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refuser une demande (Manager)
  Future<bool> rejectRequest(int requestId, String comments, String? reason) async {
    _setLoading(true);
    
    try {
      final success = await _leaveService.rejectRequest(requestId, comments, reason);
      
      if (success) {
        // Recharger les demandes d'équipe
        final user = await AuthService.getStoredUser();
        if (user != null) {
          await loadTeamRequests(user.id);
        }
        _clearError();
        return true;
      } else {
        _setError('Erreur lors du refus');
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualiser toutes les données
  Future<void> refresh() async {
    final user = await AuthService.getStoredUser();
    if (user != null) {
      await initialize();
    }
  }

  // Filtrer les demandes par statut
  List<LeaveRequestResponse> getRequestsByStatus(LeaveRequestStatus status) {
    return _userRequests.where((request) => request.status == status).toList();
  }

  // Obtenir les demandes en attente pour l'équipe
  List<LeaveRequestResponse> getPendingTeamRequests() {
    return _teamRequests.where((request) => request.status == LeaveRequestStatus.pending).toList();
  }

  // Calculer les jours ouvrés entre deux dates
  int calculateWorkingDays(DateTime startDate, DateTime endDate) {
    return _leaveService.calculateWorkingDays(startDate, endDate);
  }

  // Validation d'une demande
  String? validateLeaveRequest({
    required DateTime startDate,
    required DateTime endDate,
    required LeaveNature leaveNature,
  }) {
    // Vérifier les dates
    if (startDate.isAfter(endDate)) {
      return 'La date de début doit être antérieure à la date de fin';
    }

    // Vérifier le délai de préavis
    final advanceError = _leaveService.getAdvanceNoticeError(LeaveType.leave, startDate);
    if (advanceError != null) {
      return advanceError;
    }

    // Vérifier le solde disponible
    final workingDays = calculateWorkingDays(startDate, endDate);
    if (workingDays > availableBalance) {
      return 'Solde de congés insuffisant ($workingDays jours demandés, $availableBalance disponibles)';
    }

    return null; // Demande valide
  }

  String? getAdvanceNoticeError(LeaveType type, DateTime? startDate) {
    return _leaveService.getAdvanceNoticeError(type, startDate);
  }

  String? getAbsenceDurationError(TimeOfDay? startTime, TimeOfDay? endTime) {
    return _leaveService.getAbsenceDurationError(startTime, endTime);
  }

  int getHoursUntilMinimum(LeaveType type, DateTime startDate) {
    return _leaveService.getHoursUntilMinimum(type, startDate);
  }

  int calculateAbsenceDurationMinutes(TimeOfDay startTime, TimeOfDay endTime) {
    return _leaveService.calculateAbsenceDurationMinutes(startTime, endTime);
  }

  Future<bool> submitRequest(LeaveRequest request) {
    return _leaveService.submitRequest(request);
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

  String _getErrorMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Erreur: $error';
  }
}