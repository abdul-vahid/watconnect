import 'package:flutter/material.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/views/view/profile_view.dart';

class ProfileHeaderClip extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onEditTap;

  const ProfileHeaderClip({
    super.key,
    required this.imageUrl,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double headerHeight = size.height * 0.16;
    final double profileSize = size.width * 0.28; // responsive image size

    return ClipPath(
      clipper: CustomShape(),
      child: Container(
        height: headerHeight,
        width: size.width,
        color: Color(0xffE6F4EA),
        child: Padding(
          padding: EdgeInsets.only(
            left: size.width * 0.06,
            top: size.height * 0.015,
          ),
          child: Stack(
            children: [
              Container(
                height: profileSize,
                width: profileSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(profileSize / 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(profileSize / 2),
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          '$imageUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                          key: ValueKey(imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Image.asset("assets/images/profile-image.png"),
                          loadingBuilder: (_, child, loading) => loading == null
                              ? child
                              : const CircularProgressIndicator(),
                        )
                      : Image.asset("assets/images/profile-image.png"),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 30,
                  width: 30,
                  // height: profileSize * 0.33,
                  // width: profileSize * 0.33,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 3,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    color: AppColor.navBarIconColor,
                  ),
                  child: InkWell(
                    onTap: onEditTap,
                    child:
                        const Icon(Icons.edit, color: Colors.black, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
