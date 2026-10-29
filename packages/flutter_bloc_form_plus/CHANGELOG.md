# Unreleased

## Fixed

* **`CanShowFieldBlocBuilder`** — field visibility is now driven only by whether the `FieldBloc` is added to a `FormBloc`; it no longer depends on the show/hide transition finishing. A canceled or muted ticker (slow/low-end devices, reduce-motion, off-screen `TickerMode`) can no longer leave a field permanently hidden, and the show transition animates the field again instead of an empty box. With the animations disabled (`animateWhenCanShow: false` or reduce motion) fields are still shown/hidden instantly, and a field is never rendered before it is added to the form.
* **`CanShowFieldBlocBuilder`** — while a field animates out, the `builder` now receives `canShow: false` (previously `true` until the transition ended), and `didUpdateWidget` re-syncs the visibility when the `fieldBloc` changes.

# 0.3.0

Flutter **3.44.2** / Dart **3.12** release. Requires **`bloc_form_plus` ^0.3.0**.

## Added

### Cupertino & adaptive builders
* **`CupertinoTextFieldBlocBuilder`** — Cupertino-styled text field integrated with `TextFieldBloc`.
* **`CupertinoSwitchFieldBlocBuilder`** — Cupertino switch integrated with `BooleanFieldBloc`.
* **`AdaptiveTextFieldBlocBuilder`** — picks Cupertino or Material text field based on platform (`prefersCupertinoFields`).
* **`prefersCupertinoFields(BuildContext)`** — helper in `functions.dart` for platform-aware field selection.

### Accessibility utilities (`lib/src/utils/accessibility.dart`)
* **`shouldAnimateFieldTransitions()`** — respects `MediaQuery.disableAnimations` (reduce motion).
* **`effectiveScrollPadding()`** — larger default scroll padding on web to keep fields visible above mobile browser keyboards.
* **`wrapSensitiveContent()`** — wraps obscured fields with Flutter `SensitiveContent` on supported platforms (Android screen capture).
* **`semanticProgressIndicator()`** — exposes async validation / loading indicators to assistive technologies.

### Field builder enhancements
* **`TextFieldBlocBuilder.sensitiveContent`** — opt-in/out `SensitiveContent` for password and sensitive fields.
* **`StepperFormBlocBuilder.animateStepTransitions`** — controls step animations; disabled automatically when reduce motion is on.

## Changed

### Flutter 3.44 / API compatibility
* **`RadioGroupFieldBlocBuilder`** — migrated to Flutter `RadioGroup` API; inner `Radio` widgets no longer use deprecated `groupValue` / `onChanged`.
* **`RadioButtonGroupFieldBlocBuilder`** — wrapped in `RadioGroup`; same deprecated API cleanup.
* **`flutter_typeahead.dart`** — replaced deprecated `SizeTransition.axisAlignment` with `alignment: Alignment.topLeft`.
* Fixed **`unnecessary_underscores`** lints across builders (`checkbox_field_bloc_builder`, `filter_chip_field_bloc_builder`, `date_time_field_bloc_builder_base`, `checkbox_group_field_bloc_builder`, `group_view`, `switch_field_bloc_builder`, and others).

### Accessibility & UX
* **`TextFieldBlocBuilder`** — uses `effectiveScrollPadding` on web; wraps obscured text with `SensitiveContent`; semantic labels on async validation progress.
* **`CanShowFieldBlocBuilder`** — field show/hide transitions respect reduce motion via `shouldAnimateFieldTransitions`.
* **`StepperFormBlocBuilder`** — step transitions respect reduce motion.
* **`TypeAheadField`** — suggestion overlay animations respect reduce motion.

### Typeahead / mobile web keyboard
* **Removed `flutter_keyboard_visibility` dependency** — keyboard visibility on mobile web uses `View.of(context).viewInsets` in `didChangeMetrics` instead.
* Improved keyboard inset handling for suggestion overlay positioning.

