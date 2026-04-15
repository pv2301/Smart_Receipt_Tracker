import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/screens/scaffold_with_nav.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/scanner_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/shopping_list_screen.dart';
import 'presentation/screens/receipt_detail_screen.dart';
import 'presentation/screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => ScaffoldWithNav(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/shopping-list',
          builder: (context, state) => const ShoppingListScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    // Full-screen routes (no bottom nav)
    GoRoute(
      path: '/scanner',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ScannerScreen(),
    ),
    GoRoute(
      path: '/receipt/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final extra = state.extra;
        final allIds = extra is List<int> ? extra : null;
        return ReceiptDetailScreen(receiptId: id, allIds: allIds);
      },
    ),
  ],
);
