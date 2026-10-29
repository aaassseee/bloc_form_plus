import 'package:flutter/material.dart';
import 'package:bloc_form_web_plus/constants/style.dart';

class GradientElevatedButton extends StatelessWidget {
  const GradientElevatedButton({
    super.key,
    required this.onPressed,
    this.height,
    this.width,
    this.gradient,
    this.child,
    this.borderRadius,
    this.padding,
    this.elevation,
  });

  final VoidCallback? onPressed;
  final double? height;
  final double? width;
  final Gradient? gradient;
  final Widget? child;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final resolvedBorderRadius = borderRadius ?? BorderRadius.circular(2.0);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? mainGradient,
        borderRadius: resolvedBorderRadius,
      ),
      child: Material(
        elevation: elevation ?? 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: resolvedBorderRadius,
        ),
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: resolvedBorderRadius,
          child: Container(
            padding: padding ?? const EdgeInsets.fromLTRB(24, 14, 24, 10),
            child: child,
          ),
        ),
      ),
    );
  }
}
