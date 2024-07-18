import 'package:flutter/material.dart';

/// Standard large primary color app button with rounded corners.
/// Default size is 300 x 40, with 5 px rounded corners.
///
/// If `padding` is set, `width` and `height` restrictions are are disabled.
///
/// Label color is white, text is font size 18.
class AppButtonLarge extends StatefulWidget {
  /// Label text of button
  final String? text;

  /// Widget on the left side of text
  final Widget? buttonTextPrefix;

  /// Widget on the right side of text
  final Widget? buttonTextSuffix;

  final double? width;
  final double? height;

  final EdgeInsetsGeometry padding;

  /// function to be called when the button is tapped
  final void Function()? onTap;

  const AppButtonLarge({
    super.key,
    this.text,
    this.buttonTextPrefix,
    this.buttonTextSuffix,
    this.width = 300,
    this.height = 40,
    this.padding = EdgeInsets.zero,
    this.onTap,
  });

  @override
  _AppButtonLargeState createState() => _AppButtonLargeState();
}

class _AppButtonLargeState extends State<AppButtonLarge> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textStyles = Theme.of(context).textTheme;

    // set up button label
    final List<Widget> label = [];
    if (widget.buttonTextPrefix != null) {
      label.add(widget.buttonTextPrefix!);
    }

    label.add(Text(
      widget.text ?? "",

      // set to the bold font!
      style: textStyles.bodyLarge!.copyWith(fontSize: 18, color: Colors.white),
      // style: const TextStyle(fontSize: 18, color: Colors.white),
    ));

    if (widget.buttonTextSuffix != null) {
      label.add(widget.buttonTextSuffix!);
    }

    // set width and height
    final double? width, height;
    if (widget.padding != EdgeInsets.zero) {
      width = null;
      height = null;
    } else {
      width = widget.width;
      height = widget.height;
    }

    return Material(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: widget.onTap,
        // splashColor: Colors.black.withOpacity(0.4),
        child: Container(
          padding: widget.padding,
          width: width,
          height: height,
          decoration: const BoxDecoration(
              // color: colorScheme.primary,
              // borderRadius: BorderRadius.circular(5),
              ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: label,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small pressable icon
class AppIconButtonSmall extends StatefulWidget {
  /// Icon inside button
  final Icon icon;

  /// function to be called when the button is pressed
  final void Function()? onPressed;

  const AppIconButtonSmall({
    super.key,
    required this.icon,
    this.onPressed,
  });

  @override
  _AppIconButtonSmallState createState() => _AppIconButtonSmallState();
}

class _AppIconButtonSmallState extends State<AppIconButtonSmall> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // final TextTheme textStyles = Theme.of(context).textTheme;

    return IconButton(
      icon: widget.icon,
      onPressed: widget.onPressed,
      color: colorScheme.primary,
      padding: EdgeInsets.zero,
    );
  }
}
