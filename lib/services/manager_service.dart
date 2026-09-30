import '../models/leave_request.dart';
import '../models/user.dart';

class ManagerService {
  static final ManagerService _instance = ManagerService._internal();
  factory ManagerService() => _instance;
  ManagerService._internal();

  // Base de données simulée
  final List<LeaveRequest> _allRequests = [];
  final List<UserProfile> _allUsers = [];

  // Initialiser avec des données de test
  void initializeTestData() {
    // Utilisateurs de test
    _allUsers.addAll([
      UserProfile(
        id: 1,
        username: 'M001',
        firstName: 'Sarah',
        lastName: 'Martin',
        email: 'sarah.martin@company.com',
        role: UserRole.manager,
      ),
      UserProfile(
        id: 2,
        username: 'E001',
        firstName: 'Jean',
        lastName: 'Dupont',
        email: 'jean.dupont@company.com',
        role: UserRole.employee,
      ),
      UserProfile(
        id: 3,
        username: 'E002',
        firstName: 'Marie',
        lastName: 'Durand',
        email: 'marie.durand@company.com',
        role: UserRole.employee,
      ),
      UserProfile(
        id: 4,
        username: 'E003',
        firstName: 'Pierre',
        lastName: 'Moreau',
        email: 'pierre.moreau@company.com',
        role: UserRole.employee,
      ),
    ]);

    // Demandes de test
    _allRequests.addAll([
      LeaveRequest(
        id: 'req1',
        userId: '2',
        type: LeaveType.leave,
        nature: LeaveNature.annual,
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 11)),
        comment: 'Congés d\'été',
        status: RequestStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        workingDays: 5,
      ),
      LeaveRequest(
        id: 'req2',
        userId: '3',
        type: LeaveType.absence,
        startDate: DateTime.now().add(const Duration(days: 3)),
        startTime: '14:00',
        endTime: '16:00',
        comment: 'Rendez-vous médical',
        status: RequestStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      LeaveRequest(
        id: 'req3',
        userId: '4',
        type: LeaveType.leave,
        nature: LeaveNature.sick,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        comment: 'Grippe',
        status: RequestStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        workingDays: 3,
      ),
      // Demande déjà traitée pour exemple
      LeaveRequest(
        id: 'req4',
        userId: '2',
        type: LeaveType.leave,
        nature: LeaveNature.annual,
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 6)),
        comment: 'Week-end prolongé',
        status: RequestStatus.approved,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        workingDays: 4,
        managerId: '1',
        managerComment: 'Approuvé - période creuse',
        processedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
    ]);
  }

  // Obtenir toutes les demandes en attente
  List<LeaveRequest> getPendingRequests() {
    return _allRequests.where((request) => request.status == RequestStatus.pending).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Plus anciennes en premier
  }

  // Obtenir les informations d'un employé
  UserProfile? getEmployeeInfo(String userId) {
    return _allUsers.firstWhere(
      (user) => user.id.toString() == userId,
      orElse: () => UserProfile(
        id: int.tryParse(userId) ?? 999,
        firstName: 'Employé',
        lastName: 'Inconnu',
        email: 'unknown@company.com',
        username: 'UNKNOWN',
        role: UserRole.employee,
      ),
    );
  }

  // Approuver une demande
  Future<bool> approveRequest({
    required String requestId,
    required String managerId,
    String? managerComment,
  }) async {
    try {
      final index = _allRequests.indexWhere((req) => req.id == requestId);
      if (index == -1) return false;

      final updatedRequest = _allRequests[index].copyWith(
        status: RequestStatus.approved,
        managerId: managerId,
        managerComment: managerComment,
        processedAt: DateTime.now(),
      );

      _allRequests[index] = updatedRequest;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Refuser une demande
  Future<bool> rejectRequest({
    required String requestId,
    required String managerId,
    String? managerComment,
  }) async {
    try {
      final index = _allRequests.indexWhere((req) => req.id == requestId);
      if (index == -1) return false;

      final updatedRequest = _allRequests[index].copyWith(
        status: RequestStatus.rejected,
        managerId: managerId,
        managerComment: managerComment,
        processedAt: DateTime.now(),
      );

      _allRequests[index] = updatedRequest;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Obtenir toutes les demandes (pour l'historique)
  List<LeaveRequest> getAllRequests() {
    return List.from(_allRequests)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Plus récentes en premier
  }

  // Obtenir les statistiques pour le manager
  Map<String, int> getManagerStatistics() {
    final pending = _allRequests.where((req) => req.status == RequestStatus.pending).length;
    final approved = _allRequests.where((req) => req.status == RequestStatus.approved).length;
    final rejected = _allRequests.where((req) => req.status == RequestStatus.rejected).length;
    
    return {
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
      'total': _allRequests.length,
    };
  }

  // Obtenir les demandes par département
  List<LeaveRequest> getRequestsByDepartment(String department) {
    // Note: department field is a fixed mock on UserProfile
    final departmentUsers = _allUsers.where((user) => user.department == department).map((u) => u.id.toString()).toList();
    return _allRequests.where((req) => departmentUsers.contains(req.userId)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Obtenir une demande spécifique
  LeaveRequest? getRequest(String requestId) {
    try {
      return _allRequests.firstWhere((req) => req.id == requestId);
    } catch (e) {
      return null;
    }
  }
}