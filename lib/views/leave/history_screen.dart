import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../core/animations.dart';
import '../../core/saas_design.dart';
import '../../models/leave_request.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/leave_viewmodel.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<LeaveViewModel>(context, listen: false).loadUserData(user.id ?? 'user1');
      }
    });
  }

  Color _getStatusColor(LeaveRequestStatus status) {
    switch (status) {
      case LeaveRequestStatus.pending:
        return SaaSDesign.warning;
      case LeaveRequestStatus.approved:
        return SaaSDesign.success;
      case LeaveRequestStatus.rejected:
      case LeaveRequestStatus.cancelled:
        return SaaSDesign.error;
    }
  }

  IconData _getStatusIconData(LeaveRequestStatus status) {
    switch (status) {
      case LeaveRequestStatus.pending:
        return Icons.schedule;
      case LeaveRequestStatus.approved:
        return Icons.check_circle;
      case LeaveRequestStatus.rejected:
      case LeaveRequestStatus.cancelled:
        return Icons.cancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header moderne avec dégradé
          SaaSHeader(
            title: 'Historique',
            subtitle: 'Mes demandes de congés',
            showBackButton: true,
            actions: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                ),
                child: IconButton(
                  onPressed: () {
                    final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
                    if (user != null) {
                      Provider.of<LeaveViewModel>(context, listen: false).loadUserData(user.id ?? 'user1');
                    }
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
              ),
            ],
          ),
          
          // Contenu
          Expanded(
            child: Consumer<LeaveViewModel>(
              builder: (context, leaveViewModel, child) {
                final requests = leaveViewModel.requests;

                if (requests.isEmpty) {
                  return SlideAndFadeAnimation(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(SaaSDesign.spacing32),
                            decoration: BoxDecoration(
                              color: SaaSDesign.primaryOrange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.history_outlined,
                              size: 64,
                              color: SaaSDesign.primaryOrange.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: SaaSDesign.spacing24),
                          const Text(
                            'Aucune demande trouvée',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: SaaSDesign.spacing8),
                          Text(
                            'Vos demandes apparaîtront ici',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(SaaSDesign.spacing20),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: SaaSDesign.spacing16),
                  itemBuilder: (context, index) {
                    return _buildRequestCard(requests[index], index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(LeaveRequestResponse request, int index) {
    final statusColor = _getStatusColor(request.status);
    final statusIconData = _getStatusIconData(request.status);
    
    return SlideAndFadeAnimation(
      index: index,
      child: SaaSCard(
        padding: const EdgeInsets.all(SaaSDesign.spacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(SaaSDesign.spacing8),
                  decoration: BoxDecoration(
                    color: SaaSDesign.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                  ),
                  child: Icon(
                    request.type == LeaveType.leave
                        ? Icons.calendar_month 
                        : Icons.access_time,
                    color: SaaSDesign.primaryOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: SaaSDesign.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.displayTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: SaaSDesign.spacing4),
                      Text(
                        request.displayPeriod,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: SaaSDesign.spacing8),
                Flexible(
                  child: SaaSBadge(
                    text: request.statusText,
                    backgroundColor: statusColor.withOpacity(0.1),
                    textColor: statusColor,
                    icon: statusIconData,
                  ),
                ),
              ],
            ),
            
            if (request.comment != null && request.comment!.isNotEmpty) ...[
              const SizedBox(height: SaaSDesign.spacing12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(SaaSDesign.spacing12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: SaaSDesign.spacing8),
                    Expanded(
                      child: Text(
                        request.comment!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: SaaSDesign.spacing12),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: SaaSDesign.spacing4),
                Expanded(
                  child: Text(
                    'Soumis le ${_formatSubmittedDate(request.submittedAt)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                if (request.status == LeaveRequestStatus.pending) ...[
                  const SizedBox(width: SaaSDesign.spacing8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SaaSDesign.spacing8,
                      vertical: SaaSDesign.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: SaaSDesign.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 12,
                          color: SaaSDesign.info,
                        ),
                        const SizedBox(width: SaaSDesign.spacing4),
                        Text(
                          'En cours',
                          style: TextStyle(
                            fontSize: 10,
                            color: SaaSDesign.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatSubmittedDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}