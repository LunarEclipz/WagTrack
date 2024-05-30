import 'package:flutter/widgets.dart';

class BackgroundImageWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundImageWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight,
      decoration: const BoxDecoration(
        image: DecorationImage(
          // Needs to be an SVG for higher definition
          image: AssetImage('assets/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
