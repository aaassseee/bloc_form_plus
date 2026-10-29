import 'package:material_ui/material_ui.dart';

import 'package:bloc_form_web_plus/examples/submission_error_to_field_form.dart';
import 'package:bloc_form_web_plus/widgets/widgets.dart';

class SubmissionErrorToFieldExamplePage extends StatelessWidget {
  const SubmissionErrorToFieldExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Submission Error to Field',
      demo: const DeviceScreen(app: SubmissionErrorToFieldForm()),
      code: const CodeScreen(
          codePath: 'lib/examples/submission_error_to_field_form.dart'),
      tutorial: TutorialScreen(
        children: <Widget>[
          ...TutorialPackageSetup.dependencySteps(
            headerPrefix: '# Setup (bloc_form 0.3.0)',
          ),
          const TutorialText('''
You can add an error to field bloc from anywhere using the `addFieldError` method.

It is usually used to add an error that we get from the server.

For example when the username is not available and we want to show the error in the field.
'''),
          CodeCard.main(
            nestedPath: 'MyFormBloc > onSubmitting',
            code: '''
  @override
  void onSubmitting() async {

    username.addFieldError('That username is taken. Try another.');

  }
''',
          ),
          TutorialText.sub('''
Use **`FormBloc.clearErrors()`** to dismiss field errors without resetting values (Flutter 3.44 `Form.clearError` API).
'''),
          CodeCard.main(
            code: '''
OutlinedButton(
  onPressed: formBloc.clearErrors,
  child: Text('CLEAR ERRORS'),
),
''',
          ),
          TutorialText.sub('''
The `addFieldError` method has the optional parameter `isPermanent`, by default it is `false`, but if you assign `true` the error will be cached, so whenever you set that value the error will be added (like a sync validator).
'''),
          CodeCard.main(
            nestedPath: 'MyFormBloc > onSubmitting',
            code: '''
  @override
  void onSubmitting() async {

    if (username.value.toLowerCase() == 'dev') {
      username.addFieldError(
        'Cached - That username is taken. Try another.',
        isPermanent: true,
      );
    } else {
      username.addFieldError('That username is taken. Try another.');
    }
  }
''',
          ),
        ],
      ),
    );
  }
}
