import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({super.key, required this.child});
  final Widget child;

  int _selectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/dashboard'))    return 0;
    if (path.startsWith('/history'))      return 1;
    if (path.startsWith('/shopping-list'))return 2;
    if (path.startsWith('/settings'))     return 3;
    return 0;
  }

  void _onTap(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/dashboard');     break;
      case 1: context.go('/history');       break;
      case 2: context.go('/shopping-list'); break;
      case 3: context.go('/settings');      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPhone    = constraints.maxWidth < 600;
        final selectedIndex = _selectedIndex(context);

        if (isPhone) return _PhoneScaffold(
          child: child,
          selectedIndex: selectedIndex,
          onTap: (i) => _onTap(i, context),
          onScan: () => context.push('/scanner'),
        );

        // ── Tablet / Desktop ──────────────────────────────────────────────
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: (i) => _onTap(i, context),
                labelType: NavigationRailLabelType.all,
                trailing: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spaceLG),
                      child: FloatingActionButton(
                        onPressed: () => context.push('/scanner'),
                        child: const Icon(Icons.qr_code_scanner, size: AppTheme.iconSizeMD),
                      ),
                    ),
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.dashboard_rounded),        label: Text('Dashboard')),
                  NavigationRailDestination(icon: Icon(Icons.history_rounded),           label: Text('Histórico')),
                  NavigationRailDestination(icon: Icon(Icons.shopping_basket_rounded),   label: Text('Lista')),
                  NavigationRailDestination(icon: Icon(Icons.settings_rounded),          label: Text('Ajustes')),
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

// ── Phone Layout ─────────────────────────────────────────────────────────────

class _PhoneScaffold extends StatelessWidget {
  const _PhoneScaffold({
    required this.child,
    required this.selectedIndex,
    required this.onTap,
    required this.onScan,
  });

  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      // Notched FAB centered in the bottom bar
      floatingActionButton: SizedBox(
        width:  AppTheme.fabSize,
        height: AppTheme.fabSize,
        child: FloatingActionButton(
          onPressed: onScan,
          child: const Icon(Icons.qr_code_scanner, size: 26),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        height: 72.0,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            // Left side — 2 items taking equal space
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    selected: selectedIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    icon: Icons.history_rounded,
                    label: 'Histórico',
                    selected: selectedIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ],
              ),
            ),
            // Space for the notched FAB
            const SizedBox(width: AppTheme.fabSize + AppTheme.spaceMD),
            // Right side — 2 items taking equal space
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavItem(
                    icon: Icons.shopping_basket_rounded,
                    label: 'Lista',
                    selected: selectedIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavItem(
                    icon: Icons.settings_rounded,
                    label: 'Ajustes',
                    selected: selectedIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single Nav Item ───────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String   label;
  final bool     selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primaryAction : AppTheme.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceSM,
          vertical: 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: AppTheme.iconSizeNav),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: AppTheme.fontXS,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
