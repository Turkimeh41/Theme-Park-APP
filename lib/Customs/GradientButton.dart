import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  const GradientButton(this.text, {required this.onTap, this.style, this.width, this.height, this.gradient, this.color, super.key, required this.radius});
  final String text;
  final double? width;
  final double? height;
  final double radius;
  final void Function() onTap;
  final TextStyle? style;
  final Color? color;
  final LinearGradient? gradient;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(radius)),
        height: height,
        width: width,
        alignment: Alignment.center,
        child: Text(
          text,
          style: style,
        ),
      ),
    );
  }
}
