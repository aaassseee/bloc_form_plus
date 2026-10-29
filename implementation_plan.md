# Implementation Plan

## [Overview]

Make field visibility in `CanShowFieldBlocBuilder` depend only on `FieldBlocState.hasFormBloc` (i.e. "is this field added to a `FormBloc`?") and never on the completion of a transition animation, while keeping the intent of commit `c790265` ("initial show without add, never hide if low end device") and restoring the animated show/hide that `c790265` accidentally disabled.

Scope: one library file (`packages/flutter_bloc_form_plus/lib/src/features/appear/can_show_field_bloc_builder.dart`), one new widget test file, and a CHANGELOG entry. No public API change: the `CanShowFieldBlocBuilder` constructor, its `animate` flag and the `builder(context, canShow)` contract stay exactly the same, so every existing caller keeps working — `SimpleFieldBlocBuilder` (used by text/dropdown/chips/slider/switch/date-time builders), `CheckboxFieldBlocBuilder`, `RadioGroupFieldBlocBuilder`, `RadioButtonGroupFieldBlocBuilder`.

Context and evidence (why a fix is needed):

* `c790265` changed `if (_showOnFirstFrame)` into `if (_showOnFirstFrame && _canShow)` in `build()`. That is **correct for the animations-disabled path**: when `shouldAnimateFieldTransitions(context, widget.animate)` is `false` (`animateWhenCanShow: false`, or `MediaQuery.disableAnimations` / reduce-motion — commonly enabled on low-end devices) the widget applies no `FadeTransition`/`SizeTransition`, so before the change `_controller` had no effect at all and the field was rendered even when it was *not* added to the `FormBloc` (shows before add) and stayed rendered after removal (never hides). Those two symptoms are exactly what the commit message describes, and they must stay fixed.
* The same commit made `_canShow` a *post-animation* flag: `_changeVisibility()` does `_updateAnimation(canShow).whenComplete(() => _updateCanShow(canShow))` (current line 91). Consequences:
  1. On a **show**, the child is `SizedBox.shrink()` for the whole 300 ms, so `FadeTransition`/`SizeTransition` animate an empty box and the field then pops in at full size (no animation, plus a visible delay/jump on slow devices).
  2. `TickerFuture` **never completes when its ticker is canceled or muted** — Flutter SDK `packages/flutter/lib/src/scheduler/ticker.dart`: `_cancel()` only completes `_secondaryCompleter` (used by `orCancel`), never `_primaryCompleter` (used by `whenComplete`), and the class docs state *"If the Ticker is disposed without being stopped, or if it is stopped with `canceled` set to true, then this Future will never complete… they risk hanging indefinitely if the Ticker is canceled **or muted** before the animation completes."* `AnimationController.stop({bool canceled = true})` defaults to `true`, and both `_animateToInternal()` (a new `forward`/`reverse`) and the `value =` setter call `stop()`. Tickers are muted by `TickerMode(enabled: false)` ancestors (`IndexedStack`, `AnimatedCrossFade`, `Expansible`, `Hero`, inactive overlay/route entries).
  3. Therefore, whenever the show animation is canceled (interrupted) or its ticker is muted, `_updateCanShow(true)` never runs. With `c790265`'s extra `&& _canShow` gate this leaves the field **permanently invisible** — the reported "low end device never shows because the animation is too slow then skipped frames". Before `c790265` the child was at least mounted, so the failure was cosmetic rather than permanent.
* Secondary flaws found while reading the file: `_initVisibility()` guards the controller value with `widget.animate` while `build()` uses `shouldAnimateFieldTransitions(...)`, and the `!animate` branch of `_changeVisibility()` never syncs the controller — so toggling reduce-motion can leave `_controller` at `0.0` while `_canShow == true` (invisible field until the next event); `didUpdateWidget()` compares `widget.fieldBloc.state.hasFormBloc != oldWidget.fieldBloc.state.hasFormBloc`, which is always `false` for the same bloc instance, so a swapped `fieldBloc` is never re-synced.

