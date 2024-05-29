import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final Function(int) setIndex;

  const Home({super.key, required this.setIndex});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void goToScreen(int index) {
    widget.setIndex(index); // call the function using widget
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
