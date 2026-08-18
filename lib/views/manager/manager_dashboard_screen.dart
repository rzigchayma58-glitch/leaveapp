import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/manager_viewmodel.dart';
import '../../models/leave_request.dart';
import '../../models/user.dart';
import 'request_detail_screen.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ManagerViewModel>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Espace Responsable',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: ThemeColors.appBarColor(context),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<ManagerViewModel>(context, listen: false).loadPendingRequests();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<ManagerViewModel>(
        builder: (context, managerViewModel, child) {
          if (managerViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryOrange),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 20),
                _buildStatsCards(managerViewModel.statistics),
                const SizedBox(height: 20),
                _buildPendingRequestsSection(managerViewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final user = authViewModel.currentUser;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppConstants.primaryOrange, AppConstants.lightOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryOrange.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour ${user?.firstName ?? 'Responsable'} !',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Gérez les demandes de votre équipe',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(Map<String, int> stats) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'En attente',
            value: stats['pending'] ?? 0,
            color: AppConstants.pendingColor,
            icon: Icons.schedule,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Approuvées',
            value: stats['approved'] ?? 0,
            color: AppConstants.approvedColor,
            icon: Icons.check_circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Refusées',
            value: stats['rejected'] ?? 0,
            color: AppConstants.rejectedColor,
            icon: Icons.cancel,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.shadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ThemeColors.textColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: ThemeColors.secondaryTextColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsSection(ManagerViewModel managerViewModel) {
    final pendingRequests = managerViewModel.pendingRequests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Demandes en attente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeColors.textColor(context),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.pendingColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${pendingRequests.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.pendingColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (pendingRequests.isEmpty)
          _buildEmptyState()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingRequests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final request = pendingRequests[index];
              final employee = managerViewModel.getEmployeeInfo(request.userId);
              return _buildRequestCard(request, employee);
            },
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: ThemeColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeColors.borderColor(context),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: ThemeColors.secondaryTextColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune demande en attente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ThemeColors.textColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toutes les demandes ont été traitées',
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.secondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(LeaveRequest request, User? employee) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequestDetailScreen(request: request),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeColors.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeColors.borderColor(context),
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.shadowColor(context),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppConstants.primaryOrange.withOpacity(0.1),
                  child: Text(
                    employee?.firstName.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.primaryOrange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee?.fullName ?? 'Employé Inconnu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.textColor(context),
                        ),
                      ),
                      Text(
                        '${employee?.employeeId ?? 'N/A'} • ${employee?.department ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeColors.secondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.pendingColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.statusText,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.pendingColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.primaryOrange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        request.type == LeaveType.leave ? Icons.calendar_month : Icons.access_time,
                        size: 16,
                        color: AppConstants.primaryOrange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        request.displayTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.textColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.displayPeriod,
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.secondaryTextColor(context),
                    ),
                  ),
                  if (request.comment != null && request.comment!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Commentaire: ${request.comment}',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: ThemeColors.secondaryTextColor(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: ThemeColors.secondaryTextColor(context),
                ),
                const SizedBox(width: 4),
                Text(
                  _getTimeAgo(request.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeColors.secondaryTextColor(context),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppConstants.primaryOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}