import 'package:flutter/material.dart';
import 'package:flutter_bloc_form_plus/flutter_bloc_form.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SubmissionErrorToFieldForm(),
    );
  }
}

class SubmissionErrorToFieldFormBloc extends FormBloc<String, String> {
  final username = TextFieldBloc();

  SubmissionErrorToFieldFormBloc() {
    addFieldBlocs(
      fieldBlocs: [
        username,
      ],
    );
  }

  @override
  void onSubmitting() async {
    debugPrint(username.value);

    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (username.value.toLowerCase() == 'dev') {
      username.addFieldError(
        'Cached - That username is taken. Try another.',
        isPermanent: true,
      );

      emitFailure(failureResponse: 'Cached error was added to username field.');
    } else {
      username.addFieldError('That username is taken. Try another.');

      emitFailure(failureResponse: 'Error was added to username field.');
    }
  }
}

class SubmissionErrorToFieldForm extends StatelessWidget {
  const SubmissionErrorToFieldForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubmissionErrorToFieldFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc =
              BlocProvider.of<SubmissionErrorToFieldFormBloc>(context);

          return Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationThemeData(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: Scaffold(
              appBar: AppBar(title: const Text('Submission Error to Field')),
              body: FormBlocListener<SubmissionErrorToFieldFormBloc, String,
                  String>(
                onSubmitting: (context, state) {
                  LoadingDialog.show(context);
                },
                onSuccess: (context, state) {
                  LoadingDialog.hide(context);

                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SuccessScreen()));
                },
                onFailure: (context, state) {
                  LoadingDialog.hide(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.failureResponse!)));
                },
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.username,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.sentiment_very_satisfied),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('"dev" will add a cached error'),
                        ),
                        OutlinedButton.icon(
                          onPressed: formBloc.clearErrors,
                          icon: const Icon(Icons.clear_all),
                          label: const Text('CLEAR ERRORS'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: formBloc.submit,
                          child: const Text('SUBMIT'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key? key}) => showDialog<void>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (_) => LoadingDialog(key: key),
      ).then((_) {
        if (context.mounted) {
          FocusScope.of(context).requestFocus(FocusNode());
        }
      });

  static void hide(BuildContext context) => Navigator.pop(context);

  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // prevents popping
      onPopInvokedWithResult: (didPop, result) {
        // didPop == true if the route already popped
        // didPop == false if it was blocked
        // result is the value passed back when popping (can be null)
      },
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(12.0),
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.tag_faces, size: 100),
            const SizedBox(height: 10),
            const Text(
              'Success',
              style: TextStyle(fontSize: 54, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (_) => const SubmissionErrorToFieldForm())),
              icon: const Icon(Icons.replay),
              label: const Text('AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}
