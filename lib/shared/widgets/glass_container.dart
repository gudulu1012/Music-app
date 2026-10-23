import 'dart:ui';
import 'package:flutter/material.dart';

/// A genuine glassmorphic container with frosted backdrop blur,
/// fine translucent borders, and optional inner light highlights.
class GlassContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry borderRadius;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final Clip clipBehavior;

  const GlassContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.blur = 16.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.gradient,
    this.boxShadow,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Factory for a prominent glass card with soft highlight.
  factory GlassContainer.card({
    Key? key,
    Widget? child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadiusGeometry? borderRadius,
    double blur = 20.0,
    Color? accent,
  }) {
    return GlassContainer(
      key: key,
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      borderRadius: borderRadius ?? BorderRadius.circular(18),
      blur: blur,
      backgroundColor:
          (accent != null) ? accent.withAlpha(15) : const Color(0x18FFFFFF),
      borderColor:
          (accent != null) ? accent.withAlpha(45) : const Color(0x28FFFFFF),
      borderWidth: 1.0,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withAlpha(25),
          Colors.white.withAlpha(6),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(70),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
      child: child,
    );
  }

  /// Factory for a subtle glass capsule / chip.
  factory GlassContainer.capsule({
    Key? key,
    Widget? child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    bool isSelected = false,
    Color? accent,
  }) {
    final activeColor = accent ?? const Color(0xFFEF4444);
    return GlassContainer(
      key: key,
      width: width,
      height: height,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: margin,
      borderRadius: BorderRadius.circular(30),
      blur: 14.0,
      backgroundColor: isSelected ? activeColor : const Color(0x1EFFFFFF),
      borderColor: isSelected ? activeColor : const Color(0x28FFFFFF),
      borderWidth: 1.0,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0x14FFFFFF),
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? const Color(0x22FFFFFF),
          width: borderWidth,
        ),
        gradient: gradient,
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (blur > 0) {
      content = ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
