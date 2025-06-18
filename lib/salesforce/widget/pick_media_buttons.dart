import 'package:flutter/material.dart';

class PickMediaButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const PickMediaButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: InkWell(
            onTap: onTap,
            child: IntrinsicWidth(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 3,
                      offset: const Offset(2, 4),
                    ),
                  ],
                  color: const Color.fromARGB(255, 169, 215, 236),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
