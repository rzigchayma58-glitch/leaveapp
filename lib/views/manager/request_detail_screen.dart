import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../models/leave_request.dart';
import '../../models/user.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/manager_viewmodel.dart';

class RequestDetailScreen extends StatefulWidget {
  final LeaveRequest request;

  const RequestDetailScreen({Key? key, required this.request}) : super(key: key);

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final _commentController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(context),
      appBar: AppBar(
        title: const Text(
          'Détail de la demande',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: ThemeColors.appBarColor(context),
        elevation: 0,
      ),
      body: Consumer<ManagerViewModel>(
        builder: (context, managerViewModel, child) {
          final employee = managerViewModel.getEmployeeInfo(widget.request.userId);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmployeeCard(employee),
                const SizedBox(height: 20),
                _buildRequestDetails(),
                const SizedBox(height: 20),
                if (widget.request.status == RequestStatus.pending) ...[
                  _buildCommentSection(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ] else
                  _buildProcessedInfo(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmployeeCard(User? employee) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppConstants.primaryOrange.withOpacity(0.1),
            child: Text(
              employee?.firstName.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryOrange,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee?.fullName ?? 'Employé Inconnu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.textColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${employee?.employeeId ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeColors.secondaryTextColor(context),
                  ),
                ),
                Text(
                  'Département: ${employee?.department ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeColors.secondaryTextColor(context),
                  ),
                ),
                Text(
                  'Email: ${employee?.email ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeColors.secondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              Icon(
                widget.request.type == LeaveType.leave ? Icons.calendar_month : Icons.access_time,
                color: AppConstants.primaryOrange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Détails de la demande',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.textColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Type', widget.request.displayTitle),
          const SizedBox(height: 12),
          _buildDetailRow('Période', widget.request.displayPeriod),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Demande créée',
            _formatDateTime(widget.request.createdAt),
          ),
          if (widget.request.comment != null && widget.request.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetailRow('Commentaire employé', widget.request.comment!),
          ],
          const SizedBox(height: 12),
          _buildDetailRow(
            'Statut',
            widget.request.statusText,
            statusColor: _getStatusColor(widget.request.status),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? statusColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ThemeColors.secondaryTextColor(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: statusColor ?? ThemeColors.textColor(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeColors.borderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commentaire de décision',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeColors.textColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez un commentaire pour justifier votre décision (optionnel)',
            style: TextStyle(
              fontSize: 12,
              color: ThemeColors.secondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Commentaire...',
              hintStyle: TextStyle(
                color: ThemeColors.secondaryTextColor(context),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ThemeColors.borderColor(context),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: ThemeColors.borderColor(context),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppConstants.primaryOrange,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: ThemeColors.inputFillColor(context),
            ),
            style: TextStyle(
              color: ThemeColors.textColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : () => _rejectRequest(),
            icon: const Icon(Icons.cancel, size: 20),
            label: const Text('Refuser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.rejectedColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : () => _approveRequest(),
            icon: const Icon(Icons.check_circle, size: 20),
            label: const Text('Approuver'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.approvedColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessedInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStatusColor(widget.request.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(widget.request.status).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.request.status == RequestStatus.approved 
                    ? Icons.check_circle 
                    : Icons.cancel,
                color: _getStatusColor(widget.request.status),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Demande ${widget.request.status == RequestStatus.approved ? 'approuvée' : 'refusée'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(widget.request.status),
                ),
              ),
            ],
          ),
          if (widget.request.processedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Traitée le ${_formatDateTime(widget.request.processedAt!)}',
              style: TextStyle(
                fontSize: 12,
                color: ThemeColors.secondaryTextColor(context),
              ),
            ),
          ],
          if (widget.request.managerComment != null && widget.request.managerComment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Commentaire du responsable:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ThemeColors.textColor(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.request.managerComment!,
              style: TextStyle(
                fontSize: 14,
                color: ThemeColors.textColor(context),
              ),
            ),
          ],
        ],
      ),
    );
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _approveRequest() async {
    if (_isProcessing) return;

    final shouldApprove = await _showConfirmationDialog(
      title: 'Approuver la demande',
      message: 'Êtes-vous sûr de vouloir approuver cette demande ?',
      confirmText: 'Approuver',
      confirmColor: AppConstants.approvedColor,
    );

    if (shouldApprove == true) {
      setState(() {
        _isProcessing = true;
      });

      final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
      final success = await Provider.of<ManagerViewModel>(context, listen: false)
          .approveRequest(
        requestId: widget.request.id!,
        managerId: user?.id ?? 'manager',
        comment: _commentController.text.trim().isNotEmpty 
            ? _commentController.text.trim() 
            : null,
      );

      setState(() {
        _isProcessing = false;
      });

      if (success) {
        _showSuccessMessage('Demande approuvée avec succès');
        Navigator.pop(context);
      } else {
        _showErrorMessage('Erreur lors de l\'approbation');
      }
    }
  }

  void _rejectRequest() async {
    if (_isProcessing) return;

    final shouldReject = await _showConfirmationDialog(
      title: 'Refuser la demande',
      message: 'Êtes-vous sûr de vouloir refuser cette demande ?',
      confirmText: 'Refuser',
      confirmColor: AppConstants.rejectedColor,
    );

    if (shouldReject == true) {
      setState(() {
        _isProcessing = true;
      });

      final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
      final success = await Provider.of<ManagerViewModel>(context, listen: false)
          .rejectRequest(
        requestId: widget.request.id!,
        managerId: user?.id ?? 'manager',
        comment: _commentController.text.trim().isNotEmpty 
            ? _commentController.text.trim() 
            : null,
      );

      setState(() {
        _isProcessing = false;
      });

      if (success) {
        _showSuccessMessage('Demande refusée');
        Navigator.pop(context);
      } else {
        _showErrorMessage('Erreur lors du refus');
      }
    }
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.approvedColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.rejectedColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}