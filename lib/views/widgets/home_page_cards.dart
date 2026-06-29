import 'package:flutter/material.dart';

class HomePageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String polygonAsset;
  final VoidCallback tap;

  const HomePageCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.polygonAsset,
    required this.tap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 95,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: tap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(10, 12, 60, 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFFCFEAFF),
                        Color(0xFFB8DFFF),
                        Color(0xFFEAF6FF),
                        Colors.white,
                      ],
                      stops: [
                        0.0,
                        0.35,
                        0.7,
                        1.0,
                      ],
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        spreadRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  polygonAsset,
                  width: 50,
                  height: 50,
                ),

                Positioned(
                  bottom: 18,
                  left: 15,
                  child: Icon(
                    icon,
                    size: 24,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}