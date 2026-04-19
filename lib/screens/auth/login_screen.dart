import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core Constants
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

// Providers
import '../../providers/mock_auth_provider.dart';

// Widgets
import '../../widgets/cupertino_text_field.dart';
import '../../widgets/primary_action_button.dart';
import '../../widgets/ios_glass_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 🚀 Trigger the Mock Database Login!
      // (If you type 'student' in the email, it routes to Student Dashboard)
      await ref.read(mockAuthServiceProvider).signIn(
        email: email, 
        password: password
      );
      
      // Note: We don't need to manually navigate here! 
      // The AuthWrapper is watching the state and will instantly teleport us 
      // to the correct dashboard as soon as the state changes.
      
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          // 🌌 Background Glow Effect
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 100, spreadRadius: 50),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🎓 App Logo / Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: const Icon(CupertinoIcons.sparkles, size: 64, color: AppColors.aiAccent),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text('Academic AI', style: AppTypography.largeTitle),
                    const SizedBox(height: 8),
                    const Text('Sign in to continue', style: AppTypography.callout),
                    const SizedBox(height: 48),

                    // 🪟 The Glass Login Card
                    IOSGlassCard(
                      child: Column(
                        children: [
                          PremiumIOSTextField(
                            controller: _emailController,
                            placeholder: 'Email (Type "student" or "teacher")',
                            prefixIcon: CupertinoIcons.mail,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          PremiumIOSTextField(
                            controller: _passwordController,
                            placeholder: 'Password',
                            prefixIcon: CupertinoIcons.lock,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleLogin(),
                          ),
                        ],
                      ),
                    ),
                    
                    // ⚠️ Error Message Display
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(_errorMessage, style: const TextStyle(color: AppColors.destructive)),
                    ],
                    
                    const SizedBox(height: 32),

                    // 🚀 The Login Button
                    PrimaryActionButton(
                      text: 'Sign In',
                      icon: CupertinoIcons.arrow_right_circle_fill,
                      isAIAction: false,
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}