High-level approach: keep one authoritative flag `_canShow` (from `hasFormBloc`, updated synchronously on show so the real content is mounted and *animated in*), add one mount flag `_keepChild` so the child stays in the tree while it animates out, and unmount it from an `AnimationStatus` listener (which is driven by the very same controller that drives the transition) instead of a `TickerFuture`. All "no animation" paths go through one helper that snaps `_canShow`, `_keepChild` and the controller value together.

### Behaviour matrix (after the fix)

| `hasFormBloc` | transitions rendered | child mounted | controller | notes |
| --- | --- | --- | --- | --- |
| `true` at `initState` | yes/no | yes | `1.0` (instant) | first frame shows the field without animation (unchanged) |
| `false` → `true` | yes | immediately, transition animates it in | `0.0` → `forward()` → `1.0` | restores pre-`c790265` look; no dependency on `whenComplete` |
| `true` → `false` | yes | kept until `AnimationStatus.dismissed` | `1.0` → `reverse()` → `0.0` | `builder` receives `canShow: false` while fading out |
| `false` → `true` / `true` → `false` | no (`animate: false` or reduce motion) | yes / no, immediately | `1.0` / `0.0` (snapped) | keeps the `c790265` fix: never shown before add, always hidden after removal |
| never added | either | no | `0.0` | renders `SizedBox.shrink()` |

## [Types]

No public types are added, removed or changed. `CanShowFieldBlocBuilder` keeps `FieldBloc fieldBloc`, `bool animate`, `Widget Function(BuildContext, bool) builder`.

Internal state of `_CanShowFieldBlocBuilderState` (all private):

| member | type | meaning |
| --- | --- | --- |
| `_animationDuration` | `static const Duration` | `Duration(milliseconds: 300)` — extracted from the current inline literal, same value |
| `_showOnFirstFrame` | `bool` | unchanged; `true` once the initial `FormBloc` event handling has settled (initial state may be rendered without animating) |
| `_controller` | `late AnimationController` | unchanged, now created with `..addStatusListener(_handleAnimationStatus)` |
| `_canShow` | `bool` | **source of truth**: `fieldBloc.state.hasFormBloc`. Passed to `builder` and used to decide whether the field may be rendered. Updated immediately on show; only the *mount* of the outgoing child is delayed |
| `_keepChild` | `bool` | new; `true` while the child must stay in the widget tree (it equals `_canShow` after a snap, and stays `true` during a reverse transition until `AnimationStatus.dismissed`) |

## [Files]

### Modified

**`packages/flutter_bloc_form_plus/lib/src/features/appear/can_show_field_bloc_builder.dart`**
Only `_CanShowFieldBlocBuilderState` changes (fields, `initState`, `didUpdateWidget`, `_initVisibility` → `_syncWithFieldBloc`, `_changeVisibility`, new `_handleAnimationStatus`, `build`; `_updateCanShow` and `_updateAnimation` are deleted). Imports, the widget class, the 10 ms initial-settle heuristic and the `BlocListener` wiring stay as they are.

### New

**`packages/flutter_bloc_form_plus/test/features/appear/can_show_field_bloc_builder_test.dart`**
First test file of the `flutter_bloc_form_plus` package (the package currently has no `test/` directory; `flutter_test` is already declared in `dev_dependencies`). Mirrors the `lib/src/features/appear/` path, matching how `packages/bloc_form_plus/test/` is organised. Contains the regression tests listed in [Testing].

### Modified (documentation, optional but recommended)

**`packages/flutter_bloc_form_plus/CHANGELOG.md`**
Prepend a new top section above the existing `# 0.3.0` heading (the package version stays `0.3.0` in `pubspec.yaml`; the branch is a bugfix branch):

```markdown
# Unreleased

## Fixed

* **`CanShowFieldBlocBuilder`** — field visibility is now driven only by whether the `FieldBloc` is added to a `FormBloc`. The show/hide transition is no longer required to complete for the field to be shown or hidden, so a canceled or muted ticker (slow/low-end devices, reduce-motion, off-screen `TickerMode`) can no longer leave the field permanently hidden. The show transition animates the field again instead of an empty box, and reduce-motion (`MediaQuery.disableAnimations`) still shows/hides instantly.
```

### Not modified (verified)

