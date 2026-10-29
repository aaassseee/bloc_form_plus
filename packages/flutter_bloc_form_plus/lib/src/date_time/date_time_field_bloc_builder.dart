import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc_form_plus/src/date_time/date_time_field_bloc_builder_base.dart';
import 'package:flutter_bloc_form_plus/src/utils/utils.dart';
import 'package:bloc_form_plus/bloc_form.dart';
import 'package:intl/intl.dart' show DateFormat;

export 'package:intl/intl.dart' show DateFormat;

class DateTimeFieldBlocBuilder extends StatelessWidget {
  const DateTimeFieldBlocBuilder({
    super.key,
    required this.dateTimeFieldBloc,
    required this.format,
    this.canSelectTime = false,
    this.enableOnlyWhenFormBlocCanSubmit = false,
    this.isEnabled = true,
    this.errorBuilder,
    this.padding,
    this.decoration = const InputDecoration(),
    this.textAlign,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.initialTime,
    this.selectableDayPredicate,
    this.locale,
    this.textDirection,
    this.pickerBuilder,
    this.useRootNavigator = false,
    this.routeSettings,
    this.animateWhenCanShow = true,
    this.showClearIcon = true,
    this.clearIcon,
    this.nextFocusNode,
    this.focusNode,
    this.textStyle,
    this.textColor,
  });

  /// {@macro flutter_bloc_form_plus.FieldBlocBuilder.fieldBloc}
  final InputFieldBloc<DateTime?, dynamic> dateTimeFieldBloc;

  /// For representing the date as a string e.g.
  /// `DateFormat("EEEE, MMMM d, yyyy 'at' h:mma")`
  /// (Sunday, June 3, 2018 at 9:24pm)
  final DateFormat format;

  /// {@macro flutter_bloc_form_plus.FieldBlocBuilder.errorBuilder}
  final FieldBlocErrorBuilder? errorBuilder;

  /// {@macro flutter_bloc_form_plus.FieldBlocBuilder.enableOnlyWhenFormBlocCanSubmit}
  final bool enableOnlyWhenFormBlocCanSubmit;

  /// {@macro flutter_bloc_form_plus.FieldBlocBuilder.isEnabled}
  final bool isEnabled;

  /// {@macro flutter_bloc_form_plus.FieldBlocBuilder.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro flutter_bloc_form_plus.FieldBlocBuilder.decoration}
  final InputDecoration decoration;

  final bool canSelectTime;

  /// {@macro  flutter_bloc_form_plus.FieldBlocBuilder.animateWhenCanShow}
  final bool animateWhenCanShow;

  /// {@macro flutter_bloc_form_plus.FieldBlocBuilder.nextFocusNode}
  final FocusNode? nextFocusNode;

  /// {@macro flutter_bloc_form_plus.FieldBlocBuilder.focusNode}
  final FocusNode? focusNode;

  /// {@macro flutter_bloc_form_plus.FieldBlocBuilder.textAlign}
  final TextAlign? textAlign;

  /// {@macro flutter_bloc_form_plus.FieldBlocBuilder.textStyle}
  final TextStyle? textStyle;

  /// {@macro flutter_bloc_form_plus.FieldBlocBuilder.textColor}
  final WidgetStateProperty<Color?>? textColor;

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final SelectableDayPredicate? selectableDayPredicate;
  final DatePickerMode initialDatePickerMode = DatePickerMode.day;
  final Locale? locale;
  final TextDirection? textDirection;
  final TransitionBuilder? pickerBuilder;
  final bool useRootNavigator;
  final RouteSettings? routeSettings;
  final TimeOfDay? initialTime;

  /// Defaults `true`
  final bool? showClearIcon;

  /// Defaults `const Icon(Icons.clear)`
  final Widget? clearIcon;

  @override
  Widget build(BuildContext context) {
    return DateTimeFieldBlocBuilderBase<DateTime?>(
      dateTimeFieldBloc: dateTimeFieldBloc,
      format: format,
      type: canSelectTime
          ? DateTimeFieldBlocBuilderBaseType.both
          : DateTimeFieldBlocBuilderBaseType.date,
      decoration: decoration,
      enableOnlyWhenFormBlocCanSubmit: enableOnlyWhenFormBlocCanSubmit,
      errorBuilder: errorBuilder,
      isEnabled: isEnabled,
      padding: padding,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: pickerBuilder,
      locale: locale,
      routeSettings: routeSettings,
      selectableDayPredicate: selectableDayPredicate,
      useRootNavigator: useRootNavigator,
      textDirection: textDirection,
      animateWhenCanShow: animateWhenCanShow,
      clearIcon: clearIcon,
      showClearIcon: showClearIcon,
      nextFocusNode: nextFocusNode,
      focusNode: focusNode,
      textAlign: textAlign,
      textStyle: textStyle,
      textColor: textColor,
    );
  }
}
