import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class CharacterSelect<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final T value;
  final ValueChanged<T> onChanged;

  final String Function(T item) labelBuilder;
  final Color Function(T item) colorBuilder;

  const CharacterSelect({
    super.key,
    required this.title,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.labelBuilder,
    required this.colorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER (igual filtros)
          InkWell(
            onTap: () {},
            child: Padding(
              padding: AppSpacing.paddingMd,
              child: Text(
                title,
                style: context.textStyles.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// CONTENT
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: items.map((item) {
                final isSelected = item == value;

                return FilterChip(
                  label: Text(
                    labelBuilder(item),
                    style: TextStyle(
                      color: colorBuilder(item),
                    ),
                  ),

                  selected: isSelected,

                  onSelected: (_) => onChanged(item),

                  selectedColor: baseColor.withValues(alpha: 0.85),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}