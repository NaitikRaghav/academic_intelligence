import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core Constants
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

// Providers
import '../../providers/auth_provider.dart';

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
      // 🚀 FIXED: Called the provider correctly without named parameters
      await ref.read(authServiceProvider).signIn(email, password);
      
      // The AuthWrapper automatically handles the navigation!
      
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
                    // 🎓 FIXED: Perfect circle with glowing blue sparkles!
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.glassBorder),
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 30, spreadRadius: 5),
                        ],
                      ),
                      child: const Icon(CupertinoIcons.sparkles, size: 56, color: AppColors.primary),
                    ),
                    const SizedBox(height: 24),
                    
                    const Text('Academic AI', style: AppTypography.largeTitle),
                    const SizedBox(height: 8),
                    const Text('Sign in to your intelligent campus.', style: AppTypography.callout),
                    const SizedBox(height: 48),

                    // 🪟 The Glass Login Card
                    IOSGlassCard(
                      child: Column(
                        children: [
                          PremiumIOSTextField(
                            controller: _emailController,
                            placeholder: 'Email (e.g. teacher@test.com)',
                            prefixIcon: CupertinoIcons.mail,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),
                          
                          // 🚀 FIXED: Native Text Field to safely hide the password
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: CupertinoTextField(
                              controller: _passwordController,
                              placeholder: 'Password',
                              placeholderStyle: const TextStyle(color: AppColors.textSecondary),
                              style: const TextStyle(color: CupertinoColors.white),
                              prefix: const Padding(
                                padding: EdgeInsets.only(left: 12.0),
                                child: Icon(CupertinoIcons.lock, color: AppColors.textSecondary, size: 20),
                              ),
                              obscureText: true, // Hides the password dots!
                              padding: const EdgeInsets.all(16),
                              decoration: null,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _handleLogin(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // ⚠️ Error Message Display
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(_errorMessage, style: const TextStyle(color: CupertinoColors.destructiveRed), textAlign: TextAlign.center),
                    ],
                    
                    const SizedBox(height: 32),

                    // 🚀 The Login Button
                    PrimaryActionButton(
                      text: _isLoading ? 'Authenticating...' : 'Sign In',
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