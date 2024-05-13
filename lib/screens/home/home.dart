import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/services/auth.dart';

class Home extends StatefulWidget {
  final Function(int) setIndex;

  const Home({Key? key, required this.setIndex}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void goToScreen(int index) {
    widget.setIndex(index); // call the function using widget
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
