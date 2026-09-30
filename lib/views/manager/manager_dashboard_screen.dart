import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../core/animations.dart';
import '../../core/saas_design.dart';
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
      Provider.of<ManagerViewModel>(context, listen: false).loadPendingRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header moderne avec dégradé
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              final user = authViewModel.currentUser;
              return SaaSHeader(
                title: 'Espace Manager',
                subtitle: 'Bonjour ${user?.firstName ?? 'Responsable'} !',
                showBackButton: true,
                actions: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Provider.of<ManagerViewModel>(context, listen: false).loadPendingRequests();
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Contenu
          Expanded(
            child: Consumer<ManagerViewModel>(
              builder: (context, managerViewModel, child) {
                if (managerViewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(SaaSDesign.primaryOrange),
                    ),
                  );
                }

                if (managerViewModel.errorMessage != null &&
                    managerViewModel.pendingRequests.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(SaaSDesign.spacing24),
                      child: Text(
                        managerViewModel.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(SaaSDesign.spacing20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cartes de statistiques
                      _buildStatsCards(managerViewModel.statistics),
                      const SizedBox(height: SaaSDesign.spacing32),
                      
                      // Section des demandes en attente
                      _buildPendingRequestsSection(managerViewModel),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(Map<String, int> stats) {
    return SlideAndFadeAnimation(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: (MediaQuery.of(context).size.width - 60) / 3,
              child: SaaSStatsCard(
                title: 'Attente',
                value: '${stats['pending'] ?? 0}',
                icon: Icons.schedule,
                color: SaaSDesign.warning,
                animationIndex: 0,
              ),
            ),
            const SizedBox(width: SaaSDesign.spacing12),
            SizedBox(
              width: (MediaQuery.of(context).size.width - 60) / 3,
              child: SaaSStatsCard(
                title: 'Validées',
                value: '${stats['approved'] ?? 0}',
                icon: Icons.check_circle,
                color: SaaSDesign.success,
                animationIndex: 1,
              ),
            ),
            const SizedBox(width: SaaSDesign.spacing12),
            SizedBox(
              width: (MediaQuery.of(context).size.width - 60) / 3,
              child: SaaSStatsCard(
                title: 'Refusées',
                value: '${stats['rejected'] ?? 0}',
                icon: Icons.cancel,
                color: SaaSDesign.error,
                animationIndex: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestsSection(ManagerViewModel managerViewModel) {
    final pendingRequests = managerViewModel.pendingRequests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SlideAndFadeAnimation(
          child: Row(
            children: [
              const Text(
                'Demandes en attente',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: SaaSDesign.spacing12),
              SaaSBadge(
                text: '${pendingRequests.length}',
                backgroundColor: SaaSDesign.warning.withOpacity(0.1),
                textColor: SaaSDesign.warning,
                icon: Icons.schedule,
              ),
            ],
          ),
        ),
        const SizedBox(height: SaaSDesign.spacing20),
        
        if (pendingRequests.isEmpty)
          _buildEmptyState()
        else
          StaggeredListAnimation(
            children: pendingRequests.asMap().entries.map((entry) {
              final index = entry.key;
              final request = entry.value;
              final employee = managerViewModel.getEmployeeInfo(request.userId);
              return Padding(
                padding: const EdgeInsets.only(bottom: SaaSDesign.spacing16),
                child: _buildRequestCard(request, employee, index),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SlideAndFadeAnimation(
      child: SaaSCard(
        padding: const EdgeInsets.all(SaaSDesign.spacing48),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(SaaSDesign.spacing24),
              decoration: BoxDecoration(
                color: SaaSDesign.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 64,
                color: SaaSDesign.success.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: SaaSDesign.spacing20),
            const Text(
              'Aucune demande en attente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SaaSDesign.spacing8),
            Text(
              'Les demandes apparaissent ici si vous êtes le responsable assigné, ou si elles n’ont pas encore de responsable.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(LeaveRequest request, UserProfile? employee, int index) {
    return SlideAndFadeAnimation(
      index: index,
      child: SaaSCard(
        onTap: () {
          Navigator.push(
            context,
            SaaSPageRoute(
              child: RequestDetailScreen(request: request),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec info employé
            Row(
              children: [
                // Avatar employé
                Container(
                  padding: const EdgeInsets.all(SaaSDesign.spacing12),
                  decoration: BoxDecoration(
                    gradient: SaaSDesign.primaryGradient,
                    borderRadius: BorderRadius.circular(SaaSDesign.radiusMedium),
                  ),
                  child: Text(
                    employee?.firstName.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: SaaSDesign.spacing16),
                
                // Info employé
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee?.fullName ?? 'Employé Inconnu',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: SaaSDesign.spacing4),
                      Text(
                        '${employee?.employeeId ?? 'N/A'} • ${employee?.department ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Badge statut
                SaaSBadge(
                  text: request.statusText,
                  backgroundColor: SaaSDesign.warning.withOpacity(0.1),
                  textColor: SaaSDesign.warning,
                  icon: Icons.schedule,
                ),
              ],
            ),
            
            const SizedBox(height: SaaSDesign.spacing16),
            
            // Détails de la demande
            Container(
              padding: const EdgeInsets.all(SaaSDesign.spacing16),
              decoration: BoxDecoration(
                color: SaaSDesign.primaryOrange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                border: Border.all(
                  color: SaaSDesign.primaryOrange.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        request.type == LeaveType.leave 
                            ? Icons.calendar_month 
                            : Icons.access_time,
                        size: 18,
                        color: SaaSDesign.primaryOrange,
                      ),
                      const SizedBox(width: SaaSDesign.spacing8),
                      Text(
                        request.displayTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SaaSDesign.spacing8),
                  Text(
                    request.displayPeriod,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  if (request.comment != null && request.comment!.isNotEmpty) ...[
                    const SizedBox(height: SaaSDesign.spacing12),
                    Container(
                      padding: const EdgeInsets.all(SaaSDesign.spacing8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.format_quote,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: SaaSDesign.spacing4),
                          Expanded(
                            child: Text(
                              request.comment!,
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: SaaSDesign.spacing16),
            
            // Footer
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: SaaSDesign.spacing4),
                Text(
                  _getTimeAgo(request.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SaaSDesign.spacing8,
                    vertical: SaaSDesign.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: SaaSDesign.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Examiner',
                        style: TextStyle(
                          fontSize: 10,
                          color: SaaSDesign.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: SaaSDesign.spacing4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: SaaSDesign.primaryOrange,
                      ),
                    ],
                  ),
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