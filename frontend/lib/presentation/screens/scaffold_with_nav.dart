import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({super.key, required this.child});
  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/history')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/history');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Decide Responsive Layout
        final isPhone = constraints.maxWidth < 600;
        final selectedIndex = _calculateSelectedIndex(context);

        if (isPhone) {
          return Scaffold(
            body: child,
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppTheme.primaryAction,
              foregroundColor: AppTheme.darkBackground,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              onPressed: () => context.push('/scanner'),
              child: const Icon(Icons.qr_code_scanner, size: 28),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (idx) => _onItemTapped(idx, context),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Histórico'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
              ],
            ),
          );
        }

        // Tablet/Desktop Layout: Navigation Rail
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: (idx) => _onItemTapped(idx, context),
                labelType: NavigationRailLabelType.all,
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: FloatingActionButton(
                        backgroundColor: AppTheme.primaryAction,
                        foregroundColor: AppTheme.darkBackground,
                        onPressed: () => context.push('/scanner'),
                        child: const Icon(Icons.qr_code_scanner),
                      ),
                    ),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
                  NavigationRailDestination(icon: Icon(Icons.receipt_long), label: Text('Histórico')),
                  NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Ajustes')),
                ],
              ),
              const VerticalDivider(thickness: 1, width: 1, color: Colors.white12),
              Expanded(child: child),
            ],
          ),
        );
      },
    );
  }
}
