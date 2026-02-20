import 'package:flutter/material.dart';

class SendButtonSheet extends StatelessWidget {
  final VoidCallback onForward;
  final VoidCallback onSaveImage;
  final VoidCallback onShare;
  final VoidCallback onCancel;

  const SendButtonSheet({
    super.key,
    required this.onForward,
    required this.onSaveImage,
    required this.onShare,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Send',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Action buttons in grid (with fixed height to prevent overflow)
          SizedBox(
            height: 150, // Fixed height to prevent overflow
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling inside grid
              crossAxisCount: 3,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildActionItem(
                  icon: Icons.forward,
                  label: 'Forward',
                  color: Colors.green,
                  onTap: onForward,
                ),
                _buildActionItem(
                  icon: Icons.save_alt,
                  label: 'Save Image',
                  color: Colors.blue,
                  onTap: onSaveImage,
                ),
                _buildActionItem(
                  icon: Icons.share,
                  label: 'Share',
                  color: Colors.orange,
                  onTap: onShare,
                ),
              ],
            ),
          ),
          // Cancel button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}