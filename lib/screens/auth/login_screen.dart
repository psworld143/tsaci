import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/admin_layout.dart';
import '../../models/app_error_model.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../manager/manager_home_screen.dart';
import '../supervisor/supervisor_home_screen.dart';
import '../production_manager/production_manager_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    print('=== LOGIN ATTEMPT ===');
    print('Email: ${_emailController.text.trim()}');

    setState(() => _isLoading = true);

    try {
      print('Calling AuthService.login...');
      await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      print('✅ Login successful');

      if (mounted) {
        // Redirect based on user role
        final role = await StorageService.getUserRole();
        print('User role from storage: $role');
        Widget homeScreen;

        final roleLower = role?.toLowerCase();
        print('Role (lowercase): $roleLower');

        switch (roleLower) {
          case 'admin':
            print('→ Routing to AdminLayout');
            homeScreen = const AdminLayout(initialRoute: '/admin/dashboard');
            break;
          case 'production_manager':
            print('→ Routing to ProductionManagerLayout');
            homeScreen = const ProductionManagerLayout(
              initialRoute: '/production/dashboard',
            );
            break;
          case 'inventory_officer':
            print('→ Routing to ManagerHomeScreen (Inventory Officer)');
            homeScreen = const ManagerHomeScreen();
            break;
          case 'qa_officer':
            print('→ Routing to ManagerHomeScreen (QA Officer)');
            homeScreen = const ManagerHomeScreen();
            break;
          case 'worker':
            print('→ Routing to SupervisorHomeScreen (Worker)');
            homeScreen = const SupervisorHomeScreen();
            break;
          // DEPRECATED: Legacy roles
          case 'manager': // redirects to production_manager
            print('⚠️ DEPRECATED ROLE: manager → ProductionManagerLayout');
            homeScreen = const ProductionManagerLayout(
              initialRoute: '/production/dashboard',
            );
            break;
          case 'owner': // redirects to admin
            print('⚠️ DEPRECATED ROLE: owner → AdminLayout');
            homeScreen = const AdminLayout(initialRoute: '/admin/dashboard');
            break;
          case 'supervisor': // redirects to worker
            print('⚠️ DEPRECATED ROLE: supervisor → SupervisorHomeScreen');
            homeScreen = const SupervisorHomeScreen();
            break;
          default:
            print('⚠️ Unknown role, defaulting to ManagerHomeScreen');
            homeScreen = const ManagerHomeScreen();
        }

        print('Navigating to home screen...');
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => homeScreen));
        print('✅ Navigation complete');
      }
    } catch (e) {
      print('❌ LOGIN ERROR: $e');
      print('Error type: ${e.runtimeType}');
      if (mounted) {
        // Parse error and show beautiful error dialog
        final appError = AppError.fromException(e);

        ErrorDialog.show(
          context,
          error: appError,
          onRetry: appError.isRetryable ? _handleLogin : null,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      print('=== LOGIN FLOW COMPLETE ===\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyles.space6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(AppStyles.space6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.factory,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppStyles.space6),

                    // Title
                    const Text(
                      'TSACI System',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppStyles.space2),
                    Text(
                      'Tupi Supreme Activated Carbon Plant',
                      style: AppStyles.bodySm,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppStyles.space8),

                    // Login Card
                    AppCard(
                      padding: const EdgeInsets.all(AppStyles.space6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Welcome Back', style: AppStyles.headingSm),
                          const SizedBox(height: AppStyles.space2),
                          Text('Sign in to continue', style: AppStyles.bodySm),
                          const SizedBox(height: AppStyles.space6),

                          // Email Field
                          AppTextField(
                            label: 'Email',
                            hint: 'Enter your email',
                            controller: _emailController,
                            prefixIcon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppStyles.space4),

                          // Password Field
                          AppTextField(
                            label: 'Password',
                            hint: 'Enter your password',
                            controller: _passwordController,
                            prefixIcon: Icons.lock,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppStyles.space6),

                          // Login Button
                          AppButton(
                            text: 'Login',
                            onPressed: _isLoading ? null : _handleLogin,
                            loading: _isLoading,
                            fullWidth: true,
                            size: ButtonSize.lg,
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
      ),
    );
  }
}