* `packages/flutter_bloc_form_plus/pubspec.yaml` — `flutter_test` is already a dev dependency; no new packages.
* `lib/src/utils/accessibility.dart` — `shouldAnimateFieldTransitions` is reused unchanged.
* `lib/src/fields/simple_field_bloc_builder.dart`, `lib/src/checkbox_field_bloc_builder.dart`, `lib/src/groups/fields/radio_group_field_bloc.dart`, `lib/src/groups/fields/radio_button_group_field_bloc.dart` — callers only; no changes needed (they pass `animate:` and a `builder`).
* `packages/bloc_form_plus/**` — `hasFormBloc`/`updateFormBloc`/`removeFormBloc` already emit synchronous `Bloc` state changes; nothing to fix there.
* No files are deleted or moved.

## [Functions]

File: `packages/flutter_bloc_form_plus/lib/src/features/appear/can_show_field_bloc_builder.dart`

### New

**`void _syncWithFieldBloc()`** (state method) — replaces `_initVisibility()`. Reads `widget.fieldBloc.state.hasFormBloc` once and applies it *without* animating: sets `_canShow`, `_keepChild` and `_controller.value` (`1.0`/`0.0`). Used by the initial state (initState / 10 ms settle) and by every path where transitions must not run. Setting `_controller.value` unconditionally (not only when `widget.animate`) keeps the controller in sync with `_canShow`, which fixes the reduce-motion toggle leaving the field invisible. Safe to call from `initState` and `didUpdateWidget`: it does not call `setState` itself and cannot cause a nested `setState` from `_handleAnimationStatus`, because that listener returns early in both of those cases.

**`void _handleAnimationStatus(AnimationStatus status)`** (state method) — status listener registered on `_controller`. Returns unless `status == AnimationStatus.dismissed`; returns if `_canShow || !_keepChild`; otherwise `setState(() => _keepChild = false)` so the outgoing child is removed once the reverse transition has actually finished. This replaces the `TickerFuture.whenComplete` callback and is immune to cancellation/muting. It also covers the zero-duration case (`reverse()` from `0.0` jumps straight to `dismissed`).

### Modified

**`initState()`** — controller creation becomes `AnimationController(vsync: this, duration: _animationDuration)..addStatusListener(_handleAnimationStatus)`; both branches call `_syncWithFieldBloc()` instead of `_initVisibility()`. The 10 ms `Future.delayed` settle heuristic is intentionally kept as-is (Rule 3: it only suppresses the transition for fields added during initialisation and is not the cause of the reported bug; a possible follow-up is replacing it with `WidgetsBinding.instance.addPostFrameCallback`).

**`didUpdateWidget(CanShowFieldBlocBuilder oldWidget)`** — condition becomes `widget.animate != oldWidget.animate || widget.fieldBloc != oldWidget.fieldBloc` and calls `_syncWithFieldBloc()`. The old `widget.fieldBloc.state.hasFormBloc != oldWidget.fieldBloc.state.hasFormBloc` check is dropped because both sides are normally the same instance (always `false`); comparing the blocs themselves makes a swapped `fieldBloc` re-sync correctly (the `BlocListener` re-subscribes on its own).

**`_changeVisibility(bool canShow)`** — early-returns when `!_showOnFirstFrame` (unchanged) and now also when `_canShow == canShow` (no spurious transitions). When `shouldAnimateFieldTransitions(context, widget.animate)` is `false` it does `setState(_syncWithFieldBloc)` (instant, keeps the `c790265` fix). Otherwise it does `setState(() { _canShow = canShow; _keepChild = true; })` **before** starting the transition, so the real content is mounted and revealed by `forward()` and stays mounted through `reverse()`; then `canShow ? _controller.forward() : _controller.reverse()`. No `TickerFuture` is awaited any more.

**`build(BuildContext context)`** — render gate (the `BlocListener` wrapper, `listenWhen` and `listener` are unchanged):

```dart
final animate = shouldAnimateFieldTransitions(context, widget.animate);

// The field is shown only when it is added to a FormBloc. While it animates
// out it must stay in the widget tree, but only when the transitions are
// actually rendered.
final canShowChild =
    _showOnFirstFrame && (_canShow || (animate && _keepChild));

Widget child = canShowChild
    ? widget.builder(context, _canShow)
    : const SizedBox.shrink();

if (animate) {
  child = FadeTransition(
    opacity: _controller,
    child: SizeTransition(sizeFactor: _controller, child: child),
  );
}
```

