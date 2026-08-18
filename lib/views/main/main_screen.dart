import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../services/local_notification_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/notification_badge.dart';
import '../home/dashboard_screen.dart';
import '../leave/new_request_screen.dart';
import '../leave/history_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../manager/manager_dashboard_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const NewRequestScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Charger les notifications au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
      if (user != null) {
        Provider.of<LocalNotificationService>(context, listen: false)
            .loadNotifications(user.id ?? 'user1');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(context),
      appBar: _currentIndex == 0 ? _buildAppBar() : null,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: ThemeColors.surfaceColor(context),
          selectedItemColor: AppConstants.primaryOrange,
          unselectedItemColor: ThemeColors.secondaryTextColor(context),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: AppConstants.homeTab,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: AppConstants.newRequestTab,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: AppConstants.historyTab,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: AppConstants.profileTab,
            ),
          ],
        ),
      ),
    );
  }

  AppBar? _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            final user = authViewModel.currentUser;
            if (user != null && user.isManager) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManagerDashboardScreen(),
                      ),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: AppConstants.primaryOrange,
                      size: 20,
                    ),
                  ),
                  tooltip: 'Espace Responsable',
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: NotificationIcon(
            color: AppConstants.whiteColor,
            size: 28,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}