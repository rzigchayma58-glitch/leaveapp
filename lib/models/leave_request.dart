import 'package:flutter/material.dart';
import 'user.dart';

// NOUVEAUX modèles adaptés au backend Spring Boot
class LeaveRequestCreateDto {
  final int requesterId;
  final int leaveTypeId;
  final String startDate;
  final String endDate;
  final String? reason;

  LeaveRequestCreateDto({
    required this.requesterId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'requesterId': requesterId,
      'leaveTypeId': leaveTypeId,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
    };
  }
}

class LeaveRequestResponse {
  final int id;
  final RequesterInfo requester;
  final ApproverInfo? approver;
  final LeaveTypeInfo leaveType;
  final String startDate;
  final String endDate;
  final double requestedDays;
  final String? reason;
  final LeaveRequestStatus status;
  final DateTime submittedAt;
  final DateTime? decisionAt;
  final String? decisionComment;

  LeaveRequestResponse({
    required this.id,
    required this.requester,
    this.approver,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.requestedDays,
    this.reason,
    required this.status,
    required this.submittedAt,
    this.decisionAt,
    this.decisionComment,
  });

  // Propriétés calculées pour compatibilité avec l'UI existante
  LeaveType get type {
    final name = leaveType.name.toLowerCase();
    if (name.contains('absence') || name.contains('autorisation')) {
      return LeaveType.absence;
    }
    return LeaveType.leave;
  }
  LeaveNature? get nature => type == LeaveType.absence ? null : _mapLeaveTypeToNature(leaveType.id);
  String? get comment => reason;
  String get displayTitle => leaveType.name;

  LeaveRequest toUiRequest() {
    DateTime parsedStart;
    DateTime parsedEnd;
    try {
      parsedStart = DateTime.parse(startDate);
    } catch (_) {
      parsedStart = submittedAt;
    }
    try {
      parsedEnd = DateTime.parse(endDate);
    } catch (_) {
      parsedEnd = parsedStart;
    }

    return LeaveRequest(
      id: id.toString(),
      userId: requester.id.toString(),
      type: type,
      nature: nature,
      startDate: parsedStart,
      endDate: parsedEnd,
      comment: reason,
      status: requestStatus,
      createdAt: submittedAt,
      workingDays: requestedDays.round(),
      managerComment: decisionComment,
      processedAt: decisionAt,
    );
  }

  UserProfile toEmployeeProfile() {
    return UserProfile(
      id: requester.id,
      username: requester.email,
      email: requester.email,
      firstName: requester.firstName,
      lastName: requester.lastName,
      role: UserRole.employee,
    );
  }
  int? get workingDays => requestedDays.round();
  DateTime get createdAt => submittedAt;
  
  String get displayPeriod {
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return '${_formatDate(start)} - ${_formatDate(end)} • ${requestedDays.round()} jours';
  }

  String get statusText {
    switch (status) {
      case LeaveRequestStatus.pending:
        return 'En attente';
      case LeaveRequestStatus.approved:
        return 'Approuvé';
      case LeaveRequestStatus.rejected:
        return 'Refusé';
      case LeaveRequestStatus.cancelled:
        return 'Annulé';
    }
  }

  RequestStatus get requestStatus {
    switch (status) {
      case LeaveRequestStatus.pending:
        return RequestStatus.pending;
      case LeaveRequestStatus.approved:
        return RequestStatus.approved;
      case LeaveRequestStatus.rejected:
        return RequestStatus.rejected;
      case LeaveRequestStatus.cancelled:
        return RequestStatus.rejected;
    }
  }

