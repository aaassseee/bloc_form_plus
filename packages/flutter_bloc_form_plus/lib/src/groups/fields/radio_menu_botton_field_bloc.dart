import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc_form_plus/flutter_bloc_form.dart';
import 'package:flutter_bloc_form_plus/src/theme/field_theme_resolver.dart';

/// A [RadioMenuButton] group powered by [SelectFieldBloc].
///
/// Displays a menu with radio items, automatically managing selection via BLoC.
class RadioMenuButtonFieldBlocBuilder<Value> extends StatelessWidget {
  const RadioMenuButtonFieldBlocBuilder({
    super.key,
    required this.selectFieldBloc,
    required this.itemBuilder,
    required this.menuLabel,
    this.direction = Axis.vertical,
    this.spacing = 8.0,
    this.padding = const EdgeInsets.symmetric(vertical: 4.0),
    this.radioSize = 24.0,
    this.menuButtonStyle,
    this.menuButtonFocusNode,
    this.isEnabled = true,
    this.labelStyle,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.canDeselect,
     this.decoration = const InputDecoration(),
    this.nextFocusNode,
     this.animateWhenCanShow = true,
    this.textStyle, this.textColor,
    // required this.groupStyle,
    this.canTapItemTile,
    this.mouseCursor,
    this.fillColor,
    this.overlayColor,
    this.splashRadius,
  });

  /// The BLoC that manages selection.
  final SelectFieldBloc<Value, dynamic> selectFieldBloc;

  /// Builds a widget for each menu item.
  final FieldItemBuilder<Value> itemBuilder;

  /// Label for the menu button.
  final Widget menuLabel;

  /// Layout direction of menu items (vertical / horizontal)
  final Axis direction;

  /// Spacing between menu items
  final double spacing;

  /// Padding around each menu item
  final EdgeInsetsGeometry padding;

  /// Size of the radio buttons
  final double radioSize;

  /// Optional style for the menu button
  final ButtonStyle? menuButtonStyle;

  /// Optional focus node for the menu button
  final FocusNode? menuButtonFocusNode;

  /// Whether the menu items are enabled
  final bool isEnabled;



  final TextStyle? labelStyle;

  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool? canDeselect;
  final InputDecoration decoration;
  final FocusNode? nextFocusNode;
  final bool animateWhenCanShow;
  final TextStyle? textStyle;
  final WidgetStateProperty<Color?>? textColor;
  //final GroupStyle groupStyle;
  final bool? canTapItemTile;
  final WidgetStateProperty<MouseCursor?>? mouseCursor;
  final WidgetStateProperty<Color?>? fillColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final double? splashRadius;

  RadioFieldTheme themeStyleOf(BuildContext context) {
    final theme = Theme.of(context);
    final formTheme = FormTheme.of(context);
    final fieldTheme = formTheme.radioTheme;
    final resolver = FieldThemeResolver(theme, formTheme, fieldTheme);
    final radioTheme = fieldTheme.radioTheme ?? theme.radioTheme;

    return RadioFieldTheme(
      decorationTheme: resolver.decorationTheme,
      textStyle: textStyle ?? resolver.textStyle,
      textColor: textColor ?? resolver.textColor,
      radioTheme: radioTheme.copyWith(
        mouseCursor: mouseCursor,
        fillColor: fillColor,
        overlayColor: overlayColor,
        splashRadius: splashRadius,
      ),
      canDeselect: canDeselect ?? fieldTheme.canDeselect,
      canTapItemTile: canTapItemTile ?? fieldTheme.canTapItemTile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldTheme = themeStyleOf(context);

    return Theme(
      data: Theme.of(context).copyWith(radioTheme: fieldTheme.radioTheme),
      child: MenuAnchor(
        childFocusNode: menuButtonFocusNode,
        builder: (context, controller, child) {
          return TextButton(
            style: menuButtonStyle,
            focusNode: menuButtonFocusNode,
            onPressed: () {
              controller.isOpen ? controller.close() : controller.open();
            },
            child: menuLabel,
          );
        },
        menuChildren: [
          BlocBuilder<SelectFieldBloc<Value, dynamic>, SelectFieldBlocState<Value, dynamic>>(
            bloc: selectFieldBloc,
            builder: (context, state) {
              return direction == Axis.vertical
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: state.items.map((item) {
                  final label = itemBuilder(context, item);

                  return Padding(
                    padding: padding,
                    child: RadioMenuButton<Value>(
                      value: item,
                      groupValue: state.value,
                      onChanged: isEnabled
                          ? (value) => selectFieldBloc.changeValue(value)
                          : null,
                      // Scale radio size
                      // style: ButtonStyle.styleFrom(
                      //   iconSize: radioSize,
                      // ),
                      child: label,
                    ),
                  );
                }).toList(),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: state.items.map((item) {
                  final label = itemBuilder(context, item);

                  return Padding(
                    padding: padding,
                    child: RadioMenuButton<Value>(
                      value: item,
                      groupValue: state.value,
                      onChanged: isEnabled
                          ? (value) => selectFieldBloc.changeValue(value)
                          : null,
                      child: label,
                      // style: RadioMenuButton.styleFrom(
                      //   iconSize: radioSize,
                      // ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
