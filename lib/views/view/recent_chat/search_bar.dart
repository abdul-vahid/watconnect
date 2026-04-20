import 'package:flutter/material.dart';
import 'package:whatsapp/utils/app_color.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: AppColor.navBarIconColor,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search...',
          hintStyle: TextStyle(
            color: AppColor.textoriconColor.withOpacity(0.6),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(10),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColor.backgroundGrey),
            borderRadius: BorderRadius.circular(10),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColor.backgroundGrey),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColor.navBarIconColor,
              width: 1.5,
            ),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.black, size: 20),
              onPressed: () {},
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
        ),
      ),
    );
  }
}