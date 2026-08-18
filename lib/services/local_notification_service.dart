import 'package:flutter/foundation.dart';
import '../models/notification.dart';

class LocalNotificationService extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  // Initialize the service
  Future<void> initialize() async {
    // Initialize local notification settings here
    // For now, we'll just use in-memory storage
  }

  // Load notifications for a specific user
  Future<void> loadNotifications(String userId) async {
    // Load existing notifications from storage if any
    _updateUnreadCount();
    notifyListeners();
  }

  // Add a new notification
  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    _updateUnreadCount();
    notifyListeners();
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
      notifyListeners();
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId && !_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _updateUnreadCount();
    notifyListeners();
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    notifyListeners();
  }

  // Delete all notifications for a user
  Future<void> deleteAllNotifications(String userId) async {
    _notifications.removeWhere((n) => n.userId == userId);
    _updateUnreadCount();
    notifyListeners();
  }

  // Show notification when a request is approved
  Future<void> notifyRequestApproved({
    required String userId,
    required String requestType,
    required String dates,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '✅ Demande approuvée',
      message: 'Votre demande de $requestType ($dates) a été approuvée.',
      type: NotificationType.requestApproved,
      isRead: false,
      createdAt: DateTime.now(),
      userId: userId,
    );
    
    await addNotification(notification);
  }

  // Show notification when a request is rejected
  Future<void> notifyRequestRejected({
    required String userId,
    required String requestType,
    required String dates,
    String? reason,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '❌ Demande refusée',
      message: 'Votre demande de $requestType ($dates) a été refusée.' +
          (reason != null ? ' Motif: $reason' : ''),
      type: NotificationType.requestRejected,
      isRead: false,
      createdAt: DateTime.now(),
      userId: userId,
    );
    
    await addNotification(notification);
  }

  // Show notification when a new decision is available
  Future<void> notifyNewDecision({
    required String userId,
    required String title,
    required String message,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '📋 $title',
      message: message,
      type: NotificationType.newDecision,
      isRead: false,
      createdAt: DateTime.now(),
      userId: userId,
    );
    
    await addNotification(notification);
  }

  // Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  // Get notifications by type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get unread notifications
  List<AppNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }
}