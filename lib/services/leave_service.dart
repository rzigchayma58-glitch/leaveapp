import 'package:flutter/material.dart';
import '../models/leave_request.dart';

class LeaveService {
  static final LeaveService _instance = LeaveService._internal();
  factory LeaveService() => _instance;
  LeaveService._internal();

  final List<LeaveRequest> _requests = [
    // Données d'exemple
    LeaveRequest(
      id: '1',
      userId: 'user1',
      type: LeaveType.leave,
      nature: LeaveNature.annual,
      startDate: DateTime(2026, 8, 12),
      endDate: DateTime(2026, 8, 16),
      workingDays: 5,
      status: RequestStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    LeaveRequest(
      id: '2',
      userId: 'user1',
      type: LeaveType.leave,
      nature: LeaveNature.sick,
      startDate: DateTime(2026, 6, 2),
      endDate: DateTime(2026, 6, 3),
      workingDays: 2,
      status: RequestStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    LeaveRequest(
      id: '3',
      userId: 'user1',
      type: LeaveType.leave,
      nature: LeaveNature.other,
      startDate: DateTime(2026, 4, 15),
      endDate: DateTime(2026, 4, 15),
      workingDays: 1,
      status: RequestStatus.rejected,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  List<LeaveRequest> getRequestsForUser(String userId) {
    return _requests.where((request) => request.userId == userId).toList();
  }

  Future<bool> submitRequest(LeaveRequest request) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final newRequest = request.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
      );
      
      _requests.add(newRequest);
      return true;
    } catch (e) {
      return false;
    }
  }

  Map<String, int> getStatisticsForUser(String userId) {
    final userRequests = getRequestsForUser(userId);
    
    return {
      'pending': userRequests.where((r) => r.status == RequestStatus.pending).length,
      'approved': userRequests.where((r) => r.status == RequestStatus.approved).length,
      'rejected': userRequests.where((r) => r.status == RequestStatus.rejected).length,
    };
  }

  int getAvailableBalance(String userId) {
    // Simulation du calcul du solde
    final approvedDays = _requests
        .where((r) => r.userId == userId && r.status == RequestStatus.approved)
        .fold<int>(0, (total, request) => total + (request.workingDays ?? 0));
    
    return 25 - approvedDays; // 25 jours par an moins les jours déjà pris
  }

  int calculateWorkingDays(DateTime startDate, DateTime endDate) {
    int workingDays = 0;
    DateTime current = startDate;
    
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      // Exclure les weekends (samedi = 6, dimanche = 7)
      if (current.weekday < 6) {
        workingDays++;
      }
      current = current.add(const Duration(days: 1));
    }
    
    return workingDays;
  }

  /// Valide si une demande respecte le délai de préavis requis
  bool isValidAdvanceNotice(LeaveType type, DateTime requestDate) {
    final now = DateTime.now();
    final difference = requestDate.difference(now);
    
    switch (type) {
      case LeaveType.absence:
        // Minimum 48 heures pour autorisation d'absence
        return difference.inHours >= 48;
      case LeaveType.leave:
        // Minimum 72 heures pour congé
        return difference.inHours >= 72;
    }
  }

  /// Retourne le message d'erreur approprié pour le délai de préavis
  String? getAdvanceNoticeError(LeaveType type, DateTime? requestDate) {
    if (requestDate == null) return null;
    
    if (!isValidAdvanceNotice(type, requestDate)) {
      switch (type) {
        case LeaveType.absence:
          return 'Les autorisations d\'absence doivent être demandées au minimum 48 heures à l\'avance';
        case LeaveType.leave:
          return 'Les congés doivent être demandés au minimum 72 heures à l\'avance';
      }
    }
    return null;
  }

  /// Calcule les heures restantes avant le délai minimum
  int getHoursUntilMinimum(LeaveType type, DateTime requestDate) {
    final now = DateTime.now();
    final difference = requestDate.difference(now);
    final minHours = type == LeaveType.absence ? 48 : 72;
    
    return minHours - difference.inHours;
  }

  /// Valide la durée d'une autorisation d'absence (max 2h)
  bool isValidAbsenceDuration(TimeOfDay startTime, TimeOfDay endTime) {
    // Convertir en minutes pour calcul plus précis
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    
    // Gérer le cas où l'heure de fin est le lendemain (très rare mais possible)
    int duration;
    if (endMinutes >= startMinutes) {
      duration = endMinutes - startMinutes;
    } else {
      // Cas où on traverse minuit (ex: 23:00 → 01:00)
      duration = (24 * 60) - startMinutes + endMinutes;
    }
    
    // Maximum 2 heures = 120 minutes
    return duration <= 120 && duration > 0;
  }

  /// Calcule la durée en minutes d'une autorisation d'absence
  int calculateAbsenceDurationMinutes(TimeOfDay startTime, TimeOfDay endTime) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    
    if (endMinutes >= startMinutes) {
      return endMinutes - startMinutes;
    } else {
      // Cas où on traverse minuit
      return (24 * 60) - startMinutes + endMinutes;
    }
  }

  /// Valide si l'heure de fin est après l'heure de début
  bool isValidTimeRange(TimeOfDay startTime, TimeOfDay endTime) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    
    // Pour simplifier, on évite les cas qui traversent minuit
    // L'heure de fin doit être strictement après l'heure de début le même jour
    return endMinutes > startMinutes;
  }

  /// Retourne le message d'erreur pour la durée d'absence
  String? getAbsenceDurationError(TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime == null || endTime == null) return null;
    
    if (!isValidTimeRange(startTime, endTime)) {
      return 'L\'heure de fin doit être après l\'heure de début';
    }
    
    if (!isValidAbsenceDuration(startTime, endTime)) {
      final duration = calculateAbsenceDurationMinutes(startTime, endTime);
      final hours = (duration / 60).toStringAsFixed(1);
      return 'Durée trop longue ($hours h). Maximum autorisé : 2 heures';
    }
    
    return null;
  }
}