import 'package:flutter/material.dart';
import '../../core/theme/bondbox_theme.dart';

class BondGradientBackground extends StatelessWidget {
  final Widget child;
  final LinearGradient gradient;

  const BondGradientBackground({
    super.key,
    required this.child,
    this.gradient = BondBoxTheme.primaryGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}

class BondButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;

  const BondButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).colorScheme.primary,
        foregroundColor: textColor ?? Colors.white,
      ),
      child: Text(text),
    );
  }
}

class BondTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final IconData? prefixIcon;

  const BondTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: BondBoxTheme.softPurple) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}

class BondAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Border? border;

  const BondAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('assets/')) {
        imageProvider = AssetImage(imageUrl!);
      } else {
        imageProvider = NetworkImage(imageUrl!);
      }
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: BondBoxColors.lavender,
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? Icon(Icons.person, size: radius, color: BondBoxColors.softPurple)
            : null,
      ),
    );
  }
}
