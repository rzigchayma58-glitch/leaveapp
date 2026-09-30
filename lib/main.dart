import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/leave_viewmodel.dart';
import 'viewmodels/manager_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'services/theme_service.dart';
import 'services/notification_service.dart';
import 'views/auth/login/login_screen.dart';
import 'views/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => LeaveViewModel()),
        ChangeNotifierProvider(create: (_) => ManagerViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            debugShowCheckedModeBanner: false,
            home: Consumer<AuthViewModel>(
              builder: (context, authViewModel, child) {
                if (authViewModel.isLoggedIn) {
                  return const MainScreen();
                }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}