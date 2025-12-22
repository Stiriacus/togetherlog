// TogetherLog - Navigation Rail
// Implements side navigation per Structural UI Patterns.md

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../theme/app_icons.dart';
import '../widgets/icon_container.dart';

/// Navigation rail destinations
enum NavDestination {
  logs('/logs'),
  settings('/settings');

  const NavDestination(this.route);
  final String route;
}

/// Side navigation rail widget
/// Implements Design Tokens.md navigation rail contract
class AppNavigationRail extends StatefulWidget {
  const AppNavigationRail({
    required this.currentRoute,
    required this.onLogout,
    super.key,
  });

  final String currentRoute;
  final VoidCallback onLogout;

  @override
  State<AppNavigationRail> createState() => _AppNavigationRailState();
}

class _AppNavigationRailState extends State<AppNavigationRail> {
  bool _isExpanded = true;

  /// Get current selected index based on route
  int get _selectedIndex {
    if (widget.currentRoute.startsWith('/logs')) {
      return 0;
    } else if (widget.currentRoute.startsWith('/settings')) {
      return 1;
    }
    return 0; // Default to logs
  }

  /// Toggle expanded/collapsed state
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  /// Handle destination tap
  void _onDestinationTapped(int index, BuildContext context) {
    final destination = NavDestination.values[index];
    context.go(destination.route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _isExpanded ? 240 : 72,
      color: AppColors.antiqueWhite,
      child: Column(
        children: [
          // Toggle button
          SizedBox(
            height: 56,
            child: Align(
              alignment: _isExpanded ? Alignment.centerRight : Alignment.center,
              child: IconButton(
                icon: Icon(
                  _isExpanded ? Icons.menu_open : Icons.menu,
                  color: AppColors.carbonBlack,
                ),
                onPressed: _toggleExpanded,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Navigation destinations
          _buildNavItem(
            icon: AppIcons.book,
            label: 'Logs',
            isActive: _selectedIndex == 0,
            onTap: () => _onDestinationTapped(0, context),
          ),

          const SizedBox(height: AppSpacing.sm),

          _buildNavItem(
            icon: AppIcons.person,
            label: 'Settings',
            isActive: _selectedIndex == 1,
            onTap: () => _onDestinationTapped(1, context),
          ),

          const Spacer(),

          // Logout button (bottom-aligned)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: _buildNavItem(
              icon: AppIcons.logout,
              label: 'Logout',
              isActive: false,
              onTap: widget.onLogout,
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual navigation item
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      hoverColor: AppColors.hoverOverlay,
      child: Container(
        height: 56,
        padding: EdgeInsets.symmetric(
          horizontal: _isExpanded ? AppSpacing.md : AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Icon or icon container
            if (isActive)
              IconContainer(
                icon: icon,
                size: AppIconSize.standard,
                isActive: true,
              )
            else
              Icon(
                icon,
                size: AppIconSize.standard,
                color: AppColors.inactiveIcon,
              ),

            // Label (only in expanded state)
            if (_isExpanded) ...[
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                    color: isActive
                        ? AppColors.carbonBlack
                        : AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
