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
  /// Whether this text field is enabled
  final bool enabled;

  /// Hint text - inside the text field
  final String hintText;

  /// Label Text - above the text field
  final String labelText;

  /// Prefix icon
  final Widget? prefixIcon;

  /// Whether or not to append the default "optional" UI item to the field
  ///
  /// Also sets validator to be empty (disabled) if no other validator is set.
  final bool showOptional;

  /// Whether or not to append the default "required" UI item to the field
  final bool showRequired;

  /// Suffix icon
  final Widget? suffixIcon;

  /// Suffix text to be placed at the back
  final String suffixString;

  /// TextEditingController
  final TextEditingController? controller;

  /// Defaults to `AutovalidateMode.onUserInteraction`.
  ///
  /// `AutovalidateMode.always` or `AutovalidateMode.disabled`
  final AutovalidateMode autovalidateMode;

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
    this.enabled = true,
    this.hintText = '',
    this.labelText = '',
    this.showOptional = false,
    this.showRequired = false,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixString = '',
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
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

    String? hintText = widget.hintText;
    String? labelText = widget.labelText;

    // now change text based on optional/required
    // mutually exclusive, with required taking priority over optional
    //
    // Label text takes precedence over hint text
    if (widget.showRequired) {
      if (widget.labelText.isNotEmpty) {
        labelText = "${widget.labelText} (required)";
      } else if (widget.hintText.isNotEmpty) {
        hintText = "${widget.hintText} (required)";
      }
    } else if (widget.showOptional) {
      if (widget.labelText.isNotEmpty) {
        labelText = "${widget.labelText} (optional)";
      } else if (widget.hintText.isNotEmpty) {
        hintText = "${widget.hintText} (optional)";
      }
    }

    final obscurer = widget.isObscurable
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
        : null;

    // if there is a suffix Icon, it overrides obscurer
    Widget? suffixIcon = widget.suffixIcon ?? obscurer;

    // if there is suffix text, that overrides suffix icon
    // TODO suffix text is currently aligned top
    if (widget.suffixString.isNotEmpty) {
      suffixIcon = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          widget.suffixString,
          style: textStyles.bodyLarge
              ?.copyWith(color: AppTheme.customColors.secondaryText),
        ),
      );
    }

    // set default validator
    final String? Function(dynamic value) defaultValidator;
    if (widget.showOptional) {
      defaultValidator = (value) => InputStringValidators.emptyValidator(value);
    } else {
      defaultValidator = (value) => emptyStringValidator(value);
    }

    return TextFormField(
      enabled: widget.enabled,
      controller: widget.controller,
      obscureText: _obscuretext,
      keyboardType: widget.keyboardType,
      validator: widget.validator ?? defaultValidator,
      autovalidateMode: widget.autovalidateMode,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        // isDense: true,
        hintText: hintText,
        labelText: labelText,
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                child: widget.prefixIcon,
              )
            : null,
        prefixIconColor: AppTheme.customColors.hint,
        prefixStyle: inputTextStyle,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.only(bottom: 0),
        prefixIconConstraints: const BoxConstraints(maxHeight: 24),
        suffixIconConstraints: const BoxConstraints(maxHeight: 24),

        // force there to be no label IF there isn't a label text
        labelStyle: labelText.isEmpty ? const TextStyle(fontSize: 0) : null,
      ),
      style: inputTextStyle,
    );
  }
}

/// Standard large text form field for WagTrack. For large fields like authentication
///
/// Validates fields on user interaction by default.
///
/// Wrap in a `Form` and supply a `GlobalKey` for external form validation.
class AppTextFormFieldLarge extends StatefulWidget {
  /// Hint text
  final String hintText;

  /// Label Text
  final String labelText;

  /// Prefix icon
  final Widget? prefixIcon;

  /// TextEditingController
  final TextEditingController? controller;

  /// Defaults to `AutovalidateMode.onUserInteraction`.
  ///
  /// `AutovalidateMode.always` or `AutovalidateMode.disabled`
  final AutovalidateMode autovalidateMode;

  /// Whether this field is obscurable.
  ///
  /// Obscurable fields are obscured by default.
  final bool isObscurable;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  /// Creates a standard text form field for WagTrack.
  const AppTextFormFieldLarge({
    super.key,
    required this.controller,
    this.hintText = '',
    this.labelText = '',
    this.prefixIcon,
    this.isObscurable = false,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<AppTextFormFieldLarge> createState() => _AppTextFormFieldLargeState();
}

class _AppTextFormFieldLargeState extends State<AppTextFormFieldLarge> {
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
      autovalidateMode: widget.autovalidateMode,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        prefixIcon: widget.prefixIcon,
        prefixIconColor: AppTheme.customColors.hint,
        prefixStyle: inputTextStyle,
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
      style: inputTextStyle,
    );
  }
}

/// Standard text dropdown for WagTrack.
class AppDropdown extends StatefulWidget {
  /// Whether this drop down is enabled
  ///
  /// Works by overriding the "onChanged" function to do nothing and setting the
  /// options list to just the selected option
  final bool enabled;

  /// Initial selected text
  ///
  /// Can be empty.
  final String? selectedText;

  /// Hint widget to be displayed when no initial selection is made
  final Widget? hint;

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
    this.enabled = true,
    this.selectedText,
    this.hint,
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
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: !widget.optionsList.contains(widget.selectedText)
                ? null
                : widget.selectedText,
            icon: const Icon(Icons.expand_more),
            style: textStyles.bodyMedium
                ?.copyWith(color: AppTheme.customColors.secondaryText),
            isExpanded: true,
            onChanged: widget.enabled ? widget.onChanged : (value) {},
            hint: widget.hint,
            items: widget.enabled
                ? widget.optionsList
                    .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList()
                : [
                    // only the selected value is shown if dropdown is disabled!
                    DropdownMenuItem<String>(
                        value: widget.selectedText,
                        child: Text(widget.selectedText ?? "")),
                  ],
          ),
        ),
      ),
    );
  }
}

/// String validator functions matching the format of `String? -> String?`
class InputStringValidators {
  /// validator that doesn't do anything. Use for optional fields
  static String? emptyValidator(String? value) {
    return null;
  }
}
