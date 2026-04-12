import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'router.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  try {
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.requestPermissions();
    
    // Schedule daily reminder at 9:00 AM
    await notificationService.scheduleDailyReminder(id: 1000);
  } catch (e) {
    debugPrint('Notification service failed to initialize: $e');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart Receipt Tracker',
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
    );
  }
}
