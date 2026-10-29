import 'package:material_ui/material_ui.dart';
import 'package:bloc_form_web_plus/examples/all_fields_form.dart';
import 'package:bloc_form_web_plus/widgets/widgets.dart';

class AllFieldsExamplePage extends StatelessWidget {
  const AllFieldsExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Built-in Widgets',
      demo: const DeviceScreen(app: AllFieldsForm()),
      code: const CodeScreen(codePath: 'lib/examples/all_fields_form.dart'),
      tutorial: TutorialScreen(
        children: [
          ...TutorialPackageSetup.dependencySteps(
            headerPrefix: '# Setup (bloc_form 0.3.0)',
          ),
          TutorialText(TutorialPackageSetup.builders030),
          const TutorialText('''
This example lists the main **flutter_bloc_form_plus** builders in one form.

**0.3.0 additions** in this demo:
* `AdaptiveTextFieldBlocBuilder`
* `RadioGroupFieldBlocBuilder` (Flutter `RadioGroup` API)
* TypeAhead via `TextFieldBlocBuilder` + `suggestions` on `TextFieldBloc`
'''),
        ],
      ),
    );
  }
}
