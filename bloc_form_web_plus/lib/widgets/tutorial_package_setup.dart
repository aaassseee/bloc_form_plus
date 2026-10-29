import 'package:material_ui/material_ui.dart';
import 'package:bloc_form_web_plus/widgets/code_card.dart';
import 'package:bloc_form_web_plus/widgets/tutorial_text.dart';

/// Shared tutorial snippets for **bloc_form_plus** / **flutter_bloc_form_plus** 0.3.0.
class TutorialPackageSetup {
  TutorialPackageSetup._();

  static const String importBlock = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc_form_plus/flutter_bloc_form.dart';
''';

  static const String packageNote = '''
**bloc_form 0.3.0** targets **Flutter 3.44.2+** (Dart 3.12).

Add **`flutter_bloc_form_plus`** to `pubspec.yaml`. It depends on **`bloc_form_plus`** (form logic, validators, `FieldBloc.clearError()`, `FormBloc.clearErrors()`, and `FormBlocState.fields`).
''';

  static const String builders030 = '''
**Built-in field builders** include:
* TextFieldBlocBuilder (TypeAhead suggestions, web scroll padding, SensitiveContent)
* AdaptiveTextFieldBlocBuilder / CupertinoTextFieldBlocBuilder
* DropdownFieldBlocBuilder, RadioButtonGroupFieldBlocBuilder, RadioGroupFieldBlocBuilder
* CheckboxFieldBlocBuilder, SwitchFieldBlocBuilder, CheckboxGroupFieldBlocBuilder
* DateTimeFieldBlocBuilder, TimeFieldBlocBuilder
* StepperFormBlocBuilder (respects reduce motion)
''';

  /// Standard dependency + import steps for example tutorials.
  static List<Widget> dependencySteps({String? headerPrefix}) {
    return [
      if (headerPrefix != null) TutorialText.header(headerPrefix),
      TutorialText(packageNote),
      CodeCard.pubspec(),
      TutorialText.sub('Import the library:'),
      CodeCard.main(code: importBlock),
    ];
  }
}
