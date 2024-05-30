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
/// Autovalidates for empty field by default.
class AppTextFormField extends StatefulWidget {
  /// Hint text
  final String hintText;

  /// Prefix icon
  final Icon? prefixIcon;

  /// TextEditingController
  final TextEditingController? controller;

  /// Whether this field is obscurable
  final bool isObscurable;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AppTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.isObscurable = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  bool _obscuretext = false;

  String? emptyStringValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a ${widget.hintText}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscuretext,
      keyboardType: widget.keyboardType,
      validator: widget.validator ?? (value) => emptyStringValidator(value),
      autovalidateMode: AutovalidateMode.always,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        prefixIconColor: AppTheme.customColors.hint,
        // border: const OutlineInputBorder(),
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
      ),
      style: textStyles.bodyLarge
          ?.copyWith(color: AppTheme.customColors.secondaryText),
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
