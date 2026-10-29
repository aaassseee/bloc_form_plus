import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_form_plus/src/fields/simple_field_bloc_builder.dart';
import 'package:flutter_bloc_form_plus/src/theme/bloc_form_theme.dart';
import 'package:flutter_bloc_form_plus/src/theme/field_theme_resolver.dart';
import 'package:flutter_bloc_form_plus/src/utils/utils.dart';
import 'package:bloc_form_plus/bloc_form.dart';

/// An iOS-style switch integrated with [BooleanFieldBloc].
class CupertinoSwitchFieldBlocBuilder extends StatelessWidget {
  const CupertinoSwitchFieldBlocBuilder({
    super.key,
    required this.booleanFieldBloc,
    required this.body,
    this.enableOnlyWhenFormBlocCanSubmit = false,
    this.isEnabled = true,
    this.errorBuilder,
    this.padding,
    this.alignment = AlignmentDirectional.centerStart,
    this.nextFocusNode,
    this.controlAffinity = FieldBlocBuilderControlAffinity.leading,
    this.animateWhenCanShow = true,
    this.textStyle,
    this.textColor,
    this.activeTrackColor,
  });

  final BooleanFieldBloc booleanFieldBloc;
  final Widget body;
  final bool enableOnlyWhenFormBlocCanSubmit;
  final bool isEnabled;
  final FieldBlocErrorBuilder? errorBuilder;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;
  final FocusNode? nextFocusNode;
  final FieldBlocBuilderControlAffinity controlAffinity;
  final bool animateWhenCanShow;
  final TextStyle? textStyle;
  final WidgetStateProperty<Color?>? textColor;
  final Color? activeTrackColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formTheme = FormTheme.of(context);
    final fieldTheme = formTheme.switchTheme;
    final resolver = FieldThemeResolver(theme, formTheme, fieldTheme);

    return SimpleFieldBlocBuilder(
      singleFieldBloc: booleanFieldBloc,
      animateWhenCanShow: animateWhenCanShow,
      builder: (_, _) {
        return BlocBuilder<BooleanFieldBloc, BooleanFieldBlocState>(
          bloc: booleanFieldBloc,
          builder: (context, state) {
            final fieldEnabled = fieldBlocIsEnabled(
              isEnabled: isEnabled,
              enableOnlyWhenFormBlocCanSubmit:
                  enableOnlyWhenFormBlocCanSubmit,
              fieldBlocState: state,
            );

            final errorText = Style.getErrorText(
              context: context,
              errorBuilder: errorBuilder,
              fieldBlocState: state,
              fieldBloc: booleanFieldBloc,
            );

            final switchWidget = CupertinoSwitch(
              value: state.value,
              activeTrackColor: activeTrackColor,
              onChanged: fieldBlocBuilderOnChange<bool>(
                isEnabled: fieldEnabled,
                nextFocusNode: nextFocusNode,
                onChanged: booleanFieldBloc.changeValue,
              ),
            );

            final label = DefaultTextStyle(
              style: Style.resolveTextStyle(
                isEnabled: fieldEnabled,
                style: textStyle ?? resolver.textStyle,
                color: textColor ?? resolver.textColor,
              ),
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                alignment: alignment,
                child: body,
              ),
            );

            final rowChildren = controlAffinity ==
                    FieldBlocBuilderControlAffinity.trailing
                ? <Widget>[Expanded(child: label), switchWidget]
                : <Widget>[switchWidget, const SizedBox(width: 12), Expanded(child: label)];

            return DefaultFieldBlocBuilderPadding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: rowChildren),
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
