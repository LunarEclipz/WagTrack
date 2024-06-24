import "package:flutter/material.dart";

// class HeaderMedium extends StatelessWidget {
//   final String title;
//   const HeaderMedium({super.key, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     final TextTheme textStyles = Theme.of(context).textTheme;
//     final ColorScheme colorScheme = Theme.of(context).colorScheme;

//     return Align(
//         alignment: Alignment.centerLeft,
//         child: Text(
//           title,
//           style:
//               textStyles.headlineMedium?.copyWith(color: colorScheme.secondary),
//         ));
//   }
// }

/// Sized Box of height 20
class SizedBoxh20 extends StatelessWidget {
  /// Creates a sized box of height 20.
  const SizedBoxh20({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
    );
  }
}

/// Sized Box of height 10
class SizedBoxh10 extends StatelessWidget {
  /// Creates a sized box of height 10.
  const SizedBoxh10({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 10,
    );
  }
}

/// Inkwell text widget that directs to a given widget when tapped
class AppTextOnTap extends StatelessWidget {
  // Wait this shouldn't need to only be text...?

  /// Widget to build and display when text is tapped.
  final Widget onTap;

  /// Text to be displayed
  final Text text;

  const AppTextOnTap({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => onTap),
        );
      },
      child: text,
    );
  }
}
