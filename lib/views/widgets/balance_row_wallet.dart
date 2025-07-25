// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class BalanceRow extends StatelessWidget {
  final String leftLabel;
  final String leftValue;
  final Color leftColor;

  final String rightLabel;
  final String rightValue;
  final Color rightColor;

  const BalanceRow({
    super.key,
    required this.leftLabel,
    required this.leftValue,
    required this.leftColor,
    required this.rightLabel,
    required this.rightValue,
    required this.rightColor,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _buildCard(leftLabel, leftValue, leftColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCard(rightLabel, rightValue, rightColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String label, String value, Color valueColor) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
        color: const Color(0xffE6E6E6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