The `animate && _keepChild` term is required: if animations are turned off *while* a hide is in flight, `_keepChild` may still be `true` and the child must not be rendered (otherwise the "never hides" bug that `c790265` fixed comes back).

### Removed

* `void _updateCanShow(bool canShow)` — its only purpose was to flip `_canShow` after the animation; `_changeVisibility` now sets `_canShow` synchronously.
* `TickerFuture _updateAnimation(bool canShow)` — inlined into `_changeVisibility`; the returned future was the source of the hangs.

### Target state of the modified file

```dart
class _CanShowFieldBlocBuilderState extends State<CanShowFieldBlocBuilder>
    with TickerProviderStateMixin {
  static const _animationDuration = Duration(milliseconds: 300);

  // Identifies whether it is waiting for the FormBloc's event handling
  bool _showOnFirstFrame = false;

  late AnimationController _controller;

  /// Whether the [FieldBloc] is currently added to a [FormBloc].
  ///
  /// It is the source of truth of whether the field can be shown and never
  /// depends on the transition animation being completed.
  bool _canShow = false;

  /// Whether the child must stay in the widget tree to be able to animate out.
  bool _keepChild = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _animationDuration)
      ..addStatusListener(_handleAnimationStatus);

    if (widget.fieldBloc.state.hasFormBloc) {
      _showOnFirstFrame = true;
      _syncWithFieldBloc();
    } else {
      Future.delayed(const Duration(milliseconds: 10)).whenComplete(() {
        if (!mounted) return;
        setState(() {
          _showOnFirstFrame = true;
          _syncWithFieldBloc();
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant CanShowFieldBlocBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_showOnFirstFrame) return;

    if (widget.animate != oldWidget.animate ||
        widget.fieldBloc != oldWidget.fieldBloc) {
      _syncWithFieldBloc();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Updates the visibility immediately, without a transition.
  void _syncWithFieldBloc() {
    final canShow = widget.fieldBloc.state.hasFormBloc;

    _canShow = canShow;
    _keepChild = canShow;
    _controller.value = canShow ? 1.0 : 0.0;
  }

  void _changeVisibility(bool canShow) {
    if (!_showOnFirstFrame) return;
    if (_canShow == canShow) return;

    if (!shouldAnimateFieldTransitions(context, widget.animate)) {
      setState(_syncWithFieldBloc);
      return;
    }

    setState(() {
      _canShow = canShow;
      // Keep the child mounted so that it can be animated out.
      _keepChild = true;
    });

    if (canShow) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  /// Unmounts the child when it has finished animating out.
  ///
  /// The [AnimationStatus] is used instead of the [TickerFuture] returned by
  /// [AnimationController.forward] / [AnimationController.reverse], because
  /// those futures never complete when the ticker is canceled or muted, which
  /// would leave the field permanently hidden.
  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed) return;
    if (_canShow || !_keepChild) return;

    setState(() => _keepChild = false);
  }

  @override
  Widget build(BuildContext context) {
    final animate = shouldAnimateFieldTransitions(context, widget.animate);

    // The field is shown only when it is added to a FormBloc. While it is
    // animating out it must stay in the widget tree, but only when the
    // transitions are actually rendered.
    final canShowChild =
        _showOnFirstFrame && (_canShow || (animate && _keepChild));

    Widget child = canShowChild
        ? widget.builder(context, _canShow)
        : const SizedBox.shrink();

    if (animate) {
      child = FadeTransition(
        opacity: _controller,
        child: SizeTransition(sizeFactor: _controller, child: child),
      );
    }

    return BlocListener<FieldBloc, FieldBlocStateBase>(
      bloc: widget.fieldBloc,
      listenWhen: (prev, curr) => prev.hasFormBloc != curr.hasFormBloc,
      listener: (context, state) => _changeVisibility(state.hasFormBloc),
      child: child,
    );
  }
}
```

`dart format` (CI runs `dart format --set-exit-if-changed` for the sibling package) must be run on the file; this snippet was extracted and checked against `dart format --set-exit-if-changed` with the installed SDK (Flutter 3.47.8 / tall style), so it should come out unchanged.

