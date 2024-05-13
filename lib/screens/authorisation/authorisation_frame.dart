import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:wagtrack/models/color_models.dart';
import 'package:wagtrack/screens/authorisation/login_tab.dart';
import 'package:wagtrack/screens/authorisation/register_tab.dart';
// import 'package:wagtrack/services/auth.dart';

// import '../mainTemplate.dart';

class LoginPage extends StatefulWidget {
  final Function toggleView;
  const LoginPage({Key? key, required this.toggleView}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final sidePadding = screenWidth * 0.05;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(
            left: sidePadding,
            right: sidePadding,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: <Widget>[
                Image.asset(
                  "assets/wagtrack_v1.png",
                  height: 150,
                  width: 150,
                  fit: BoxFit.fitWidth,
                ),
                // const SizedBox(height: 10),
                // const Text(
                //   'wagtrack',
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     fontSize: 36.0,
                //   ),
                // ),
                const SizedBox(height: 10),
                const Text(
                  'By signing in you are agreeing to our ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  'Terms and privacy policy',
                  style: TextStyle(fontSize: 16, color: Colors.orange),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: screenHeight * 0.6,
                  child: const DefaultTabController(
                    length: 2,
                    child: Scaffold(
                      appBar: PreferredSize(
                        preferredSize: Size.fromHeight(kToolbarHeight),
                        child: SizedBox(
                          height: 50.0,
                          child: TabBar(
                            unselectedLabelColor: Colors.grey,
                            labelColor: Colors.orange,
                            indicatorColor: Colors.orange,
                            tabs: [
                              Tab(child: Text('Login')),
                              Tab(child: Text('Register'))
                            ],
                          ),
                        ),
                      ),
                      body: TabBarView(
                        children: [LoginTab(), RegisterTab()],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
