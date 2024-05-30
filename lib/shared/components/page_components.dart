import "package:flutter/material.dart";
import "package:wagtrack/shared/background_img.dart";

// Default App Scrollbar
class AppScrollBar extends StatelessWidget {
  final Widget child;
  const AppScrollBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // final TextTheme textStyles = Theme.of(context).textTheme;
    // final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scrollbar(child: child);
  }
}

// Default App Scrollable Page (with background)
class AppScrollablePage extends StatelessWidget {
  final List<Widget> children;
  const AppScrollablePage({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    // final TextTheme textStyles = Theme.of(context).textTheme;
    // final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BackgroundImageWrapper(
      child: AppScrollBar(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children),
          ),
        ),
      ),
    );
  }
}
