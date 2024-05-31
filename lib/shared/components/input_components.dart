import 'package:flutter/material.dart';
import 'package:wagtrack/shared/themes.dart';

/// Default switch for WagTrack
class AppSwitch extends StatelessWidget {
  /// Current value of the switch.
  final bool value;

  /// Function that determines what the switch does.
  final ValueChanged<bool>? onChanged;

  /// Creates a switch.
  const AppSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Manually sized to remove unnecessary switch padding
    // Sized against bodyLarge
    return SizedBox(
      width: 60,
      height: 27,
      child: Transform.scale(
        scale: 0.8,
        child: Switch(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            activeColor: Colors.white,
            activeTrackColor: colorScheme.primary,
            value: value,
            onChanged: onChanged),
      ),
    );
  }
}

/// Standard text form field for WagTrack.
///
/// Validates fields on user interaction by default.
///
/// Wrap in a `Form` and supply a `GlobalKey` for external form validation.
class AppTextFormField extends StatefulWidget {
  /// Hint text
  final String hintText;

  /// Label Text
  final String labelText;

  /// Prefix icon
  final Icon? prefixIcon;

  /// Prefix text
  final String? prefixText;

  /// TextEditingController
  final TextEditingController? controller;

  /// Whether this field is obscurable.
  ///
  /// Obscurable fields are obscured by default.
  final bool isObscurable;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  /// Creates a standard text form field for WagTrack.
  const AppTextFormField({
    super.key,
    required this.controller,
    this.hintText = '',
    this.labelText = '',
    this.prefixIcon,
    this.prefixText,
    this.isObscurable = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late bool _obscuretext;

  @override
  void initState() {
    super.initState();
    _obscuretext = widget.isObscurable;
  }

  String? emptyStringValidator(String? value) {
    if (value == null || value.isEmpty) {
      String fieldName =
          widget.hintText.isEmpty ? widget.labelText : widget.hintText;
      // stupid silent 'y's are going to be an issue
      if (RegExp(r'^[aeiouAEIOU]+').hasMatch(fieldName)) {
        // starts with vowel
        return 'Please enter an ${fieldName.toLowerCase()}';
      }
      // does not start with vowel
      return 'Please enter a ${fieldName.toLowerCase()}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;

    final TextStyle? inputTextStyle = textStyles.bodyLarge
        ?.copyWith(color: AppTheme.customColors.secondaryText);

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscuretext,
      keyboardType: widget.keyboardType,
      validator: widget.validator ?? (value) => emptyStringValidator(value),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          prefixIcon: widget.prefixIcon,
          prefixIconColor: AppTheme.customColors.hint,
          prefixText: widget.prefixText,
          prefixStyle: inputTextStyle,
          alignLabelWithHint: true,
          suffixIcon: widget.isObscurable
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _obscuretext = !_obscuretext;
                    });
                  },
                  icon: Icon(
                    _obscuretext ? Icons.visibility_off : Icons.visibility,
                  ),
                )
              : null,
          contentPadding: EdgeInsets.zero),
      style: inputTextStyle,
    );
  }
}

/// Standard text dropdown for WagTrack.
class AppDropdown extends StatefulWidget {
  /// Hint text
  final String selectedText;

  /// Dropdown options
  final List<String> optionsList;

  /// Unary function that takes in value - used to update some data structure.
  /// Called when user selects an item.
  ///
  /// For instance:
  /// ```
  /// onChanged: (String? value) {
  ///   setState(() {
  ///     toUpdate = value!;
  ///   });
  /// },
  /// ```
  final void Function(String?)? onChanged;

  /// Creates a standard text dropdown for WagTrack.
  const AppDropdown({
    super.key,
    required this.optionsList,
    required this.selectedText,
    this.onChanged,
  });

  @override
  State<AppDropdown> createState() => _AppDropdownState();
}

class _AppDropdownState extends State<AppDropdown> {
  // @override
  // void initState() {
  //   super.initState();
  //   // Set the initial selected item
  //   _selectedItem = widget.selectedText;
  // }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;

    return InputDecorator(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: AppTheme.customColors.hint, width: 4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: AppTheme.customColors.hint, width: 4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: AppTheme.customColors.hint, width: 4),
        ),
      ),
      child: SizedBox(
        height: 20,
        child: DropdownButton<String>(
          value: widget.selectedText,
          icon: const Icon(Icons.expand_more),
          style: textStyles.bodyMedium
              ?.copyWith(color: AppTheme.customColors.secondaryText),
          isExpanded: true,
          onChanged: widget.onChanged,
          items:
              widget.optionsList.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