### Dependencies
* **SDK constraint:** `>=3.8.0 <4.0.0`.
* **`bloc_form_plus`:** **^0.3.0** (includes `clearError`, `clearErrors`, `fields`).
* **`flutter_bloc`:** **^9.1.1**.
* **`equatable`:** **^2.0.8**.
* **`collection`:** **^1.19.1**.
* **`intl`:** **^0.20.2**.
* **`flutter_lints`:** **^6.0.0**.
* **Removed:** `flutter_keyboard_visibility`.

## Removed

* **`radio_group_field_bloc_v2.dart`** — duplicate; functionality consolidated into `radio_group_field_bloc.dart`.
* **`radio_group_field_bloc_v3.dart`** — duplicate; functionality consolidated into `radio_group_field_bloc.dart`.

## Demo / example apps

* **Android edge-to-edge** enabled in `flutter_bloc_form_plus/example` via `WindowCompat.setDecorFitsSystemWindows(window, false)` in `MainActivity.kt` (Flutter 3.44+ recommendation).

## Monorepo & tooling (repository)

* **FVM** pinned to Flutter **3.44.2** (`.fvmrc`).
* **Melos 7** workspace config moved to root `pubspec.yaml`; legacy `melos.yaml` removed.
* **Pub workspaces** with `resolution: workspace` across all packages.
* **CI** (`.github/workflows/bloc_form_plus.yml`, `bloc_form_plus_web.yml`) updated to Flutter **3.44.2** and `melos bootstrap`.
* Removed legacy **`pubspec_overrides.yaml`** files.

# 0.2.3

### Added
- **`showTitle` property** to `StepperFormBlocBuilder`
  - Default: `true` (backwards compatible).
  - Allows hiding stepper titles when set to `false`.
## Adds flexibility for cleaner UIs (e.g., when using a progress bar or when step labels are unnecessary).

### Example

```dart
StepperFormBlocBuilder<WizardFormBloc>(
  formBloc: context.read<WizardFormBloc>(),
  type: StepperType.horizontal,
  showTitle: false, // hides step titles
);
```


# 0.2.2

**Date:** 2025-09-20

**Changes:**

* **New Enum:** `RadioDirection`
  * Values: `left`, `right`, `top`, `bottom`
  * Allows controlling the **position of the label relative to the radio button**.

* **New Widget:** `RadioGroupFieldBlocBuilder`
  * Fully supports **label and radio alignment** using the `RadioDirection` enum.
  * Supports **group layout customization**:
    * `GridView Style` for multi-column layouts
    * `Wrap Stayle` for flexible, auto-wrapping items
    * `Flex style` for row or column alignment
  * Uses latest **RadioGroup features** from Flutter for selection, focus, and accessibility.

* **Customizable Features:**
  * Label and radio alignment controlled per item or globally.
  * Works with `FieldBloc` state for **reactive updates**.
  * Supports **validation and error messages** as in other FieldBloc builders.

* **Example Usage:**
```dart
RadioGroupFieldBlocBuilder<String>(
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
                          );

```

* **New Widget:** `RadioMenuButtonFieldBlocBuilder`
  * Provides a **Material 3 `RadioMenuButton` implementation** integrated with `FieldBloc`.
  * Supports reactive **selected value updates**, **validation**, and **customized labels**.
  * Works well for **dropdown-like radio selection menus** in forms.

# 0.1.2

*✅ Upgrade*
### Upgraded project to Flutter 3.32.0, ensuring compatibility with the latest Dart SDK and Flutter framework features.

## 🔁 Migration
* **`Migrated from deprecated:`**

* **`MaterialState → WidgetState`**

* **`MaterialStateProperty → WidgetStateProperty`**

* **`Replaced deprecated Opacity usage with modern withValues alternatives`**.

* **`Updated widget code to remove redundant constructors using super to streamline class initialization.`**

## 🧹 Cleanup
* **`Removed redundant constructor boilerplate by leveraging super where applicable.`**

* **`Fixed invalid use of private types in public APIs to comply with Dart 3+ type safety.`**

## 🐞 Fixes
Fixed common issue with BuildContext usage across async gaps, avoiding errors caused by calling context after await.

# 0.1.3
* **`Changed from InputDecorationTheme to InputDecorationThemeData`**

* **`Upgrade to support flutter 3.35`**
* **`Upgrade Bloc to latest version 9.1.1`**



# 0.1.0

Initial Version of the library.

