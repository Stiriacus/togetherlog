// TogetherLog - Authentication Screen
// Provides login and signup forms with tab navigation

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo/Title
                  const Icon(
                    Icons.auto_stories,
                    size: AppIconSize.extraLarge,
                    color: AppColors.darkWalnut,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'TogetherLog',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: AppColors.carbonBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your shared memories, beautifully preserved',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.softApricot.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(AppRadius.button),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.antiqueWhite,
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        boxShadow: AppShadows.elevation1,
                      ),
                      labelColor: AppColors.darkWalnut,
                      unselectedLabelColor: AppColors.secondaryText,
                      tabs: const [
                        Tab(text: 'Log In'),
                        Tab(text: 'Sign Up'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tab Content
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        LoginForm(),
                        SignupForm(),
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
