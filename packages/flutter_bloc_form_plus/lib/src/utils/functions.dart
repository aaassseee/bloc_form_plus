import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:bloc_form_plus/bloc_form.dart';

ValueChanged<T>? fieldBlocBuilderOnChange<T>({
  required bool isEnabled,
  bool readOnly = false,
  required FocusNode? nextFocusNode,
  required void Function(T value) onChanged,
}) {
  if (isEnabled) {
    return (T value) {
      if (readOnly) return;
      onChanged(value);
      if (nextFocusNode != null) {
        nextFocusNode.requestFocus();
      }
    };
  }
  return null;
}

bool fieldBlocIsEnabled({
  required bool isEnabled,
  bool? enableOnlyWhenFormBlocCanSubmit,
  required FieldBlocState fieldBlocState,
}) {
  return isEnabled
      ? (enableOnlyWhenFormBlocCanSubmit ?? false)
          ? fieldBlocState.formBloc?.state.canSubmit ?? true
          : true
      : false;
}

bool prefersCupertinoFields(BuildContext context) {
  if (kIsWeb) return false;
  return Theme.of(context).platform == TargetPlatform.iOS;
}

Widget widgetBasedOnPlatform({
  required Widget mobile,
  required Widget other,
}) {
  if (kIsWeb) {
    return other;
  } else if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    return mobile;
  } else {
    return other;
  }
}
