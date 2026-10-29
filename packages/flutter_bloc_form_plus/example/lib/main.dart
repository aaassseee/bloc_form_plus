import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc_form_plus/flutter_bloc_form.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        inputDecorationTheme: InputDecorationThemeData(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      builder: (context, child) {
        return FormThemeProvider(
          theme: FormTheme(
            checkboxTheme: CheckboxFieldTheme(
              canTapItemTile: true,
            ),
            radioTheme: RadioFieldTheme(
              canTapItemTile: true,
            ),
          ),
          child: child!,
        );
      },
      home: AllFieldsForm(),
    );
  }
}

class AllFieldsFormBloc extends FormBloc<String, String> {
  final text1 = TextFieldBloc();

  final boolean1 = BooleanFieldBloc();

  final boolean2 = BooleanFieldBloc();

  final select1 = SelectFieldBloc(
    items: ['Option 1', 'Option 2'],
    validators: [FieldBlocValidators.required],
  );

  final select2 = SelectFieldBloc(
    items: ['Option 1', 'Option 2'],
    validators: [FieldBlocValidators.required],
  );

  final select2X = SelectFieldBloc(
    items:  ['Apple', 'Banana', 'Orange', 'Grapes', 'Mango', 'Peach'],
    validators: [FieldBlocValidators.required],
  );

  final multiSelect1 = MultiSelectFieldBloc<String, dynamic>(
    items: [
      'Option 1',
      'Option 2',
      'Option 3',
      'Option 4',
      'Option 5',
    ],
  );
  final file = InputFieldBloc<File?, String>(initialValue: null);

  final date1 = InputFieldBloc<DateTime?, Object>(initialValue: null);

  final dateAndTime1 = InputFieldBloc<DateTime?, Object>(initialValue: null);

  final time1 = InputFieldBloc<TimeOfDay?, Object>(initialValue: null);

  final double1 = InputFieldBloc<double, dynamic>(
    initialValue: 0.5,
  );

  AllFieldsFormBloc() : super(autoValidate: false) {
    addFieldBlocs(fieldBlocs: [
      text1,
      boolean1,
      boolean2,
      select1,
      select2,
      select2X,
      multiSelect1,
      date1,
      dateAndTime1,
      time1,
      double1,
    ]);
  }

  void addErrors() {
    text1.addFieldError('Awesome Error!');
    boolean1.addFieldError('Awesome Error!');
    boolean2.addFieldError('Awesome Error!');
    select1.addFieldError('Awesome Error!');
    select2.addFieldError('Awesome Error!');
    multiSelect1.addFieldError('Awesome Error!');
    date1.addFieldError('Awesome Error!');
    dateAndTime1.addFieldError('Awesome Error!');
    time1.addFieldError('Awesome Error!');
  }

  @override
  void onSubmitting() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 500));

      emitSuccess(canSubmitAgain: true);
    } catch (e) {
      emitFailure();
    }
  }
}

class AllFieldsForm extends StatelessWidget {
  const AllFieldsForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AllFieldsFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = BlocProvider.of<AllFieldsFormBloc>(context);

