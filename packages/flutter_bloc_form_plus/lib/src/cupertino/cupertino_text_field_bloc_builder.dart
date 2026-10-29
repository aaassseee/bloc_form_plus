import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_form_plus/src/fields/simple_field_bloc_builder.dart';
import 'package:flutter_bloc_form_plus/src/suffix_buttons/obscure_suffix_button.dart';
import 'package:flutter_bloc_form_plus/src/theme/bloc_form_theme.dart';
import 'package:flutter_bloc_form_plus/src/theme/field_theme_resolver.dart';
import 'package:flutter_bloc_form_plus/src/utils/accessibility.dart';
import 'package:flutter_bloc_form_plus/src/utils/utils.dart';
import 'package:bloc_form_plus/bloc_form.dart';

/// An iOS-style text field integrated with [TextFieldBloc].
class CupertinoTextFieldBlocBuilder extends StatefulWidget {
  const CupertinoTextFieldBlocBuilder({
    super.key,
    required this.textFieldBloc,
    this.enableOnlyWhenFormBlocCanSubmit = false,
    this.isEnabled = true,
    this.errorBuilder,
    this.padding,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText,
    this.autofillHints,
    this.sensitiveContent,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.autofocus = false,
    this.nextFocusNode,
    this.animateWhenCanShow = true,
    this.focusOnValidationFailed = true,
    this.showObscureToggle = true,
    this.onChanged,
    this.onSubmitted,
    this.scrollPadding = const EdgeInsets.all(20.0),
  });

  final TextFieldBloc<dynamic> textFieldBloc;
  final bool enableOnlyWhenFormBlocCanSubmit;
  final bool isEnabled;
  final FieldBlocErrorBuilder? errorBuilder;
  final EdgeInsetsGeometry? padding;
  final FocusNode? focusNode;
  final InputDecoration decoration;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool? obscureText;
  final Iterable<String>? autofillHints;
  final bool? sensitiveContent;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? nextFocusNode;
  final bool animateWhenCanShow;
  final bool focusOnValidationFailed;
  final bool showObscureToggle;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final EdgeInsets scrollPadding;

  @override
  State<CupertinoTextFieldBlocBuilder> createState() =>
      _CupertinoTextFieldBlocBuilderState();
}

class _CupertinoTextFieldBlocBuilderState
    extends State<CupertinoTextFieldBlocBuilder> {
  late TextEditingController _controller;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.textFieldBloc.state.value);
    _obscureText = widget.obscureText ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _shouldUseSensitiveContent {
    if (widget.sensitiveContent == false) return false;
    if (!_obscureText) return false;
    if (widget.sensitiveContent == true) return true;
    return widget.obscureText == true || widget.showObscureToggle;
  }

  void _syncController(String value) {
    if (_controller.text == value) return;
    _controller
      ..text = value
      ..selection = TextSelection.collapsed(offset: value.length);
  }

  void _onSubmitted(String value) {
    widget.nextFocusNode?.requestFocus();
    widget.onSubmitted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formTheme = FormTheme.of(context);
    final fieldTheme = formTheme.textTheme;
    final resolver = FieldThemeResolver(theme, formTheme, fieldTheme);
    final textStyle = resolver.textStyle;
    final textColor = resolver.textColor;

    return SimpleFieldBlocBuilder(
      singleFieldBloc: widget.textFieldBloc,
      animateWhenCanShow: widget.animateWhenCanShow,
      focusOnValidationFailed: widget.focusOnValidationFailed,
      builder: (_, _) {
        return BlocBuilder<TextFieldBloc, TextFieldBlocState>(
          bloc: widget.textFieldBloc,
          builder: (context, state) {
            final isEnabled = fieldBlocIsEnabled(
              isEnabled: widget.isEnabled,
              enableOnlyWhenFormBlocCanSubmit:
                  widget.enableOnlyWhenFormBlocCanSubmit,
              fieldBlocState: state,
            );

            _syncController(state.value);

            final errorText = Style.getErrorText(
              context: context,
              errorBuilder: widget.errorBuilder,
              fieldBlocState: state,
              fieldBloc: widget.textFieldBloc,
            );

            final placeholder =
                widget.decoration.hintText ?? widget.decoration.labelText ?? '';

            Widget field = CupertinoTextField(
              controller: _controller,
              focusNode: widget.focusNode,
              placeholder: placeholder,
              obscureText: _obscureText,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              enabled: isEnabled,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction ??
                  (widget.nextFocusNode != null
                      ? TextInputAction.next
                      : TextInputAction.done),
              autofillHints: widget.autofillHints,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              scrollPadding: effectiveScrollPadding(context, widget.scrollPadding),
              style: Style.resolveTextStyle(
                isEnabled: isEnabled,
                style: textStyle,
                color: textColor,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: errorText != null
                      ? CupertinoColors.systemRed.resolveFrom(context)
                      : CupertinoColors.separator.resolveFrom(context),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              suffix: widget.showObscureToggle && widget.obscureText == null
                  ? ObscureSuffixButton(
                      singleFieldBloc: widget.textFieldBloc,
                      isEnabled: isEnabled,
                      value: _obscureText,
                      onChanged: (value) => setState(() => _obscureText = value),
                    )
                  : null,
              onChanged: (value) {
                widget.textFieldBloc.changeValue(value);
                widget.onChanged?.call(value);
              },
              onSubmitted: _onSubmitted,
            );

            field = wrapSensitiveContent(
              enabled: _shouldUseSensitiveContent,
              child: field,
            );

            return DefaultFieldBlocBuilderPadding(
              padding: widget.padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  field,
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        errorText,
                        style: TextStyle(
                          color: CupertinoColors.systemRed.resolveFrom(context),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
