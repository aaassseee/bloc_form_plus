import 'package:material_ui/material_ui.dart';
import 'package:bloc_form_web_plus/examples/whats_new_form.dart';
import 'package:bloc_form_web_plus/widgets/widgets.dart';

class WhatsNewExamplePage extends StatelessWidget {
  const WhatsNewExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'What\'s New 0.3.0',
      demo: const DeviceScreen(app: WhatsNewForm()),
      code: const CodeScreen(codePath: 'lib/examples/whats_new_form.dart'),
      tutorial: TutorialScreen(
        children: [
          ...TutorialPackageSetup.dependencySteps(
            headerPrefix: '# Setup (bloc_form 0.3.0)',
          ),
          const TutorialText('''
This example showcases **bloc_form 0.3.0** features aligned with **Flutter 3.44.2**:

* **AdaptiveTextFieldBlocBuilder** / **CupertinoTextFieldBlocBuilder**
* **SensitiveContent** for obscured password fields
* **RadioGroupFieldBlocBuilder** (`RadioGroup` API)
* **TypeAhead** suggestions with improved mobile-web keyboard handling
* **FormBloc.clearErrors()** and **FormBlocState.fields**
* Accessibility: reduced motion, semantic progress, web scroll padding (via library defaults)
'''),
          CodeCard.main(
            nestedPath: 'WhatsNewFormBloc',
            code: '''
final email = TextFieldBloc(validators: [FieldBlocValidators.required]);

Future<void> validateAllFields() async {
  for (final field in state.fields) {
    await field.validate();
  }
}

// Clears errors without resetting values:
formBloc.clearErrors();
''',
          ),
          CodeCard.main(
            nestedPath: 'WhatsNewForm > build',
            code: '''
AdaptiveTextFieldBlocBuilder(
  textFieldBloc: formBloc.password,
  sensitiveContent: true,
  forceCupertino: true,
  suffixButton: SuffixButton.obscureText,
  decoration: InputDecoration(labelText: 'Password'),
),

RadioGroupFieldBlocBuilder<String>(
  selectFieldBloc: formBloc.framework,
  direction: RadioDirection.right,
  itemBuilder: (context, item) => FieldItem(child: Text(item)),
),
''',
          ),
        ],
      ),
    );
  }
}
