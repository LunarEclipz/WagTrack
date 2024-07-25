import 'package:flutter/material.dart';

/// A text section widget with a `header` and `body`
class TextSection extends StatelessWidget {
  final String header;
  final String body;

  const TextSection({
    super.key,
    required this.header,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: textStyles.bodyLarge!.copyWith(color: colorScheme.secondary),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: textStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
