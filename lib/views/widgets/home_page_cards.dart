// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class HomePageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String polygonAsset;
  final VoidCallback tap;

  const HomePageCard(
      {Key? key,
      required this.title,
      required this.subtitle,
      required this.icon,
      required this.polygonAsset,
      required this.tap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          InkWell(
            onTap: tap,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 12, 35, 12),
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
                  stops: [0.0, 0.2, 0.4, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: subtitle.split(' / ').first,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              // TextSpan(
                              //   text:
                              //       ' / ${subtitle.split(' / ').last}', // "Total"
                              //   style: const TextStyle(
                              //     fontSize: 14,
                              //     color: Colors.black54,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Polygon Icon
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
                const Positioned(
                  bottom: 18,
                  left: 15,
                  child: Icon(
                    Icons.leaderboard_rounded,
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
