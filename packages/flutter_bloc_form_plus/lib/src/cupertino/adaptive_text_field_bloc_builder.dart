import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc_form_plus/src/cupertino/cupertino_text_field_bloc_builder.dart';
import 'package:flutter_bloc_form_plus/src/text_field_bloc_builder.dart';
import 'package:flutter_bloc_form_plus/src/utils/functions.dart';
import 'package:flutter_bloc_form_plus/src/utils/typedefs.dart';
import 'package:bloc_form_plus/bloc_form.dart';

/// Uses [CupertinoTextFieldBlocBuilder] on iOS and [TextFieldBlocBuilder]
/// everywhere else.
class AdaptiveTextFieldBlocBuilder extends StatelessWidget {
  const AdaptiveTextFieldBlocBuilder({
    super.key,
    required this.textFieldBloc,
    this.enableOnlyWhenFormBlocCanSubmit = false,
    this.isEnabled = true,
    this.errorBuilder,
    this.suffixButton,
    this.padding,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.obscureText,
    this.autofillHints,
    this.sensitiveContent,
    this.maxLines = 1,
    this.readOnly = false,
    this.autofocus = false,
    this.nextFocusNode,
    this.animateWhenCanShow = true,
    this.focusOnValidationFailed = true,
    this.onChanged,
    this.onSubmitted,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.forceCupertino,
    this.forceMaterial,
  });

  final TextFieldBloc<dynamic> textFieldBloc;
  final bool enableOnlyWhenFormBlocCanSubmit;
  final bool isEnabled;
  final FieldBlocErrorBuilder? errorBuilder;
  final SuffixButton? suffixButton;
  final EdgeInsetsGeometry? padding;
  final FocusNode? focusNode;
  final InputDecoration decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool? obscureText;
  final Iterable<String>? autofillHints;
  final bool? sensitiveContent;
  final int? maxLines;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? nextFocusNode;
  final bool animateWhenCanShow;
  final bool focusOnValidationFailed;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final EdgeInsets scrollPadding;
  final bool? forceCupertino;
  final bool? forceMaterial;

  bool _useCupertino(BuildContext context) {
    if (forceMaterial == true) return false;
    if (forceCupertino == true) return true;
    return prefersCupertinoFields(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_useCupertino(context)) {
      return CupertinoTextFieldBlocBuilder(
        textFieldBloc: textFieldBloc,
        enableOnlyWhenFormBlocCanSubmit: enableOnlyWhenFormBlocCanSubmit,
        isEnabled: isEnabled,
        errorBuilder: errorBuilder,
        padding: padding,
        focusNode: focusNode,
        decoration: decoration,
        keyboardType: keyboardType ?? TextInputType.text,
        textInputAction: textInputAction,
        obscureText: obscureText ?? suffixButton == SuffixButton.obscureText,
        autofillHints: autofillHints,
        sensitiveContent: sensitiveContent,
        maxLines: maxLines,
        readOnly: readOnly,
        autofocus: autofocus,
        nextFocusNode: nextFocusNode,
        animateWhenCanShow: animateWhenCanShow,
        focusOnValidationFailed: focusOnValidationFailed,
        showObscureToggle: suffixButton == SuffixButton.obscureText,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        scrollPadding: scrollPadding,
      );
    }

    return TextFieldBlocBuilder(
      textFieldBloc: textFieldBloc,
      enableOnlyWhenFormBlocCanSubmit: enableOnlyWhenFormBlocCanSubmit,
      isEnabled: isEnabled,
      errorBuilder: errorBuilder,
      suffixButton: suffixButton,
      padding: padding,
      focusNode: focusNode,
      decoration: decoration,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      autofillHints: autofillHints,
      sensitiveContent: sensitiveContent,
      maxLines: maxLines,
      readOnly: readOnly,
      autofocus: autofocus,
      nextFocusNode: nextFocusNode,
      animateWhenCanShow: animateWhenCanShow,
      focusOnValidationFailed: focusOnValidationFailed,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      scrollPadding: scrollPadding,
    );
  }
}
