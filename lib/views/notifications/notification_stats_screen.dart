import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../models/notification.dart';
import '../../services/local_notification_service.dart';

class NotificationStatsScreen extends StatelessWidget {
  const NotificationStatsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Statistiques des notifications',
          style: TextStyle(
            color: ThemeColors.textColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ThemeColors.appBarColor(context),
        elevation: 0,
      ),
      body: Consumer<LocalNotificationService>(
        builder: (context, notificationService, child) {
          final notifications = notificationService.notifications;
          final stats = _calculateStats(notifications);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vue d'ensemble
                _buildOverviewCard(stats, context),
                
                const SizedBox(height: 24),
                
                // Statistiques par type
                _buildTypeStatsSection(stats, context),
                
                const SizedBox(height: 24),
                
                // Tendances
                _buildTrendsSection(notifications, context),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<AppNotification> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = now.subtract(const Duration(days: 7));
    final thisMonth = DateTime(now.year, now.month, 1);

    var todayCount = 0;
    var weekCount = 0;
    var monthCount = 0;
    var unreadCount = 0;
    
    final typeStats = <NotificationType, int>{};
    final dailyStats = <String, int>{};

    for (final notification in notifications) {
      // Compteurs généraux
      if (notification.createdAt.isAfter(today)) todayCount++;
      if (notification.createdAt.isAfter(thisWeek)) weekCount++;
      if (notification.createdAt.isAfter(thisMonth)) monthCount++;
      if (!notification.isRead) unreadCount++;
      
      // Statistiques par type
      typeStats[notification.type] = (typeStats[notification.type] ?? 0) + 1;
      
      // Statistiques quotidiennes (derniers 7 jours)
      final dayKey = '${notification.createdAt.day}/${notification.createdAt.month}';
      if (notification.createdAt.isAfter(thisWeek)) {
        dailyStats[dayKey] = (dailyStats[dayKey] ?? 0) + 1;
      }
    }

    return {
      'total': notifications.length,
      'today': todayCount,
      'week': weekCount,
      'month': monthCount,
      'unread': unreadCount,
      'readRate': notifications.isEmpty ? 0.0 : (notifications.length - unreadCount) / notifications.length,
      'typeStats': typeStats,
      'dailyStats': dailyStats,
    };
  }

  Widget _buildOverviewCard(Map<String, dynamic> stats, BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryOrange,
            AppConstants.primaryOrange.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryOrange.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Vue d\'ensemble',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppConstants.whiteColor,
            ),
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  stats['total'].toString(),
                  Icons.notifications,
                  AppConstants.whiteColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Non lues',
                  stats['unread'].toString(),
                  Icons.mark_email_unread,
                  AppConstants.whiteColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Cette semaine',
                  stats['week'].toString(),
                  Icons.calendar_view_week,
                  AppConstants.whiteColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Taux de lecture',
                  '${(stats['readRate'] * 100).round()}%',
                  Icons.trending_up,
                  AppConstants.whiteColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTypeStatsSection(Map<String, dynamic> stats, BuildContext context) {
    final typeStats = stats['typeStats'] as Map<NotificationType, int>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Répartition par type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeColors.textColor(context),
          ),
        ),
        
        const SizedBox(height: 16),
        
        ...NotificationType.values.map((type) {
          final count = typeStats[type] ?? 0;
          final percentage = stats['total'] > 0 ? (count / stats['total']) * 100 : 0.0;
          
          return _buildTypeStatBar(
            _getTypeDisplayName(type),
            count,
            percentage,
            _getTypeColor(type),
            context,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTypeStatBar(String typeName, int count, double percentage, Color color, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.borderColor(context)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                typeName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ThemeColors.textColor(context),
                ),
              ),
              Text(
                '$count (${percentage.round()}%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsSection(List<AppNotification> notifications, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tendances récentes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: ThemeColors.textColor(context),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ThemeColors.surfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ThemeColors.borderColor(context)),
          ),
          child: Column(
            children: [
              _buildTrendItem(
                'Notification la plus récente',
                notifications.isNotEmpty 
                    ? _formatDate(notifications.first.createdAt)
                    : 'Aucune notification',
                Icons.access_time,
                AppConstants.primaryOrange,
                context,
              ),
              
              const SizedBox(height: 16),
              
              _buildTrendItem(
                'Type le plus fréquent',
                _getMostFrequentType(notifications),
                Icons.trending_up,
                AppConstants.approvedColor,
                context,
              ),
              
              const SizedBox(height: 16),
              
              _buildTrendItem(
                'Moyenne par jour',
                notifications.isEmpty 
                    ? '0' 
                    : '${(notifications.length / 30).toStringAsFixed(1)}',
                Icons.analytics,
                AppConstants.pendingColor,
                context,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendItem(String title, String value, IconData icon, Color color, BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        
        const SizedBox(width: 16),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: ThemeColors.secondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textColor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.requestApproved:
        return 'Demandes approuvées';
      case NotificationType.requestRejected:
        return 'Demandes refusées';
      case NotificationType.newDecision:
        return 'Nouvelles décisions';
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.requestApproved:
        return AppConstants.approvedColor;
      case NotificationType.requestRejected:
        return AppConstants.rejectedColor;
      case NotificationType.newDecision:
        return AppConstants.primaryOrange;
    }
  }

  String _getMostFrequentType(List<AppNotification> notifications) {
    if (notifications.isEmpty) return 'Aucun';
    
    final typeCount = <NotificationType, int>{};
    for (final notification in notifications) {
      typeCount[notification.type] = (typeCount[notification.type] ?? 0) + 1;
    }
    
    var mostFrequent = typeCount.entries.first;
    for (final entry in typeCount.entries) {
      if (entry.value > mostFrequent.value) {
        mostFrequent = entry;
      }
    }
    
    return _getTypeDisplayName(mostFrequent.key);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    }
  }
}