import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FilterChips extends StatelessWidget {
  final int selectedFilterId;
  final bool isTagFilterActive;
  final int selectedTagsCount;
  final Function(int) onFilterSelected;
  final VoidCallback onFilterTagsPressed;

  const FilterChips({
    super.key,
    required this.selectedFilterId,
    required this.isTagFilterActive,
    required this.selectedTagsCount,
    required this.onFilterSelected,
    required this.onFilterTagsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> filters = ["All", "Unread"];

    return SizedBox(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...List.generate(filters.length, (index) {
              final isSelected = selectedFilterId == index && !isTagFilterActive;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InkWell(
                  onTap: () => onFilterSelected(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      filters[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: onFilterTagsPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isTagFilterActive ? Colors.blue : Colors.grey,
                      width: 1.2,
                    ),
                    color: isTagFilterActive ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FontAwesomeIcons.filter, color: Colors.grey, size: 16),
                      const SizedBox(width: 6),
                      const Text(
                        'Filter',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      if (selectedTagsCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                          child: Text(
                            selectedTagsCount.toString(),
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}