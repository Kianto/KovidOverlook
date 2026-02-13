import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kovidoverlook/models/country.dart';
import 'package:kovidoverlook/utils/data_number_convert.dart';
import 'package:kovidoverlook/widgets/animation_notifier.dart';
import 'package:kovidoverlook/widgets/summary_chart.dart';
import 'package:provider/provider.dart';

class CountryCard extends StatefulWidget {
  const CountryCard({super.key, required this.country, this.onTap});

  final Country country;
  final Function(Country country)? onTap;

  @override
  State<CountryCard> createState() => _CountryCardState();
}

class _CountryCardState extends State<CountryCard>
    with TickerProviderStateMixin {
  late AnimationController _animationCtrler;

  @override
  void initState() {
    super.initState();
    _animationCtrler = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      reverseDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _animationCtrler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<AnimationNotifier>(
      builder: (context, notifier, child) {
        if (notifier.value >= 0.99) {
          _animationCtrler.forward();
        } else if (_animationCtrler.isCompleted) {
          _animationCtrler.reverse();
        }

        return Transform.translate(
          offset: Offset(40 * (1 - notifier.value), 0),
          child: Opacity(
            opacity: notifier.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onTap?.call(widget.country),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow
                        .withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: _buildBody(theme, notifier),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(ThemeData theme, AnimationNotifier notifier) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: FadeInImage.assetNetwork(
            image: widget.country.flag,
            placeholder: 'assets/images/kovid_overlook.png',
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            imageErrorBuilder: (_, __, ___) => Image.asset(
              'assets/images/kovid_overlook.png',
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.country.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildChip(theme, widget.country.confirmed,
                      Colors.blue.shade600, notifier,
                      delay: 0.35),
                  const SizedBox(width: 6),
                  _buildChip(theme, widget.country.recovered,
                      Colors.green.shade600, notifier,
                      delay: 0.2),
                  const SizedBox(width: 6),
                  _buildChip(theme, widget.country.deaths, Colors.red.shade600,
                      notifier),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 44,
          height: 44,
          child: SummaryChart(
            report: widget.country,
            size: 22,
            showPercent: false,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
    ThemeData theme,
    int number,
    Color color,
    AnimationNotifier notifier, {
    double delay = 0,
  }) {
    Animation animation = CurvedAnimation(
      parent: _animationCtrler,
      curve: Interval(delay, 1, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(math.pi / 2 * (1.0 - animation.value)),
        alignment: Alignment.center,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          DataNumberConverter.convert(number),
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
