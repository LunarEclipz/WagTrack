import 'package:flutter/material.dart';

class BackgroundImageWrapper extends StatefulWidget {
  final Widget child;

  const BackgroundImageWrapper({super.key, required this.child});

  @override
  _BackgroundImageWrapperState createState() => _BackgroundImageWrapperState();
}

class _BackgroundImageWrapperState extends State<BackgroundImageWrapper> {
  late final double _initialScreenHeight;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _initialScreenHeight = MediaQuery.of(context).size.height;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height +
        MediaQuery.of(context).viewInsets.bottom;
    final screenWidth = MediaQuery.of(context).size.height;

    // das is broken :c
    // return Scaffold(
    //   resizeToAvoidBottomInset: false,
    //   body: SingleChildScrollView(
    //     physics: const NeverScrollableScrollPhysics(),
    //     child: Container(
    //       height: screenHeight,
    //       width: screenWidth,
    //       decoration: const BoxDecoration(
    //         image: DecorationImage(
    //           // Needs to be an SVG for higher definition
    //           image: AssetImage('assets/background.png'),
    //           opacity: 0.25,
    //           fit: BoxFit.cover,
    //         ),
    //       ),
    //       child: child,
    //     ),
    //   ),
    // );

    Future.delayed(Duration.zero, () {
      screenHeight = MediaQuery.of(context).size.height +
          MediaQuery.of(context).viewInsets.bottom;
    });

    // debugPrint('$_initialScreenHeight');
    // debugPrint('${MediaQuery.of(context).size.height}');
    return SizedBox(
      child: Container(
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
        child: widget.child,
      ),
    );
    // return Stack(
    //   children: [
    //     Positioned.fill(
    //       child: Container(
    //         decoration: const BoxDecoration(
    //           image: DecorationImage(
    //             image: AssetImage('assets/background.png'),
    //             opacity: 0.25,
    //             fit: BoxFit.cover,
    //           ),
    //         ),
    //       ),
    //     ),
    //     Align(
    //       alignment: Alignment.topCenter,
    //       child: SizedBox(
    //         width: screenWidth,
    //         height: MediaQuery.of(context).size.height,
    //         child: widget.child,
    //       ),
    //     ),
    //   ],
    // );
  }
}
