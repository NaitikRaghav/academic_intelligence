import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart'; // Required for HapticFeedback
import '../core/constants/colors.dart';

class PrimaryActionButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isAIAction; // Set to true for AI generation buttons
  final IconData? icon;

  const PrimaryActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isAIAction = false,
    this.icon,
  });

  @override
  State<PrimaryActionButton> createState() => _PrimaryActionButtonState();
}

class _PrimaryActionButtonState extends State<PrimaryActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 🧲 Physics-based animation controller for the native "bounce"
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      HapticFeedback.lightImpact(); // Native iOS subtle vibration
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isLoading && widget.onPressed != null) {
      _animationController.reverse();
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;
    
    // Determine colors based on state and AI mode
    final Color buttonColor = isDisabled
        ? AppColors.surfaceElevated
        : widget.isAIAction
            ? AppColors.aiAccent
            : AppColors.primary;

    final Color textColor = isDisabled
        ? AppColors.textTertiary
        : CupertinoColors.white;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56.0, // Apple's standard large button height
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(16.0), // Squircle radius
            boxShadow: [
              // ✨ Add a glow if it's an AI action and not disabled
              if (widget.isAIAction && !isDisabled && !widget.isLoading)
                BoxShadow(
                  color: AppColors.aiAccent.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: -2,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: textColor, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17, // Native iOS body text size
                          fontWeight: FontWeight.w600, // Semibold for action buttons
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}