## [Classes]

* **`CanShowFieldBlocBuilder`** (`lib/src/features/appear/can_show_field_bloc_builder.dart`) — unchanged (constructor, fields, `createState`).
* **`_CanShowFieldBlocBuilderState`** — modified as described in [Functions]/[Types]: keeps `TickerProviderStateMixin` (deliberately not switched to `SingleTickerProviderStateMixin`, to stay surgical), adds `_animationDuration`, `_keepChild`, `_syncWithFieldBloc()` and `_handleAnimationStatus()`; removes `_updateCanShow()` and `_updateAnimation()`.
* No class is added or removed. No subclass/caller is affected: `SimpleFieldBlocBuilder`, `CheckboxFieldBlocBuilder`, `RadioGroupFieldBlocBuilder` and `RadioButtonGroupFieldBlocBuilder` only pass `fieldBloc`, `animate` and `builder`.

## [Dependencies]

None. No `pubspec.yaml` change, no new package, no version bump (the branch is a bugfix; the CHANGELOG entry uses an `# Unreleased` section). `flutter_test` (already in `dev_dependencies`) is the only requirement for the new test file.

## [Testing]

### Automated

Command (mirrors CI usage for the sibling package, run from the package directory):

```bash
cd /Users/jack.liu/Desktop/jack/project/bloc_form_plus/packages/flutter_bloc_form_plus
flutter test
dart format --output=none --set-exit-if-changed lib test
dart analyze --fatal-infos --fatal-warnings lib test
```

(`packages/flutter_bloc_form_plus` already has a resolved `.dart_tool/package_config.json`, and the workspace root is a Dart pub workspace, so no extra `pub get` should be required; run `flutter pub get` at the repository root if resolution is stale.)

New file: `test/features/appear/can_show_field_bloc_builder_test.dart`. It uses a real `FormBloc` + `TextFieldBloc` (no mocks) and a fixed-size child so that geometry can be asserted:

* subject: `CanShowFieldBlocBuilder(fieldBloc: fieldBloc, animate: animate, builder: (_, _) => const SizedBox(key: fieldKey, height: 100, width: 100, child: Text('field')))` inside `MaterialApp` → `Scaffold`;
* `FormBloc` created per test with the field **not** added; membership toggled with `formBloc.addFieldBlocs(fieldBlocs: [fieldBloc])` / `formBloc.removeFieldBlocs(fieldBlocs: [fieldBloc])`;
* helper `_pump({required bool animate, bool disableAnimations = false})` that wraps the subject in `Builder` + `MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations))` to exercise the reduce-motion path;
* a `TickerMode(enabled: …)` variant is used to reproduce a transition that can never complete.

Test cases (each one states the intent it protects):

1. **`does not render the field when it is not added to a FormBloc`** — `animate: true`, `pumpAndSettle()` → `find.byKey(fieldKey)` is `findsNothing`. (Never show a field that is not part of the form.)
2. **`does not render the field when it is not added to a FormBloc and animations are disabled`** — `animate: false` and, in a second expectation, `disableAnimations: true` → `findsNothing`. Regression test for the "initial show without add" symptom fixed by `c790265`.
3. **`mounts the field as soon as it is added so the transition can animate it in`** — start hidden, add the field, `await tester.pump()` (start of the transition) → `findsOneWidget`; `await tester.pump(const Duration(milliseconds: 150))` → `tester.getSize(find.byKey(fieldKey)).height` is `greaterThan(0)` and `lessThan(100)` (the real field is being revealed by the transition, not an empty box); `pumpAndSettle()` → height `100`. Fails on the current code, which mounts the child only after the transition ends.
4. **`hides the field when it is removed from the FormBloc`** — visible, remove the field, `pump(const Duration(milliseconds: 150))` → still mounted (`findsOneWidget`) and height between 0 and 100; `pumpAndSettle()` → `findsNothing`. (The child must stay mounted to animate out, then be unmounted.)
5. **`hides the field immediately when it is removed and animations are disabled`** — `animate: false` (and `disableAnimations: true`), visible → remove → `await tester.pump()` → `findsNothing`. Regression test for the "never hide if low end device" symptom fixed by `c790265`.
6. **`keeps the field mounted when the transition cannot run`** — wrap in `TickerMode(enabled: false)`: add the field → `await tester.pump()` → `findsOneWidget` (the child is mounted although the ticker is muted and the animation therefore never advances); then rebuild with `TickerMode(enabled: true)` and `pumpAndSettle()` → height `100`. Regression test for the "never shows" symptom: visibility must not depend on the `TickerFuture` completing. The mid-state assertion is deliberate — it is the only way a widget test can observe a ticker that never completes; the final assertion proves the field becomes visible once the ticker runs.
7. **`renders the field on the first frame when it is already added`** — field added before `pumpWidget`, `animate: true` → after a single `await tester.pump()` the height is already `100` (no initial animation, preserving the existing 10 ms settle behaviour).

