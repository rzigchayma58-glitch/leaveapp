import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../services/local_notification_service.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const NotificationBadge({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalNotificationService>(
      builder: (context, notificationService, _) {
        final unreadCount = notificationService.unreadCount;
        
        return GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              child,
              if (unreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: EdgeInsets.all(unreadCount > 9 ? 4 : 6),
                    decoration: const BoxDecoration(
                      color: AppConstants.rejectedColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: AppConstants.whiteColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class NotificationIcon extends StatelessWidget {
  final Color? color;
  final double size;
  final VoidCallback? onTap;

  const NotificationIcon({
    Key? key,
    this.color,
    this.size = 24,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationBadge(
      onTap: onTap,
      child: Icon(
        Icons.notifications_outlined,
        color: color,
        size: size,
      ),
    );
  }
}