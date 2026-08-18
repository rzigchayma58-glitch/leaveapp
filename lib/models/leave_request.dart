import 'package:flutter/material.dart';

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