  static LeaveNature? _mapLeaveTypeToNature(int leaveTypeId) {
    switch (leaveTypeId) {
      case 1: return LeaveNature.annual;
      case 3: return LeaveNature.sick;
      case 4: return LeaveNature.exceptional;
      default: return LeaveNature.other;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  factory LeaveRequestResponse.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    final requesterJson = json['requester'] is Map
        ? Map<String, dynamic>.from(json['requester'] as Map)
        : <String, dynamic>{
            'id': json['requesterId'] ?? 0,
            'firstName': json['firstName'] ?? '',
            'lastName': json['lastName'] ?? '',
            'email': json['email'] ?? '',
          };
    final leaveTypeJson = json['leaveType'] is Map
        ? Map<String, dynamic>.from(json['leaveType'] as Map)
        : <String, dynamic>{
            'id': json['leaveTypeId'] ?? 1,
            'name': json['leaveTypeName'] ?? 'Congé',
          };

    return LeaveRequestResponse(
      id: int.tryParse(json['id'].toString()) ?? 0,
      requester: RequesterInfo.fromJson(requesterJson),
      approver: json['approver'] is Map
          ? ApproverInfo.fromJson(Map<String, dynamic>.from(json['approver'] as Map))
          : null,
      leaveType: LeaveTypeInfo.fromJson(leaveTypeJson),
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      requestedDays: (json['requestedDays'] as num?)?.toDouble() ?? 0,
      reason: json['reason']?.toString(),
      status: _parseStatus(json['status']?.toString() ?? 'PENDING'),
      submittedAt: parseDate(json['submittedAt']),
      decisionAt: json['decisionAt'] != null ? parseDate(json['decisionAt']) : null,
      decisionComment: json['decisionComment']?.toString(),
    );
  }

  // 📱 FACTORY POUR DONNÉES LOCALES
  factory LeaveRequestResponse.fromLocalJson(Map<String, dynamic> json) {
    return LeaveRequestResponse(
      id: json['id'],
      requester: RequesterInfo(
        id: json['requesterId'],
        firstName: 'Local',
        lastName: 'User',
        email: 'local@app.com',
      ),
      approver: null,
      leaveType: LeaveTypeInfo(
        id: json['leaveTypeId'],
        name: _getLeaveTypeName(json['leaveTypeId']),
      ),
      startDate: json['startDate'],
      endDate: json['endDate'],
      requestedDays: (json['requestedDays'] as num).toDouble(),
      reason: json['reason'],
      status: _parseStatus(json['status']),
      submittedAt: DateTime.parse(json['submittedAt']),
      decisionAt: json['decisionAt'] != null ? DateTime.parse(json['decisionAt']) : null,
      decisionComment: json['decisionComment'],
    );
  }

  static String _getLeaveTypeName(int typeId) {
    switch (typeId) {
      case 1: return 'Congé annuel';
      case 2: return 'Autorisation d\'absence';
      case 3: return 'Congé maladie';
      case 4: return 'Congé exceptionnel';
      default: return 'Autre';
    }
  }

  static LeaveRequestStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING': return LeaveRequestStatus.pending;
      case 'APPROVED': return LeaveRequestStatus.approved;
      case 'REJECTED': return LeaveRequestStatus.rejected;
      case 'CANCELLED': return LeaveRequestStatus.cancelled;
      default: return LeaveRequestStatus.pending;
    }
  }
}

class RequesterInfo {
  final int id;
  final String firstName;
  final String lastName;
  final String email;

  RequesterInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory RequesterInfo.fromJson(Map<String, dynamic> json) {
    return RequesterInfo(
      id: int.tryParse(json['id'].toString()) ?? 0,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class ApproverInfo {
  final int id;
  final String firstName;
  final String lastName;
  final String email;

  ApproverInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory ApproverInfo.fromJson(Map<String, dynamic> json) {
    return ApproverInfo(
      id: int.tryParse(json['id'].toString()) ?? 0,
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class LeaveTypeInfo {
  final int id;
  final String name;

  LeaveTypeInfo({
    required this.id,
    required this.name,
  });

  factory LeaveTypeInfo.fromJson(Map<String, dynamic> json) {
    return LeaveTypeInfo(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Congé',
    );
  }
}

enum LeaveRequestStatus { pending, approved, rejected, cancelled }

// Balance models
class LeaveBalanceResponse {
  final int id;
  final UserBalanceInfo user;
  final LeaveTypeInfo leaveType;
  final int year;
  final double totalDays;
  final double usedDays;
  final double remainingDays;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LeaveBalanceResponse({
    required this.id,
    required this.user,
    required this.leaveType,
    required this.year,
    required this.totalDays,
    required this.usedDays,
    required this.remainingDays,
    required this.createdAt,
    this.updatedAt,
  });

  factory LeaveBalanceResponse.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceResponse(
      id: json['id'],
      user: UserBalanceInfo.fromJson(json['user']),
      leaveType: LeaveTypeInfo.fromJson(json['leaveType']),
      year: json['year'],
      totalDays: (json['totalDays'] as num).toDouble(),
      usedDays: (json['usedDays'] as num).toDouble(),
      remainingDays: (json['remainingDays'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // 📱 FACTORY POUR SOLDES LOCAUX
  factory LeaveBalanceResponse.createLocal({
    required int id,
    required int userId,
    required int leaveTypeId,
    required String leaveTypeName,
    required int year,
    required double totalDays,
    required double usedDays,
    required double remainingDays,
  }) {
    return LeaveBalanceResponse(
      id: id,
      user: UserBalanceInfo(
        id: userId,
        firstName: 'User',
        lastName: 'Local',
      ),
      leaveType: LeaveTypeInfo(
        id: leaveTypeId,
        name: leaveTypeName,
      ),
      year: year,
      totalDays: totalDays,
      usedDays: usedDays,
      remainingDays: remainingDays,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

class UserBalanceInfo {
  final int id;
  final String firstName;
  final String lastName;

  UserBalanceInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory UserBalanceInfo.fromJson(Map<String, dynamic> json) {
    return UserBalanceInfo(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
}

// ANCIENS modèles pour compatibilité UI

class AttachedFile {
  final String name;
  final String path;
  final String type; // 'image', 'pdf', 'document'
  final int size; // en bytes
  final DateTime addedAt;

  AttachedFile({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.addedAt,
  });

  String get displaySize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  IconData get icon {
    switch (type) {
      case 'image':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'document':
      default:
        return Icons.description;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'type': type,
      'size': size,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  factory AttachedFile.fromJson(Map<String, dynamic> json) {
    return AttachedFile(
      name: json['name'],
      path: json['path'],
      type: json['type'],
      size: json['size'],
      addedAt: DateTime.fromMillisecondsSinceEpoch(json['addedAt']),
    );
  }
}

enum LeaveType {
  leave,
  absence,
}

enum LeaveNature {
  annual,
  exceptional,
  sick,
  other,
}

enum RequestStatus {
  pending,
  approved,
  rejected,
}

class LeaveRequest {
  final String? id;
  final String userId;
  final LeaveType type;
  final LeaveNature? nature;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;
  final String? comment;
  final RequestStatus status;
  final DateTime createdAt;
  final int? workingDays;
  final List<AttachedFile> attachments;
  
  // Champs pour la gestion par le responsable
  final String? managerId;
  final String? managerComment;
  final DateTime? processedAt;

  LeaveRequest({
    this.id,
    required this.userId,
    required this.type,
    this.nature,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.comment,
    this.status = RequestStatus.pending,
    required this.createdAt,
    this.workingDays,
    this.attachments = const [],
    this.managerId,
    this.managerComment,
    this.processedAt,
  });

  String get typeText {
    switch (type) {
      case LeaveType.leave:
        return 'Congé';
      case LeaveType.absence:
        return 'Autorisation d\'absence';
    }
  }

  String get natureText {
    if (nature == null) return '';
    switch (nature!) {
      case LeaveNature.annual:
        return 'annuel';
      case LeaveNature.exceptional:
        return 'exceptionnel';
      case LeaveNature.sick:
        return 'maladie';
      case LeaveNature.other:
        return 'sans solde';
    }
  }

  String get statusText {
    switch (status) {
      case RequestStatus.pending:
        return 'En attente';
      case RequestStatus.approved:
        return 'Approuvés';
      case RequestStatus.rejected:
        return 'Refusée';
    }
  }

  String get displayTitle {
    if (type == LeaveType.absence) {
      return 'Autorisation d\'absence';
    } else {
      return 'Congé $natureText';
    }
  }

  String get displayPeriod {
    if (startDate == null) return '';
    
    if (type == LeaveType.absence && startTime != null && endTime != null) {
      return '${_formatDate(startDate!)} - $startTime à $endTime';
    } else if (endDate != null) {
      if (workingDays != null) {
        return '${_formatDate(startDate!)} - ${_formatDate(endDate!)} • $workingDays jours';
      } else {
        return '${_formatDate(startDate!)} - ${_formatDate(endDate!)}';
      }
    } else {
      return _formatDate(startDate!);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.index,
      'nature': nature?.index,
      'startDate': startDate?.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'startTime': startTime,
      'endTime': endTime,
      'comment': comment,
      'status': status.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'workingDays': workingDays,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'managerId': managerId,
      'managerComment': managerComment,
      'processedAt': processedAt?.millisecondsSinceEpoch,
    };
  }

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      userId: json['userId'],
      type: LeaveType.values[json['type']],
      nature: json['nature'] != null ? LeaveNature.values[json['nature']] : null,
      startDate: json['startDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(json['endDate']) : null,
      startTime: json['startTime'],
      endTime: json['endTime'],
      comment: json['comment'],
      status: RequestStatus.values[json['status']],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      workingDays: json['workingDays'],
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((a) => AttachedFile.fromJson(a))
          .toList() ?? [],
      managerId: json['managerId'],
      managerComment: json['managerComment'],
      processedAt: json['processedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['processedAt']) : null,
    );
  }

  LeaveRequest copyWith({
    String? id,
    String? userId,
    LeaveType? type,
    LeaveNature? nature,
    DateTime? startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    String? comment,
    RequestStatus? status,
    DateTime? createdAt,
    int? workingDays,
    List<AttachedFile>? attachments,
    String? managerId,
    String? managerComment,
    DateTime? processedAt,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      nature: nature ?? this.nature,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      workingDays: workingDays ?? this.workingDays,
      attachments: attachments ?? this.attachments,
      managerId: managerId ?? this.managerId,
      managerComment: managerComment ?? this.managerComment,
      processedAt: processedAt ?? this.processedAt,
    );
  }
}