          return Scaffold(
            appBar: AppBar(title: const Text('Built-in Widgets')),
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: formBloc.addErrors,
                  icon: const Icon(Icons.error_outline),
                  label: const Text('ADD ERRORS'),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: formBloc.submit,
                  icon: const Icon(Icons.send),
                  label: const Text('SUBMIT'),
                ),
              ],
            ),
            body: FormBlocListener<AllFieldsFormBloc, String, String>(
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
              child: ScrollableFormBlocManager(
                formBloc: formBloc,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: <Widget>[
                      TextFieldBlocBuilder(
                        textFieldBloc: formBloc.text1,
                        suffixButton: SuffixButton.obscureText,
                        decoration: const InputDecoration(
                          labelText: 'TextFieldBlocBuilder',
                          prefixIcon: Icon(Icons.text_fields),
                        ),
                      ),
                      RadioButtonGroupFieldBlocBuilder<String>(
                        selectFieldBloc: formBloc.select2,
                        decoration: const InputDecoration(
                          labelText: 'RadioButtonGroupFieldBlocBuilder',
                        ),
                        groupStyle: const FlexGroupStyle(),
                        itemBuilder: (context, item) => FieldItem(
                          child: Text(item),
                        ),
                      ),
                        RadioGroupFieldBlocBuilder<String>(
                        groupStyle: const WrapGroupStyle(
                          direction: Axis.horizontal
                        ),
                        selectFieldBloc: formBloc.select2,
                        itemBuilder: (context, item) => FieldItem(child: Text(item)),
                        direction: RadioDirection.right, // left, right, top, bottom
                        padding: const EdgeInsets.all(4),
                        radioSize: 30,
                      labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                       spacing: 8,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                      ),
                      Card(
                        child: SizedBox(
                        
                          child: RadioGroupFieldBlocBuilder<String>(
                            selectFieldBloc: formBloc.select2X,
                            itemBuilder: (context, item) => FieldItem(child: Text(item)),
                            direction: RadioDirection.right,
                            radioSize: 24,
                            spacing: 2,
                            padding: const EdgeInsets.all(4),
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            groupStyle: const WrapGroupStyle(
                           //   direction: Axis.vertical,
                              alignment: WrapAlignment.center,      // center items horizontally
                              spacing: 8,                           // 8px space between items
                              runAlignment: WrapAlignment.center,   // center rows vertically
                              runSpacing: 12,                        // 12px space between rows
                              crossAxisAlignment: WrapCrossAlignment.center, // center items in each row
                            )
                          ),
                        ),
                      ),
                      //GRID
                  Card(
                    elevation: 8,
                    child: RadioGroupFieldBlocBuilder<String>(
                      selectFieldBloc: formBloc.select2X,
                      itemBuilder: (context, item) => FieldItem(child: Center(child: Text(item))),
                      direction: RadioDirection.bottom, // radio on left
                     // mainAxisAlignment: MainAxisAlignment.center,
                     // crossAxisAlignment: CrossAxisAlignment.center,
                      radioSize: 24,
                      spacing: 2,
                      groupStyle: GridGroupStyle(
                        height: 400,
                        //width: 600,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // 3 columns
                         // mainAxisSpacing: 12,
                         // crossAxisSpacing: 12,
                         // childAspectRatio: 2, // width / height ratio
                        ),
                      ),
                      padding: const EdgeInsets.all(1),
                    ),
                  ),

                      Card(
                        child: RadioMenuButtonFieldBlocBuilder<String>(
                          selectFieldBloc: formBloc.select2,
                          menuLabel: const Text("Select Color"),
                          itemBuilder: (context, item) {
                            return FieldItem(child: Text(
                              item
                            ));
                          },
                          radioSize: 10,
                          spacing: 6,

                        ),
                      ),

                      CheckboxGroupFieldBlocBuilder<String>(
                        multiSelectFieldBloc: formBloc.multiSelect1,
                        decoration: const InputDecoration(
                          labelText: 'CheckboxGroupFieldBlocBuilder',
                        ),
                        groupStyle: const ListGroupStyle(
                          scrollDirection: Axis.horizontal,
                          height: 64,
                        ),
                        itemBuilder: (context, item) => FieldItem(
                          child: Text(item),
                        ),
                      ),
                      DateTimeFieldBlocBuilder(
                        dateTimeFieldBloc: formBloc.date1,
                        format: DateFormat('dd-MM-yyyy'),
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        decoration: const InputDecoration(
                          labelText: 'DateTimeFieldBlocBuilder',
                          prefixIcon: Icon(Icons.calendar_today),
                          helperText: 'Date',
                        ),
                      ),
                      DateTimeFieldBlocBuilder(
                        dateTimeFieldBloc: formBloc.dateAndTime1,
                        canSelectTime: true,
                        format: DateFormat('dd-MM-yyyy  hh:mm'),
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        decoration: const InputDecoration(
                          labelText: 'DateTimeFieldBlocBuilder',
                          prefixIcon: Icon(Icons.date_range),
                          helperText: 'Date and Time',
                        ),
                      ),
                      TimeFieldBlocBuilder(
                        timeFieldBloc: formBloc.time1,
                        format: DateFormat('hh:mm a'),
                        initialTime: TimeOfDay.now(),
                        decoration: const InputDecoration(
                          labelText: 'TimeFieldBlocBuilder',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                      ),
                      SwitchFieldBlocBuilder(
                        booleanFieldBloc: formBloc.boolean2,
                        body: const Text('SwitchFieldBlocBuilder'),
                      ),
                      DropdownFieldBlocBuilder<String>(
                        selectFieldBloc: formBloc.select1,
                        decoration: const InputDecoration(
                          labelText: 'DropdownFieldBlocBuilder',
                        ),
                        itemBuilder: (context, value) => FieldItem(
                          isEnabled: value != 'Option 1',
                          child: Text(value),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => formBloc.addFieldBloc(
                                fieldBloc: formBloc.select1),
                            icon: const Icon(Icons.add),
                          ),
                          IconButton(
                            onPressed: () => formBloc.removeFieldBloc(
                                fieldBloc: formBloc.select1),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                      CheckboxFieldBlocBuilder(
                        booleanFieldBloc: formBloc.boolean1,
                        body: const Text('CheckboxFieldBlocBuilder'),
                      ),
                      CheckboxFieldBlocBuilder(
                        booleanFieldBloc: formBloc.boolean1,
                        body: const Text('CheckboxFieldBlocBuilder trailing'),
                        controlAffinity:
                            FieldBlocBuilderControlAffinity.trailing,
                      ),
                      SliderFieldBlocBuilder(
                        inputFieldBloc: formBloc.double1,
                        divisions: 10,
                        labelBuilder: (context, value) =>
                            value.toStringAsFixed(2),
                      ),
                      SliderFieldBlocBuilder(
                        inputFieldBloc: formBloc.double1,
                        divisions: 10,
                        labelBuilder: (context, value) =>
                            value.toStringAsFixed(2),
                        activeColor: Colors.red,
                        inactiveColor: Colors.green,
                      ),
                      SliderFieldBlocBuilder(
                        inputFieldBloc: formBloc.double1,
                        divisions: 10,
                        labelBuilder: (context, value) =>
                            value.toStringAsFixed(2),
                      ),
                      ChoiceChipFieldBlocBuilder<String>(
                        selectFieldBloc: formBloc.select2,
                        itemBuilder: (context, value) => ChipFieldItem(
                          label: Text(value),
                        ),
                      ),
                      FilterChipFieldBlocBuilder<String>(
                        multiSelectFieldBloc: formBloc.multiSelect1,
                        itemBuilder: (context, value) => ChipFieldItem(
                          label: Text(value),
                        ),
                      ),
                      BlocBuilder<InputFieldBloc<File?, String>,
                              InputFieldBlocState<File?, String>>(
                          bloc: formBloc.file,
                          builder: (context, state) {
                            return Container();
                          })
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
      canPop:  false,
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
                  MaterialPageRoute(builder: (_) => const AllFieldsForm())),
              icon: const Icon(Icons.replay),
              label: const Text('AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}
