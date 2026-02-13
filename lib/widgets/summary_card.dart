import 'package:flutter/material.dart';
import 'package:kovidoverlook/utils/data_number_convert.dart';
import 'package:kovidoverlook/widgets/animation_notifier.dart';
import 'package:provider/provider.dart';

class SummaryCard extends StatefulWidget {
  const SummaryCard({
    super.key,
    this.color,
    required this.title,
    this.number = 0,
  });

  final Color? color;
  final String title;
  final int number;

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<AnimationNotifier>(
      builder: (context, notifier, child) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: widget.color?.withValues(alpha: 0.92),
        child: _buildBody(theme, notifier),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, AnimationNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedBuilder(
            builder: (context, _) => Text(
              DataNumberConverter.convert(widget.number * notifier.value),
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            animation: notifier,
          ),
        ],
      ),
    );
  }
}
