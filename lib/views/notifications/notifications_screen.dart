import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../models/notification.dart';
import '../../services/local_notification_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'notification_settings_screen.dart';
import 'notification_stats_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  void _loadNotifications() {
    final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
    if (user != null) {
      Provider.of<LocalNotificationService>(context, listen: false)
          .loadNotifications(user.id ?? 'user1');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: ThemeColors.textColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ThemeColors.appBarColor(context),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationStatsScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.analytics_outlined,
              color: ThemeColors.textColor(context),
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.settings,
              color: ThemeColors.textColor(context),
            ),
          ),
          Consumer<LocalNotificationService>(
            builder: (context, notificationService, child) {
              final hasUnread = notificationService.unreadCount > 0;
              return PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: ThemeColors.textColor(context),
                ),
                onSelected: (value) => _handleMenuAction(value, notificationService),
                itemBuilder: (context) => [
                  if (hasUnread)
                    const PopupMenuItem(
                      value: 'mark_all_read',
                      child: Row(
                        children: [
                          Icon(Icons.done_all, color: AppConstants.approvedColor),
                          SizedBox(width: 8),
                          Text('Marquer tout comme lu'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_sweep, color: AppConstants.rejectedColor),
                        SizedBox(width: 8),
                        Text('Supprimer tout'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<LocalNotificationService>(
        builder: (context, notificationService, child) {
          final notifications = notificationService.notifications;

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadNotifications();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(notification, notificationService);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 80,
            color: ThemeColors.secondaryTextColor(context),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: ThemeColors.textColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous serez informé ici de vos demandes\net des nouvelles décisions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: ThemeColors.secondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('Actualiser'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryOrange,
              foregroundColor: AppConstants.whiteColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification, LocalNotificationService notificationService) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppConstants.rejectedColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: AppConstants.whiteColor),
            SizedBox(width: 8),
            Text(
              'Supprimer',
              style: TextStyle(
                color: AppConstants.whiteColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        notificationService.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification supprimée'),
            backgroundColor: AppConstants.rejectedColor,
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            notificationService.markAsRead(notification.id);
          }
          _handleNotificationTap(notification);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ThemeColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead 
                  ? ThemeColors.borderColor(context)
                  : AppConstants.primaryOrange.withOpacity(0.3),
              width: notification.isRead ? 1 : 2,
            ),
            boxShadow: notification.isRead 
                ? null
                : [
                    BoxShadow(
                      color: AppConstants.primaryOrange.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône de type
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Contenu de la notification
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.textColor(context),
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppConstants.primaryOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: ThemeColors.secondaryTextColor(context),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getNotificationColor(notification.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            notification.typeDisplayName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getNotificationColor(notification.type),
                            ),
                          ),
                        ),
                        
                        Text(
                          notification.formattedDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: ThemeColors.secondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.requestApproved:
        return AppConstants.approvedColor;
      case NotificationType.requestRejected:
        return AppConstants.rejectedColor;
      case NotificationType.newDecision:
        return AppConstants.primaryOrange;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.requestApproved:
        return Icons.check_circle;
      case NotificationType.requestRejected:
        return Icons.cancel;
      case NotificationType.newDecision:
        return Icons.announcement;
    }
  }

  void _handleMenuAction(String action, LocalNotificationService notificationService) {
    final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
    if (user == null) return;

    switch (action) {
      case 'mark_all_read':
        notificationService.markAllAsRead(user.id ?? 'user1');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Toutes les notifications marquées comme lues'),
            backgroundColor: AppConstants.approvedColor,
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'delete_all':
        _showDeleteAllDialog(notificationService, user.id ?? 'user1');
        break;
    }
  }

  void _showDeleteAllDialog(LocalNotificationService notificationService, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColors.surfaceColor(context),
        title: Text(
          'Supprimer toutes les notifications',
          style: TextStyle(color: ThemeColors.textColor(context)),
        ),
        content: Text(
          'Cette action est irréversible. Voulez-vous vraiment supprimer toutes vos notifications ?',
          style: TextStyle(color: ThemeColors.textColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: ThemeColors.textColor(context)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              notificationService.deleteAllNotifications(userId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toutes les notifications supprimées'),
                  backgroundColor: AppConstants.rejectedColor,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppConstants.rejectedColor),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // Navigation vers l'écran approprié selon le type de notification
    switch (notification.type) {
      case NotificationType.requestApproved:
      case NotificationType.requestRejected:
        // Naviguer vers l'historique des demandes
        Navigator.pushReplacementNamed(context, '/main');
        break;
      case NotificationType.newDecision:
        // Naviguer vers l'écran des décisions (si existe)
        break;
    }
  }
}