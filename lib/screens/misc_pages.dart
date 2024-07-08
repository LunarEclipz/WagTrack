import 'package:flutter/material.dart';

/// Blank page. Used as a placeholder.
class BlankPage extends StatelessWidget {
  const BlankPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BLANK PAGE',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 'Work in Progress' page. Used as a placeholder for when "stuff" is supposed to be here :)
///
/// Comes with the standard white-on-red appBar
class WorkInProgressPage extends StatelessWidget {
  const WorkInProgressPage({super.key});

  // TODO WIP page needs a a funky image or some shit

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WIP',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Full-screen loading page.
class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        body: Center(
            child: CircularProgressIndicator(
      color: colorScheme.primary,
    )));
  }
}
