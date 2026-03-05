import 'package:flutter/material.dart';
class GradientBouton extends StatelessWidget {
  final String text;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const GradientBouton({
    required this.text,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2),
        margin: EdgeInsets.symmetric(horizontal: 2, ),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.green, size: 16),
              SizedBox(width: 6),
              Text(text, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}