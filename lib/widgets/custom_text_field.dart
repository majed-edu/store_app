import 'package:flutter/material.dart';

/// Text field used by the forms. Styling comes from the app theme.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.autofillHints,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.onSubmitted,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      maxLines: obscureText ? 1 : maxLines,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
