import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onPressed;
  final bool isActive;
  final double size;

  const CustomButton({
    Key? key,
    required this.icon,
    this.color,
    required this.onPressed,
    required this.isActive,
    this.size = 58,
  }) : super(key: key);

  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 248, 218, 190).withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            width: 2,
            color: isActive ? Color(0xffE77917) : Colors.transparent, // Use your primaryColor here if needed
          ),
        ),
        child: Icon(
          icon,
          color: Color(0xffE77917), // Replace with primaryColor if needed
          size: 24,
        ),
      ),
    );
  }
}
