import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
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

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return AppConstants.pendingColor;
      case RequestStatus.approved:
        return AppConstants.approvedColor;
      case RequestStatus.rejected:
        return AppConstants.rejectedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          AppConstants.myRequests,
          style: TextStyle(
            color: ThemeColors.textColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ThemeColors.appBarColor(context),
        elevation: 0,
      ),
      body: Consumer<LeaveViewModel>(
        builder: (context, leaveViewModel, child) {
          final requests = leaveViewModel.requests;

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: ThemeColors.secondaryTextColor(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune demande trouvée',
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeColors.secondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: requests.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestCard(request);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(LeaveRequest request) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.displayTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.textColor(context),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(request.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(request.status).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  request.statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(request.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.displayPeriod,
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.secondaryTextColor(context),
            ),
          ),
          if (request.comment != null && request.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              request.comment!,
              style: TextStyle(
                fontSize: 12,
                color: ThemeColors.secondaryTextColor(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (request.attachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.attach_file,
                  size: 16,
                  color: ThemeColors.secondaryTextColor(context),
                ),
                const SizedBox(width: 4),
                Text(
                  '${request.attachments.length} pièce(s) jointe(s)',
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeColors.secondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}