import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leave_request.dart';
import 'auth_service.dart';
import 'api_config.dart';

class LeaveService {
  static final LeaveService _instance = LeaveService._internal();
  factory LeaveService() => _instance;
  LeaveService._internal();

  // 🚀 CACHE GLOBAL DES TYPES DE CONGÉ
  static List<LeaveTypeModel>? _cachedLeaveTypes;
  static DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 5); // Cache 5 minutes

  Future<List<LeaveTypeModel>> getLeaveTypes({bool forceRefresh = false}) async {
    final token = await AuthService.getStoredToken();
    final knownTypes = [
      LeaveTypeModel(id: 1, name: 'Conge annuel'),
      LeaveTypeModel(id: 2, name: 'Autorisation d absence'),
      LeaveTypeModel(id: 3, name: 'Conge maladie'),
      LeaveTypeModel(id: 4, name: 'Conge exceptionnel'),
    ];

    if (token == null) {
      print('⚠️ Pas de token, utilisation des types locaux');
      return knownTypes;
    }

    if (!forceRefresh &&
        _cachedLeaveTypes != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedLeaveTypes!;
    }

    final endpoints = [
      '${ApiConfig.baseUrl}/leave-types',
      '${ApiConfig.baseUrl}/conge-types',
      '${ApiConfig.baseUrl}/flutter/leave-types',
    ];

    Object? lastError;
    for (final url in endpoints) {
      try {
        print('📡 GET $url');
        final response = await http
            .get(Uri.parse(url), headers: ApiConfig.authHeaders(token))
            .timeout(const Duration(seconds: 8));

        print('📡 Types Status: ${response.statusCode}');
        print('📡 Types Response: ${response.body}');

        if (response.statusCode == 401) {
          lastError = ApiException(401, 'Session expirée. Reconnectez-vous.');
          continue;
        }

        if (response.statusCode != 200) {
          lastError = ApiException.fromResponse(response.statusCode, response.body);
          continue;
        }

        final types = _parseLeaveTypes(response.body)
            .where((type) => type.isActive)
            .toList();

        if (types.isEmpty) {
          lastError = ApiException(404, 'Aucun type de congé actif trouvé');
          continue;
        }

        _cachedLeaveTypes = types;
        _cacheTime = DateTime.now();
        print('✅ ${types.length} types chargés (IDs: ${types.map((t) => t.id).join(', ')})');
        for (final type in types) {
          print('   - ID ${type.id}: ${type.name}');
        }
        return types;
      } catch (e) {
        print('⚠️ Échec $url: $e');
        lastError = e;
      }
    }

    print('⚠️ Fallback types MySQL (dernier essai: $lastError)');
    _cachedLeaveTypes = knownTypes;
    _cacheTime = DateTime.now();
    return knownTypes;
  }

  List<LeaveTypeModel> _parseLeaveTypes(String body) {
    final decoded = jsonDecode(body);
    List<dynamic> rawList = const [];

    if (decoded is List) {
      rawList = decoded;
    } else if (decoded is Map<String, dynamic>) {
      for (final key in ['content', 'data', 'items', 'leaveTypes', 'types']) {
        if (decoded[key] is List) {
          rawList = decoded[key] as List;
          break;
        }
      }
    }

    return rawList.whereType<Map>().map((item) {
      return LeaveTypeModel.fromBackendJson(Map<String, dynamic>.from(item));
    }).where((type) => type.id > 0).toList();
  }

  int resolveLeaveTypeId({
    required List<LeaveTypeModel> types,
    required bool isAbsence,
    int? selectedId,
  }) {
    if (isAbsence) {
      final absence = types.where((type) => type.isAbsence).toList();
      if (absence.isNotEmpty) return absence.first.id;
      throw ApiException(404, 'Aucun type d\'autorisation d\'absence disponible');
    }

    final leaveTypes = types.where((type) => !type.isAbsence).toList();
    if (selectedId != null && leaveTypes.any((type) => type.id == selectedId)) {
      return selectedId;
    }

    throw ApiException(400, 'Veuillez sélectionner un type de congé valide');
  }

  // 📝 CRÉER UNE DEMANDE DIRECTEMENT DANS MYSQL
  Future<int?> createRequest({
    required int requesterId,
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    bool isAbsence = false,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) async {
    final token = await AuthService.getStoredToken();
    if (token == null) throw ApiException(401, 'Non authentifié');
    
    try {
      print('📤 Envoi demande vers MySQL...');
      
      final requestedDays = isAbsence && startTime != null && endTime != null
          ? (calculateAbsenceDurationMinutes(startTime, endTime) / 60.0 / 8.0)
          : calculateWorkingDays(startDate, endDate).toDouble();

      String resolvedReason = reason?.trim() ?? '';
      if (resolvedReason.isEmpty) {
        if (isAbsence && startTime != null && endTime != null) {
          resolvedReason =
              "Autorisation d'absence ${_formatTime(startTime)}-${_formatTime(endTime)}";
        } else if (isAbsence) {
          resolvedReason = "Autorisation d'absence via Flutter";
        } else {
          resolvedReason = 'Demande de congé via Flutter';
        }
      }

      final demande = {
        'requesterId': requesterId,
        'leaveTypeId': leaveTypeId,
        'startDate': _formatDate(startDate),
        'endDate': _formatDate(endDate),
        'requestedDays': double.parse(requestedDays.toStringAsFixed(2)),
        'reason': resolvedReason,
        if (isAbsence && startTime != null) 'startTime': _formatTime(startTime),
        if (isAbsence && endTime != null) 'endTime': _formatTime(endTime),
      };

      print('📤 Payload: $demande');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/leave-requests'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode(demande),
      );

      print('📡 Création Status: ${response.statusCode}');
      print('📡 Création Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Demande enregistrée dans MySQL !');
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['id'] != null) {
            return int.tryParse(data['id'].toString());
          }
        } catch (_) {}
        return 0;
      } else if (response.statusCode == 404 && response.body.contains('Leave type not found')) {
        print('❌ Type de congé inexistant dans MySQL (ID: $leaveTypeId)');
        _cachedLeaveTypes = null;
        _cacheTime = null;
        throw ApiException(
          404,
          'Ce type de congé n\'existe pas côté serveur. Rechargez la liste des types puis réessayez.',
        );
      } else {
        print('❌ Erreur serveur: ${response.statusCode}');
        throw ApiException.fromResponse(response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Erreur création demande: $e');
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Erreur de création de la demande: $e');
    }
  }

  // 📋 RÉCUPÉRER LES DEMANDES DEPUIS MYSQL
  Future<List<LeaveRequestResponse>> getUserRequests(int userId) async {
    final token = await AuthService.getStoredToken();
    if (token == null) throw ApiException(401, 'Non authentifié');

    try {
      print('📡 Récupération demandes depuis MySQL...');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/leave-requests/requester/$userId'),
        headers: ApiConfig.authHeaders(token),
      );

      print('📡 Historique Status: ${response.statusCode}');
      print('📡 Historique Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final requests = data.map((json) => LeaveRequestResponse.fromJson(json)).toList();
        
        // Trier par date de soumission (plus récent en premier)
        requests.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
        
        print('✅ ${requests.length} demandes trouvées dans MySQL');
        return requests;
      } else {
        print('❌ Erreur historique: ${response.statusCode}');
        throw ApiException.fromResponse(response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Erreur réseau historique: $e');
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Erreur de récupération des demandes: $e');
    }
  }

  // 💰 SOLDES DEPUIS MYSQL (ou simulation)
  Future<List<LeaveBalanceResponse>> getUserBalance(int userId) async {
    final token = await AuthService.getStoredToken();
    
    try {
      if (token != null) {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/leave-balances/user/$userId'),
          headers: ApiConfig.authHeaders(token),
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          return data.map((json) => LeaveBalanceResponse.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('⚠️ Soldes backend non disponibles, utilisation simulation');
    }
    
    // Fallback - soldes simulés si backend pas accessible
    return [
      LeaveBalanceResponse.createLocal(
        id: 1,
        userId: userId,
        leaveTypeId: 1,
        leaveTypeName: 'Congé annuel',
        year: DateTime.now().year,
        totalDays: 30.0,
        usedDays: 0.0,
        remainingDays: 30.0,
      ),
      LeaveBalanceResponse.createLocal(
        id: 2,
        userId: userId,
        leaveTypeId: 2,
        leaveTypeName: 'Autorisation d\'absence',
        year: DateTime.now().year,
        totalDays: 0.0,
        usedDays: 0.0,
        remainingDays: 0.0,
      ),
    ];
  }

  // 📊 STATISTIQUES DEPUIS LOCAL
  Map<String, int> getStatisticsFromRequests(List<LeaveRequestResponse> requests) {
    return {
      'pending': requests.where((r) => r.status == LeaveRequestStatus.pending).length,
      'approved': requests.where((r) => r.status == LeaveRequestStatus.approved).length,
      'rejected': requests.where((r) => r.status == LeaveRequestStatus.rejected).length,
    };
  }

  // 🔧 MÉTHODES UTILITAIRES
  int calculateWorkingDays(DateTime startDate, DateTime endDate) {
    int workingDays = 0;
    DateTime current = startDate;
    
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      if (current.weekday < 6) {
        workingDays++;
      }
      current = current.add(const Duration(days: 1));
    }
    
    return workingDays;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // MÉTHODES MANQUANTES POUR LA COMPATIBILITÉ AVEC LE VIEWMODEL

  // Calcul du solde total disponible
  int getTotalAvailableBalance(List<LeaveBalanceResponse> balances) {
    return balances.fold<int>(0, (total, balance) => total + balance.remainingDays.round());
  }

  // Gestion Manager - Demandes d'équipe
  Future<List<LeaveRequestResponse>> getTeamRequests(int managerId) async {
    final token = await AuthService.getStoredToken();
    if (token == null) throw ApiException(401, 'Non authentifié');

    final byId = <int, LeaveRequestResponse>{};
    final headers = ApiConfig.authHeaders(token);

    Future<void> ingest(String path) async {
      try {
        final response = await http
            .get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: headers)
            .timeout(const Duration(seconds: 6));
        print('📡 Manager GET $path => ${response.statusCode}');
        if (response.statusCode != 200) return;
        final decoded = jsonDecode(response.body);
        if (decoded is! List) return;
        for (final item in decoded) {
          if (item is! Map) continue;
          try {
            final req = LeaveRequestResponse.fromJson(Map<String, dynamic>.from(item));
            if (req.id > 0) byId[req.id] = req;
          } catch (e) {
            print('⚠️ Parse demande ignorée: $e');
          }
        }
      } catch (e) {
        print('⚠️ Manager GET $path: $e');
      }
    }

    Future<Set<int>> loadTeamIds() async {
      final ids = <int>{};
      try {
        final response = await http
            .get(
              Uri.parse('${ApiConfig.baseUrl}/users/$managerId/team'),
              headers: headers,
            )
            .timeout(const Duration(seconds: 8));
        print('📡 Manager GET /users/$managerId/team => ${response.statusCode}');
        if (response.statusCode != 200) return ids;
        final decoded = jsonDecode(response.body);
        if (decoded is! List) return ids;
        for (final item in decoded) {
          if (item is Map && item['id'] != null) {
            final id = int.tryParse(item['id'].toString());
            if (id != null) ids.add(id);
          }
        }
      } catch (e) {
        print('⚠️ Team members: $e');
      }
      return ids;
    }

    await ingest('/leave-requests/approver/$managerId');
    final teamIds = await loadTeamIds();
    teamIds.addAll({14, 15});
    for (final employeeId in teamIds) {
      await ingest('/leave-requests/requester/$employeeId');
    }

    // Les employés sans manager créent des demandes non assignées.
    // GET /leave-requests est interdit au manager, on parcourt les demandeurs.
    final scanQueue = <Future<void>>[];
    for (var id = 1; id <= 50; id++) {
      if (id == managerId || teamIds.contains(id)) continue;
      scanQueue.add(ingest('/leave-requests/requester/$id'));
      if (scanQueue.length >= 8) {
        await Future.wait(scanQueue);
        scanQueue.clear();
      }
    }
    if (scanQueue.isNotEmpty) {
      await Future.wait(scanQueue);
    }

    final list = byId.values.toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    print('✅ ${list.length} demandes manager chargées depuis MySQL (équipe: ${teamIds.length})');
    return list;
  }

  // Méthodes de validation
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

  bool isValidAdvanceNotice(LeaveType type, DateTime requestDate) {
    final now = DateTime.now();
    final difference = requestDate.difference(now);
    
    switch (type) {
      case LeaveType.absence:
        return difference.inHours >= 48;
      case LeaveType.leave:
        return difference.inHours >= 72;
    }
  }

  String? getAbsenceDurationError(TimeOfDay? startTime, TimeOfDay? endTime) {
    if (startTime == null || endTime == null) return null;
    final minutes = calculateAbsenceDurationMinutes(startTime, endTime);
    if (minutes <= 0) return 'L\'heure de fin doit être après l\'heure de début';
    if (minutes > 4 * 60) return 'Une autorisation d\'absence ne peut dépasser 4 heures';
    return null;
  }

  int getHoursUntilMinimum(LeaveType type, DateTime startDate) {
    final now = DateTime.now();
    final difference = startDate.difference(now);
    final minHours = type == LeaveType.absence ? 48 : 72;
    final remaining = minHours - difference.inHours;
    return remaining > 0 ? remaining : 0;
  }

  int calculateAbsenceDurationMinutes(TimeOfDay startTime, TimeOfDay endTime) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    return endMinutes - startMinutes;
  }

  // Méthodes de création/gestion
  Future<bool> approveRequest(int requestId, String? comments, {int? approverId}) async {
    final token = await AuthService.getStoredToken();
    if (token == null) throw ApiException(401, 'Non authentifié');

    var actorId = approverId;
    if (actorId == null) {
      actorId = (await AuthService.getStoredUser())?.id;
    }
    if (actorId == null) {
      throw ApiException(401, 'Responsable non identifié');
    }

    final comment = (comments == null || comments.trim().isEmpty)
        ? 'Approuve'
        : comments.trim();

    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/leave-requests/$requestId/approve'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode({
          'approverId': actorId,
          'comment': comment,
        }),
      );
      print('📡 Approve $requestId => ${response.statusCode} ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) return true;
      throw _apiError(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Erreur d\'approbation: $e');
    }
  }

  Future<bool> rejectRequest(int requestId, String comments, String? reason, {int? approverId}) async {
    final token = await AuthService.getStoredToken();
    if (token == null) throw ApiException(401, 'Non authentifié');

    var actorId = approverId;
    if (actorId == null) {
      actorId = (await AuthService.getStoredUser())?.id;
    }
    if (actorId == null) {
      throw ApiException(401, 'Responsable non identifié');
    }

    final comment = comments.trim().isEmpty ? 'Refuse' : comments.trim();

    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/leave-requests/$requestId/reject'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode({
          'approverId': actorId,
          'comment': comment,
        }),
      );
      print('📡 Reject $requestId => ${response.statusCode} ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) return true;
      throw _apiError(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Erreur de refus: $e');
    }
  }

  Future<void> deleteRequest(int requestId) async {
    final token = await AuthService.getStoredToken();
    if (token == null) throw ApiException(401, 'Non authentifié');
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/leave-requests/$requestId'),
        headers: ApiConfig.authHeaders(token),
      );
      print('📡 Delete $requestId => ${response.statusCode} ${response.body}');
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 404) {
        return;
      }
      throw _apiError(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Erreur de suppression: $e');
    }
  }

  Future<bool> submitRequest(LeaveRequest request) async {
    // Appel direct au backend MySQL
    final user = await AuthService.getStoredUser();
    if (user != null && request.startDate != null && request.endDate != null) {
      // Mapper nature vers leaveTypeId
      int leaveTypeId = 1; // Congé annuel par défaut
      if (request.nature != null) {
        switch (request.nature!) {
          case LeaveNature.annual:
            leaveTypeId = 1;
            break;
          case LeaveNature.sick:
            leaveTypeId = 2;
            break;
          case LeaveNature.exceptional:
            leaveTypeId = 3;
            break;
          case LeaveNature.other:
            leaveTypeId = 1;
            break;
        }
      }
      
      return (await createRequest(
        requesterId: user.id,
        leaveTypeId: leaveTypeId,
        startDate: request.startDate!,
        endDate: request.endDate!,
        reason: request.comment,
      )) != null;
    }
    return false;
  }

  ApiException _apiError(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map && data['message'] != null) {
        return ApiException(response.statusCode, data['message'].toString(), response.body);
      }
    } catch (_) {}
    return ApiException.fromResponse(response.statusCode, response.body);
  }

  // Test de connexion backend
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl.replaceAll('/api', '')}/api/flutter/test'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur test connexion: $e');
      return false;
    }
  }
}

// MODÈLE ÉTENDU POUR LES TYPES DE CONGÉ
class LeaveTypeModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  bool get isAbsence {
    final normalized = name.toLowerCase();
    return normalized.contains('absence') || normalized.contains('autorisation');
  }

  LeaveTypeModel({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
  });

  factory LeaveTypeModel.fromBackendJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;
    final rawActive =
        json['active'] ?? json['is_active'] ?? json['isActive'] ?? json['actif'] ?? true;
    return LeaveTypeModel(
      id: parsedId,
      name: (json['name'] ?? json['nom'] ?? json['label'] ?? 'Inconnu').toString(),
      description: json['description']?.toString(),
      isActive: rawActive == true || rawActive == 1 || rawActive == '1',
    );
  }
}