import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc_form_plus/flutter_bloc_form.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WhatsNewForm(),
    );
  }
}

class WhatsNewFormBloc extends FormBloc<String, String> {
  final email = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.email,
    ],
  );

  final password = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.passwordMin6Chars,
    ],
  );

  final framework = SelectFieldBloc<String, dynamic>(
    items: ['Flutter', 'Dart', 'Bloc'],
    validators: [FieldBlocValidators.required],
  );

  final city = TextFieldBloc(
    suggestions: (pattern) async {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      const cities = [
        'San Francisco',
        'London',
        'Tokyo',
        'Berlin',
        'Dar es Salaam',
      ];
      if (pattern.isEmpty) return cities;
      final query = pattern.toLowerCase();
      return cities.where((c) => c.toLowerCase().contains(query)).toList();
    },
  );

  WhatsNewFormBloc() {
    addFieldBlocs(fieldBlocs: [email, password, framework, city]);
  }

  Future<void> validateAllFields() async {
    for (final field in state.fields) {
      await field.validate();
    }
  }

  @override
  void onSubmitting() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    emitFailure(
      failureResponse: 'Submit blocked — use Clear errors to dismiss field errors.',
    );
  }
}

class WhatsNewForm extends StatefulWidget {
  const WhatsNewForm({super.key});

  @override
  State<WhatsNewForm> createState() => _WhatsNewFormState();
}

class _WhatsNewFormState extends State<WhatsNewForm> {
  bool _forceCupertino = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WhatsNewFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = context.read<WhatsNewFormBloc>();

          return Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationThemeData(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            child: Scaffold(
              appBar: AppBar(
                title: const Text('What\'s New 0.3.0'),
              ),
              body: FormBlocListener<WhatsNewFormBloc, String, String>(
                onFailure: (context, state) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.failureResponse ?? 'Error')),
                  );
                },
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionHeader(
                        title: 'Flutter 3.44.2 · bloc_form 0.3.0',
                        subtitle:
                            'Cupertino/adaptive fields, accessibility, RadioGroup, clearError APIs, and web keyboard improvements.',
                      ),
                      BlocBuilder<WhatsNewFormBloc,
                          FormBlocState<String, String>>(
                        bloc: formBloc,
                        builder: (context, state) {
                          return Text(
                            'FormBlocState.fields: ${state.fields.length} field blocs registered',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _SectionHeader(
                        title: 'Adaptive & Cupertino text fields',
                        subtitle:
                            'Toggle Cupertino styling on web via forceCupertino.',
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Force Cupertino text field'),
                        value: _forceCupertino,
                        onChanged: (value) {
                          setState(() => _forceCupertino = value);
                        },
                      ),
                      AdaptiveTextFieldBlocBuilder(
                        textFieldBloc: formBloc.email,
                        forceCupertino: _forceCupertino,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'AdaptiveTextFieldBlocBuilder',
                          prefixIcon: Icon(Icons.email_outlined),
                          helperText: 'Material or Cupertino based on platform',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SectionHeader(
                        title: 'SensitiveContent',
                        subtitle:
                            'Obscured passwords use SensitiveContent on supported platforms.',
                      ),
                      AdaptiveTextFieldBlocBuilder(
                        textFieldBloc: formBloc.password,
                        forceCupertino: _forceCupertino,
                        sensitiveContent: true,
                        suffixButton: SuffixButton.obscureText,
                        decoration: const InputDecoration(
                          labelText: 'Password (sensitiveContent: true)',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SectionHeader(
                        title: 'RadioGroupFieldBlocBuilder',
                        subtitle: 'Uses Flutter RadioGroup API (3.32+).',
                      ),
                      RadioGroupFieldBlocBuilder<String>(
                        selectFieldBloc: formBloc.framework,
                        direction: RadioDirection.right,
                        itemBuilder: (context, item) => FieldItem(
                          child: Text(item),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SectionHeader(
                        title: 'TypeAhead suggestions',
                        subtitle:
                            'TextFieldBlocBuilder with suggestions — web keyboard inset aware.',
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: formBloc.city,
                        decoration: const InputDecoration(
                          labelText: 'City (type to search)',
                          prefixIcon: Icon(Icons.location_city_outlined),
                          helperText: 'Try "Lon" or "Dar"',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SectionHeader(
                        title: 'FormBloc.clearErrors()',
                        subtitle:
                            'Clears validation errors without resetting values (Flutter Form.clearError).',
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await formBloc.validateAllFields();
                              },
                              child: const Text('VALIDATE'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: formBloc.clearErrors,
                              child: const Text('CLEAR ERRORS'),
                            ),
                          ),
                        ],
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
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
