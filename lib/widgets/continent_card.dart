import 'package:flutter/material.dart';
import 'package:kovidoverlook/models/continent.dart';
import 'package:kovidoverlook/utils/constant.dart';

class ContinentCard extends StatefulWidget {
  const ContinentCard({
    super.key,
    required this.continent,
    this.onTap,
    this.selected = false,
  });

  final Continent continent;
  final Function(Continent continent)? onTap;
  final bool selected;

  @override
  State<ContinentCard> createState() => _ContinentCardState();
}

class _ContinentCardState extends State<ContinentCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.selected;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onTap?.call(widget.continent),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Image.asset(
                    widget.continent.image ?? Constants.defaultImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.6)
                        : theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.7),
                  ),
                  child: Text(
                    widget.continent.name ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
