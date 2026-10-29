import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc_form_plus/src/field_bloc_builder.dart';
import 'package:flutter_bloc_form_plus/src/utils/utils.dart';
import 'package:bloc_form_plus/bloc_form.dart';

class Style {
  static const InputDecoration inputDecorationWithoutBorder = InputDecoration(
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
    contentPadding: EdgeInsets.zero,
  );

  static String? getErrorText({
    required BuildContext context,
    required FieldBlocState fieldBlocState,
    required FieldBlocErrorBuilder? errorBuilder,
    required FieldBloc fieldBloc,
  }) {
    if (fieldBlocState.canShowError) {
      if (errorBuilder != null) {
        return errorBuilder(context, fieldBlocState.error!);
      } else {
        return FieldBlocBuilder.defaultErrorBuilder(
          context,
          fieldBlocState.error!,
          fieldBloc,
        );
      }
    } else {
      return null;
    }
  }

  static TextStyle resolveTextStyle({
    required bool isEnabled,
    required TextStyle style,
    required WidgetStateProperty<Color?> color,
  }) {
    return style.copyWith(
      color: color.resolve({
        if (!isEnabled) WidgetState.disabled,
      }),
    );
  }

  static EdgeInsetsGeometry getGroupFieldBlocContentPadding({
    required bool isVisible,
    required InputDecoration decoration,
  }) {
    var contentPadding = (decoration.contentPadding ?? EdgeInsets.zero);

    if (isVisible) {
      return contentPadding.add(const EdgeInsets.only(
        top: 4.0,
        bottom: 4.0,
      ));
    } else {
      return contentPadding.add(const EdgeInsets.only(
        left: 15.0,
      ));
    }
  }

  static InputBorder getInputBorder({
    required InputDecoration decoration,
    required InputDecorationThemeData decorationTheme,
  }) {
    return decoration.border ??
        decorationTheme.border ??
        const UnderlineInputBorder();
  }
}
