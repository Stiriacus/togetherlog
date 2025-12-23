// TogetherLog - Authentication Screen
// Provides login and signup forms with tab navigation

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
import 'widgets/login_form.dart';
import 'widgets/signup_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.antiqueWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 720),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo/Title
                  const Icon(
                    AppIcons.menuBook,
                    size: AppIconSize.extraLarge,
                    color: AppColors.darkWalnut,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'TogetherLog',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.carbonBlack,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Your shared memories, beautifully preserved',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.softApricot.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppRadius.rSm),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.antiqueWhite,
                        borderRadius: BorderRadius.circular(AppRadius.rSm),
                        boxShadow: AppShadows.elevation1,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: AppColors.darkWalnut,
                      unselectedLabelColor: AppColors.secondaryText,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Log In'),
                        Tab(text: 'Sign Up'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Tab Content
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(top: AppSpacing.lg),
                          child: LoginForm(),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: AppSpacing.lg),
                          child: SignupForm(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
