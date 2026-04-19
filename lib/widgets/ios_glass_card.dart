import 'dart:ui';
import 'package:flutter/cupertino.dart';

class IOSGlassCard extends StatelessWidget {
  final Widget child;
  final double padding;
  final double borderRadius;
  final double blurSigma;
  final double opacity;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const IOSGlassCard({
    super.key,
    required this.child,
    this.padding = 24.0,
    this.borderRadius = 28.0, // iOS uses larger 28-32 radius for main cards
    this.blurSigma = 50.0,    // Extreme blur for true frosted glass
    this.opacity = 0.08,      // Barely there base opacity
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            // 🌟 The Magic: Multi-stop gradient mimicking diagonal light
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CupertinoColors.white.withOpacity(opacity + 0.08), // Bright top-left edge
                CupertinoColors.white.withOpacity(opacity),
                CupertinoColors.white.withOpacity(opacity - 0.04), // Dark fading bottom-right
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            // The outer micro-border
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.12),
              width: 0.5,
            ),
            boxShadow: [
              // 🕳️ Outer drop shadow for physical depth against the pure black background
              BoxShadow(
                color: CupertinoColors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              // ✨ Specular Highlight: A tight, bright shadow simulating a top-edge light catch
              BoxShadow(
                color: CupertinoColors.white.withOpacity(0.1),
                blurRadius: 0,
                spreadRadius: 1,
                offset: const Offset(0, 1.5), 
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    // Make it interactive if an onTap function is provided
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}