### Manual

Run the web demo (`bloc_form_web_plus`) or `packages/flutter_bloc_form_plus/example` and open the conditional-fields form (`bloc_form_web_plus/lib/examples/conditional_fields_form.dart`): toggling "Do you want to see a secret field?" must animate the secret field in/out smoothly, and it must still appear instantly (and disappear) with the OS "remove animations"/reduce-motion setting enabled, or with `animateWhenCanShow: false`.

### Test file (target content)

`packages/flutter_bloc_form_plus/test/features/appear/can_show_field_bloc_builder_test.dart`

```dart
import 'package:bloc_form_plus/bloc_form.dart';
import 'package:flutter/material.dart';
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
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: disableAnimations),
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

  /// Height of the rendered field, which reflects the transition progress.
  double fieldHeight(WidgetTester tester) =>
      tester.getSize(find.byType(CanShowFieldBlocBuilder)).height;

  group('CanShowFieldBlocBuilder:', () {
    testWidgets('does not render the field when it is not added to a FormBloc',
        (tester) async {
      await tester.pumpWidget(subject(animate: true));
      await settleInitialState(tester);

      expect(find.byKey(_fieldKey), findsNothing);
    });

    testWidgets(
        'does not render the field when it is not added to a FormBloc '
        'and the animations are disabled', (tester) async {
      await tester.pumpWidget(subject(animate: false));
      await settleInitialState(tester);
      expect(find.byKey(_fieldKey), findsNothing);

      await tester.pumpWidget(subject(animate: true, disableAnimations: true));
      await settleInitialState(tester);
      expect(find.byKey(_fieldKey), findsNothing);
    });

    testWidgets(
        'mounts the field as soon as it is added so the transition '
        'can animate it in', (tester) async {
      await tester.pumpWidget(subject(animate: true));
      await settleInitialState(tester);
      expect(find.byKey(_fieldKey), findsNothing);

      formBloc.addFieldBlocs(fieldBlocs: [fieldBloc]);
      await tester.pump();

      // The real field must be mounted while the transition is running,
      // otherwise the transition animates an empty box and the field pops in
      // only when the animation is completed.
      expect(find.byKey(_fieldKey), findsOneWidget);
      expect(fieldHeight(tester), 0.0);

      await tester.pump(const Duration(milliseconds: 150));
      expect(fieldHeight(tester), greaterThan(0.0));
      expect(fieldHeight(tester), lessThan(_fieldSize));

      await tester.pumpAndSettle();
      expect(fieldHeight(tester), _fieldSize);
    });

    testWidgets('hides the field when it is removed from the FormBloc',
        (tester) async {
      formBloc.addFieldBlocs(fieldBlocs: [fieldBloc]);
      await tester.pumpWidget(subject(animate: true));
      await settleInitialState(tester);
      expect(fieldHeight(tester), _fieldSize);

      formBloc.removeFieldBlocs(fieldBlocs: [fieldBloc]);
      await tester.pump(const Duration(milliseconds: 150));

      // The field must stay mounted to be animated out.
      expect(find.byKey(_fieldKey), findsOneWidget);
      expect(fieldHeight(tester), greaterThan(0.0));
      expect(fieldHeight(tester), lessThan(_fieldSize));

      await tester.pumpAndSettle();
      expect(find.byKey(_fieldKey), findsNothing);
    });

    testWidgets(
        'hides the field immediately when it is removed and the animations '
        'are disabled', (tester) async {
      formBloc.addFieldBlocs(fieldBlocs: [fieldBloc]);
      await tester.pumpWidget(subject(animate: false));
      await settleInitialState(tester);
      expect(find.byKey(_fieldKey), findsOneWidget);

      formBloc.removeFieldBlocs(fieldBlocs: [fieldBloc]);
      await tester.pump();

      expect(find.byKey(_fieldKey), findsNothing);
    });

    testWidgets(
        'keeps the field mounted when the transition cannot run, so it is '
        'never permanently hidden', (tester) async {
      await tester.pumpWidget(subject(animate: true, tickerEnabled: false));
      await settleInitialState(tester);

      formBloc.addFieldBlocs(fieldBlocs: [fieldBloc]);
      await tester.pump();

      // The ticker is muted, so the transition never advances and the field is
      // not visible yet, but it must already be part of the widget tree.
      expect(find.byKey(_fieldKey), findsOneWidget);
      expect(fieldHeight(tester), 0.0);

      await tester.pumpWidget(subject(animate: true));
      await tester.pumpAndSettle();

      expect(fieldHeight(tester), _fieldSize);
    });

    testWidgets('renders the field on the first frame when it is already added',
        (tester) async {
      formBloc.addFieldBlocs(fieldBlocs: [fieldBloc]);
      await tester.pumpWidget(subject(animate: true));

      expect(fieldHeight(tester), _fieldSize);
    });

    testWidgets(
        'keeps the field visible when the animations are enabled '
        'after being disabled', (tester) async {
      formBloc.addFieldBlocs(fieldBlocs: [fieldBloc]);
      await tester.pumpWidget(subject(animate: true, disableAnimations: true));
      await settleInitialState(tester);
      expect(fieldHeight(tester), _fieldSize);

      await tester.pumpWidget(subject(animate: true));
      await tester.pumpAndSettle();

      expect(fieldHeight(tester), _fieldSize);
    });
  });
}
```

