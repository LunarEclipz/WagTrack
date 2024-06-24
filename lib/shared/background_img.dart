import 'package:flutter/widgets.dart';

class BackgroundImageWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundImageWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight,
      width: screenWidth,
      decoration: const BoxDecoration(
        image: DecorationImage(
          // Needs to be an SVG for higher definition
          image: AssetImage('assets/background.png'),
          opacity: 0.25,
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
