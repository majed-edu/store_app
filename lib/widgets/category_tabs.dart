import 'package:flutter/material.dart';
import 'package:store_app/core/formatters.dart';
import 'package:store_app/theme/app_theme.dart';

/// Horizontal text tabs with an underline on the selected one.
class CategoryTabs extends StatelessWidget {
  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;

          return Semantics(
            button: true,
            selected: isSelected,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.accent : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  Formatters.sentenceCase(category),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.ink : AppColors.inkSoft,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