Notes for the implementer:

* `tester.pump(const Duration(milliseconds: 20))` inside `settleInitialState` is what fires the 10 ms `Future.delayed` in `initState`; relying on `pumpAndSettle()` alone would make the tests depend on its clock advance.
* `fieldHeight` measures the render object of the `CanShowFieldBlocBuilder` element (the `SizeTransition`'s `ClipRect`), which reflects the reveal progress. Do not measure the inner `SizedBox`: it always keeps its own 100 px height inside the clipped `Align`.
* Tests 3, 6 and 8 fail against the current `c790265` code and pass after the fix; tests 1, 2, 4, 5 and 7 must keep passing (they are the guard rails for what `c790265` fixed).
* The snippet above was verified to parse, but the `dart format` "tall style" (Dart 3.7+) reflows the multi-line `testWidgets(...)` argument lists — after creating the file just run `dart format` on it and accept the reflow instead of hand-matching it.

## [Implementation Order]

1. **Snapshot the baseline.** With the current `c790265` code in place, add the test file exactly as specified above and run `flutter test` in `packages/flutter_bloc_form_plus`. Record which tests fail (expected: tests 3, 6 and 8) — this proves the tests encode the regression (Rule 9). Checkpoint: baseline failure list captured.
2. **Apply the state changes** in `lib/src/features/appear/can_show_field_bloc_builder.dart`: add `_animationDuration` and `_keepChild`; replace `_initVisibility` with `_syncWithFieldBloc`; add `_handleAnimationStatus`; register the status listener in `initState`; update `didUpdateWidget`; delete `_updateCanShow` and `_updateAnimation`.
3. **Update `_changeVisibility` and `build`** per [Functions]. Checkpoint: `dart analyze --fatal-infos --fatal-warnings lib` is clean.
4. **Run the suite** (`flutter test` in the package). All 8 tests must pass, including the three that failed at step 1. Checkpoint: green suite, nothing skipped.
5. **Format and re-analyze**: `dart format lib/src/features/appear/can_show_field_bloc_builder.dart test/features/appear/can_show_field_bloc_builder_test.dart`, then `dart analyze --fatal-infos --fatal-warnings lib test` (mirrors the CI steps used for the sibling package).
6. **Smoke-test the real UI**: run the conditional-fields example (`bloc_form_web_plus` or `packages/flutter_bloc_form_plus/example`), toggle the conditional field and verify the animated show/hide; repeat with the OS reduce-motion / "remove animations" setting enabled and with `animateWhenCanShow: false`. Checkpoint: animated show/hide works; instant show/hide with animations disabled; a field is never visible before it is added.
7. **Add the CHANGELOG entry** (`# Unreleased` → `## Fixed`) as described in [Files].

## Risks, edge cases and follow-ups

* **Deliberately unchanged**: the 10 ms initial-settle heuristic, the 300 ms duration, `TickerProviderStateMixin` (rather than `SingleTickerProviderStateMixin`), the `BlocListener` `listenWhen` predicate, and the public API.
* **Formatting scope**: run `dart format` only on the two touched files (Rule 3); formatting the whole `lib`/`test` of the package would create unrelated diffs.
* **Behavioural change for `builder` consumers**: while a field animates out, `builder` now receives `canShow: false` (it used to receive `true` until the transition ended). In-tree consumers are safe — `SimpleFieldBlocBuilder` only uses `canShow` to add/remove the `ScrollableFieldBlocTarget` wrapper — but this restores the pre-`c790265` shape of the widget tree during a transition and should be mentioned in the CHANGELOG for third-party builders.
* **Known limitation**: if a ticker stays muted forever (field permanently inside `TickerMode(enabled: false)`, e.g. an off-screen `IndexedStack` child), the field is mounted but not revealed until the ticker resumes. That is inherent to `SizeTransition`; with the fix the field is no longer lost once the ticker resumes.
* **Considered and rejected**: (a) switching `whenComplete` to `whenCompleteOrCancel` — fixes the hang but keeps the empty-box transition, the delayed pop-in and the future-driven hide path; (b) rewriting with `AnimatedSize`/`AnimatedSwitcher` — drops the fade and changes public visuals for more churn (Rule 2/3); (c) keeping `_canShow` as a post-animation flag — hides the true state from `builder` and keeps visibility coupled to the transition.
* **Same pattern elsewhere**: `whenComplete` on a `TickerFuture` exists only in this widget (`grep` over `packages/flutter_bloc_form_plus/lib`); `StepperFormBlocBuilder` and `TypeAheadField` already drive their animations with `MediaQuery`-based zero durations, so no other file needs the same treatment.

## Implementation notes (as built)

Deviations from the plan above, all verified by running the code:

* **Test pumping**: the plan's tests mutated the `FormBloc` and pumped once. Measured behaviour is that the state change reaches the `BlocListener` in a **microtask** (the first `pump()` only flushes it; the frame with the new state is the second `pump()`). The committed test file therefore uses a `toggleField(tester, add: bool)` helper that mutates and pumps twice, and the mid-transition assertions only assert `findsOneWidget` plus `fieldHeight < _fieldSize` (the first rendered frame of a transition has elapsed 0, so asserting an exact intermediate height is tick-order dependent and brittle).
* **Baseline (current `c790265` code)**: exactly 3 of the 8 tests fail — `mounts the field as soon as it is added…`, `keeps the field mounted when the transition cannot run…` and `keeps the field visible when the animations are enabled after being disabled`. All 8 pass after the fix. `hides the field when it is removed from the FormBloc` and `hides the field immediately … animations are disabled` pass on both revisions; they are guard rails for what `c790265` fixed (pre-`c790265` the animations-disabled path showed fields before add and never hid them).
* **Formatting**: `dart format` was applied to the two touched files; the tall-style formatter reflowed the multi-line `testWidgets(...)` argument lists as predicted.
* **Integration check**: a temporary widget test with the real `TextFieldBlocBuilder` (removed afterwards, not committed) confirmed 0 text fields before add → mounted during the show transition → 1 after → still mounted during the hide transition → 0 after settle, with no framework exceptions.
* **Not done**: no on-device/GUI smoke test was performed (headless environment). The equivalent behaviour is covered programmatically by the widget tests above; the manual step 6 of the implementation order is still worth doing on a real low-end device with reduce-motion enabled.
