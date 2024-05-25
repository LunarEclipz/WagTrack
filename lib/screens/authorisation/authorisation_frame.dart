import 'package:flutter/material.dart';
import 'package:wagtrack/screens/authorisation/login_tab.dart';
import 'package:wagtrack/screens/authorisation/register_tab.dart';

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
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
                  height: 121,
                  width: 298,
                  fit: BoxFit.fitWidth,
                ),
                const SizedBox(height: 10),
                Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(style: textStyles.bodyLarge, children: [
                      const TextSpan(
                          text: 'By signing in you are agreeing to our '),
                      TextSpan(
                        text: 'terms ',
                        style: textStyles.bodyLarge
                            ?.copyWith(color: colorScheme.tertiary),
                      ),
                      const TextSpan(text: 'and '),
                      TextSpan(
                        text: 'privacy policy ',
                        style: textStyles.bodyLarge
                            ?.copyWith(color: colorScheme.tertiary),
                      ),
                    ])),
                const SizedBox(height: 10),
                SizedBox(
                  height: screenHeight * 0.6,
                  child: DefaultTabController(
                    length: 2,
                    child: Scaffold(
                      appBar: PreferredSize(
                        preferredSize: const Size.fromHeight(kToolbarHeight),
                        child: SizedBox(
                          height: 50.0,
                          child: TabBar(
                            unselectedLabelColor: Colors.grey,
                            labelColor: colorScheme.tertiary,
                            indicatorColor: colorScheme.tertiary,
                            tabs: const [
                              Tab(child: Text('Login')),
                              Tab(child: Text('Register'))
                            ],
                          ),
                        ),
                      ),
                      body: const TabBarView(
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
