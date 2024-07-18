import "package:flutter/material.dart";
import "package:wagtrack/shared/background_img.dart";

// Default App Scrollbar
class AppScrollBar extends StatelessWidget {
  /// Creates an scrollbar using default settings.
  final Widget child;
  const AppScrollBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // final TextTheme textStyles = Theme.of(context).textTheme;
    // final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scrollbar(child: child);
  }
}

/// Default App Scrollable Page (with background)
///
/// Children are aligned to `CrossAxisAlignment.start`
class AppScrollablePage extends StatelessWidget {
  /// List of widgets to display in the page.
  final List<Widget> children;

  /// Creates a page with the default background that is scrollable.
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

///  Scrollable Page (with background, wihtout pading)
///
/// Children are aligned to `CrossAxisAlignment.start`
class AppScrollableNoPaddingPage extends StatelessWidget {
  /// List of widgets to display in the page.
  final List<Widget> children;

  /// Creates a page with the default background that is scrollable.
  const AppScrollableNoPaddingPage({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    // final TextTheme textStyles = Theme.of(context).textTheme;
    // final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BackgroundImageWrapper(
      child: AppScrollBar(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ),
    );
  }
}
