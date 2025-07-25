// file: dashboard_card_item.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class DashboardCardItem extends StatelessWidget {
  final IconData icon;
  final String countText;
  final String title;
  final VoidCallback onTap;

  const DashboardCardItem({
    super.key,
    required this.icon,
    required this.countText,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4A90E2),
                Color(0xFF50E3C2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            image: const DecorationImage(
              image: AssetImage("assets/images/bg011.jpg"),
              fit: BoxFit.cover,
              // colorFilter: ColorFilter.mode(
              // Colors.black38,
              // BlendMode.darken,
              // ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                countText,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
