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

// Sized Box 20-
class SizedBox20 extends StatelessWidget {
  const SizedBox20({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
    );
  }
}
