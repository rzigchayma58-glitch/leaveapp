import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../viewmodels/leave_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../home/dashboard_screen.dart';
import '../leave/new_request_screen.dart';
import '../leave/history_screen.dart';
import '../profile/profile_screen.dart';

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
    // Initialiser les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leaveViewModel = Provider.of<LeaveViewModel>(context, listen: false);
      leaveViewModel.initialize();
      Provider.of<ProfileViewModel>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(context),
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
}