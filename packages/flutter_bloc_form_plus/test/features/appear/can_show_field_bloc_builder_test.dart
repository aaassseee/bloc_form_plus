import 'package:bloc_form_plus/bloc_form.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc_form_plus/src/features/appear/can_show_field_bloc_builder.dart';
import 'package:flutter_test/flutter_test.dart';

const _fieldKey = Key('field');
const _fieldSize = 100.0;

class _FakeFormBloc extends FormBloc<void, void> {
  _FakeFormBloc(this.fieldBloc);

  final TextFieldBloc fieldBloc;

  @override
  void onSubmitting() {}

  @override
  Future<void> close() {
    fieldBloc.close();
    return super.close();
  }
}

void main() {
  late TextFieldBloc fieldBloc;
  late _FakeFormBloc formBloc;

  setUp(() {
    fieldBloc = TextFieldBloc(name: 'field');
    formBloc = _FakeFormBloc(fieldBloc);
  });

  tearDown(() => formBloc.close());

  Widget subject({
    required bool animate,
    bool disableAnimations = false,
    bool tickerEnabled = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: disableAnimations),
            child: TickerMode(
              enabled: tickerEnabled,
              child: CanShowFieldBlocBuilder(
                fieldBloc: fieldBloc,
                animate: animate,
                builder: (_, _) => const SizedBox(
                  key: _fieldKey,
                  width: _fieldSize,
                  height: _fieldSize,
                  child: Text('field'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Flushes the 10ms initial-settle timer, so the initial state is not
  /// rendered with a transition.
  Future<void> settleInitialState(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpAndSettle();
  }

  /// Adds or removes the field from the [FormBloc] and renders the first frame
  /// of the resulting transition.
  ///
  /// The state change reaches the widget in a microtask, hence the two pumps.
  Future<void> toggleField(WidgetTester tester, {required bool add}) async {
    if (add) {
      formBloc.addFieldBlocs(fieldBlocs: [fieldBloc]);
    } else {
      formBloc.removeFieldBlocs(fieldBlocs: [fieldBloc]);
    }
    await tester.pump();
    await tester.pump();
  }

  /// Height of the rendered field, which reflects the transition progress.
  double fieldHeight(WidgetTester tester) =>
      tester.getSize(find.byType(CanShowFieldBlocBuilder)).height;

  group('CanShowFieldBlocBuilder:', () {
    testWidgets(
      'does not render the field when it is not added to a FormBloc',
      (tester) async {
        await tester.pumpWidget(subject(animate: true));
        await settleInitialState(tester);

        expect(find.byKey(_fieldKey), findsNothing);
      },
    );

    testWidgets('does not render the field when it is not added to a FormBloc '
        'and the animations are disabled', (tester) async {
      await tester.pumpWidget(subject(animate: false));
      await settleInitialState(tester);
      expect(find.byKey(_fieldKey), findsNothing);

      await tester.pumpWidget(subject(animate: true, disableAnimations: true));
      await settleInitialState(tester);
      expect(find.byKey(_fieldKey), findsNothing);
    });

    testWidgets('mounts the field as soon as it is added so the transition '
        'can animate it in', (tester) async {
      await tester.pumpWidget(subject(animate: true));
      await settleInitialState(tester);
      expect(find.byKey(_fieldKey), findsNothing);

      await toggleField(tester, add: true);

      // The real field must be mounted while the transition is running,
      // otherwise the transition animates an empty box and the field pops in
      // only when the animation is completed.
      expect(find.byKey(_fieldKey), findsOneWidget);
      expect(fieldHeight(tester), lessThan(_fieldSize));

      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byKey(_fieldKey), findsOneWidget);
      expect(fieldHeight(tester), lessThan(_fieldSize));

      await tester.pumpAndSettle();
      expect(fieldHeight(tester), _fieldSize);
    });

    testWidgets('hides the field when it is removed from the FormBloc', (
      tester,
    ) async {
      formBloc.addFieldBlocs(fieldBlocs: [fieldBloc]);
      await tester.pumpWidget(subject(animate: true));
      await settleInitialState(tester);
      expect(fieldHeight(tester), _fieldSize);

      await toggleField(tester, add: false);

      // The field must stay mounted to be animated out.
      expect(find.byKey(_fieldKey), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byKey(_fieldKey), findsOneWidget);
      expect(fieldHeight(tester), lessThan(_fieldSize));

      await tester.pumpAndSettle();
      expect(find.byKey(_fieldKey), findsNothing);
    });

    testWidgets(
      'hides the field immediately when it is removed and the animations '
      'are disabled',
      (tester) async {
        formBloc.addFieldBlocs(fieldBlocs: [fieldBloc]);
        await tester.pumpWidget(subject(animate: false));
        await settleInitialState(tester);
        expect(find.byKey(_fieldKey), findsOneWidget);

        await toggleField(tester, add: false);

        expect(find.byKey(_fieldKey), findsNothing);
      },
    );

    testWidgets(
      'keeps the field mounted when the transition cannot run, so it is '
      'never permanently hidden',
      (tester) async {
        await tester.pumpWidget(subject(animate: true, tickerEnabled: false));
        await settleInitialState(tester);

        await toggleField(tester, add: true);

        // The ticker is muted, so the transition never advances and the field is
        // not revealed yet, but it must already be part of the widget tree.
        expect(find.byKey(_fieldKey), findsOneWidget);
        expect(fieldHeight(tester), lessThan(_fieldSize));

        await tester.pumpWidget(subject(animate: true));
        await tester.pumpAndSettle();

        expect(fieldHeight(tester), _fieldSize);
      },
    );

    testWidgets(
      'renders the field on the first frame when it is already added',
      (tester) async {
        formBloc.addFieldBlocs(fieldBlocs: [fieldBloc]);
        await tester.pumpWidget(subject(animate: true));

        expect(fieldHeight(tester), _fieldSize);
      },
    );

    testWidgets('keeps the field visible when the animations are enabled '
        'after being disabled', (tester) async {
      await tester.pumpWidget(subject(animate: true, disableAnimations: true));
      await settleInitialState(tester);
      expect(find.byKey(_fieldKey), findsNothing);

      await toggleField(tester, add: true);
      expect(fieldHeight(tester), _fieldSize);

      await tester.pumpWidget(subject(animate: true));
      await tester.pumpAndSettle();

      expect(fieldHeight(tester), _fieldSize);
    });
  });
}
