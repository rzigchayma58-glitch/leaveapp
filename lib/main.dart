import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/leave_viewmodel.dart';
import 'viewmodels/manager_viewmodel.dart';
import 'services/theme_service.dart';
import 'services/local_notification_service.dart';
import 'views/auth/login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local notification service
  final localNotificationService = LocalNotificationService();
  await localNotificationService.initialize();
  
  runApp(MyApp(localNotificationService: localNotificationService));
}

class MyApp extends StatelessWidget {
  final LocalNotificationService localNotificationService;
  
  const MyApp({Key? key, required this.localNotificationService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) {
          final leaveViewModel = LeaveViewModel();
          leaveViewModel.setNotificationService(localNotificationService);
          return leaveViewModel;
        }),
        ChangeNotifierProvider(create: (_) {
          final managerViewModel = ManagerViewModel();
          managerViewModel.setNotificationService(localNotificationService);
          return managerViewModel;
        }),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider.value(value: localNotificationService),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            debugShowCheckedModeBanner: false,
            home: const LoginScreen(),
          );
        },
      ),
    );
  }
}