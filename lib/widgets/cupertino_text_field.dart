import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../core/constants/colors.dart';

class PremiumIOSTextField extends StatefulWidget {
  final String placeholder;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
// 👇 1. ADD THIS NEW LINE 👇
  final void Function(String)? onSubmitted;

  const PremiumIOSTextField({
    super.key,
    required this.placeholder,
    this.controller,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    // 👇 2. ADD THIS NEW LINE 👇
    this.onSubmitted,
  });

  @override
  State<PremiumIOSTextField> createState() => _PremiumIOSTextFieldState();
}

class _PremiumIOSTextFieldState extends State<PremiumIOSTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the active color state (Error > Focused > Default)
    final Color activeColor = widget.errorText != null
        ? AppColors.destructive
        : _isFocused
            ? AppColors.aiAccent
            : AppColors.glassBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              decoration: BoxDecoration(
                color: CupertinoColors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: activeColor,
                  width: _isFocused || widget.errorText != null ? 1.2 : 0.5,
                ),
                boxShadow: [
                  if (_isFocused || widget.errorText != null)
                    BoxShadow(
                      color: activeColor.withOpacity(0.15),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                ],
              ),
              child: CupertinoTextField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: _obscureText,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  letterSpacing: -0.3, // SF Pro standard tracking
                ),
                placeholder: widget.placeholder,
                placeholderStyle: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 16,
                  letterSpacing: -0.3,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                
                // Stripping the default Cupertino decoration so our AnimatedContainer handles it
                decoration: const BoxDecoration(color: Color(0x00000000)),
                
                // 🌟 Custom Prefix Icon
                prefix: widget.prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            widget.prefixIcon,
                            key: ValueKey<bool>(_isFocused),
                            color: _isFocused ? AppColors.aiAccent : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                      )
                    : null,
                
                // 👁️ Custom Suffix: Password Visibility Toggle
                suffix: widget.isPassword
                    ? CupertinoButton(
                        padding: const EdgeInsets.only(right: 16.0),
                        minSize: 0,
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: Icon(
                          _obscureText ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
        
        // 🚨 Error Text Display below the field
        if (widget.errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: AppColors.destructive,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ]
      ],
    );
  }
}