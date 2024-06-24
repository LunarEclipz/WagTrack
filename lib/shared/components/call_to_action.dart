import 'package:flutter/material.dart';

class CallToActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color color;
  final Function onTap;

  const CallToActionButton(
      {super.key,
      required this.icon,
      required this.title,
      required this.text,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {
        onTap;
      },
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(
                icon,
                size: 50,
                color: Colors.white,
              ),
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style:
                          textStyles.bodyLarge?.copyWith(color: Colors.white),
                      softWrap: true,
                    ),
                    Text(
                      text,
                      style:
                          textStyles.bodyMedium?.copyWith(color: Colors.white),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 25,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
