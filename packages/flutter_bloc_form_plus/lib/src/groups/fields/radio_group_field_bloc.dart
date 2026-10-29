import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc_form_plus/flutter_bloc_form.dart';
import 'package:flutter_bloc_form_plus/src/theme/field_theme_resolver.dart';

enum RadioDirection { left, right, top, bottom }

class RadioGroupFieldBlocBuilder<Value> extends StatelessWidget {
  const RadioGroupFieldBlocBuilder({
    super.key,
    required this.selectFieldBloc,
    required this.itemBuilder,
    this.direction = RadioDirection.left,
    this.isEnabled = true,
    this.padding = const EdgeInsets.symmetric(vertical: 4.0),
    this.radioSize = 24.0,
    this.labelStyle,
    this.spacing = 8.0,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.canDeselect,
    this.decoration = const InputDecoration(),
    this.nextFocusNode,
    this.animateWhenCanShow = true,
    this.textStyle,
    this.textColor,
    this.groupStyle = const FlexGroupStyle(),
    this.canTapItemTile,
    this.mouseCursor,
    this.fillColor,
    this.overlayColor,
    this.splashRadius,
  });

  final SelectFieldBloc<Value, dynamic> selectFieldBloc;
  final FieldItemBuilder<Value> itemBuilder;
  final RadioDirection direction;
  final bool isEnabled;
  final EdgeInsetsGeometry padding;
  final double radioSize;
  final TextStyle? labelStyle;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool? canDeselect;
  final InputDecoration decoration;
  final FocusNode? nextFocusNode;
  final bool animateWhenCanShow;
  final TextStyle? textStyle;
  final WidgetStateProperty<Color?>? textColor;
  final GroupStyle groupStyle;
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
      child: CanShowFieldBlocBuilder(
        fieldBloc: selectFieldBloc,
        animate: animateWhenCanShow,
        builder: (_, _) {
          return BlocBuilder<SelectFieldBloc<Value, dynamic>,
              SelectFieldBlocState<Value, dynamic>>(
            bloc: selectFieldBloc,
            builder: (context, state) {
              return RadioGroup<Value>(
                groupValue: state.value,
                onChanged: (value) {
                  if (!isEnabled) return;
                  selectFieldBloc.changeValue(value);
                },
                child: GroupView(
                  style: groupStyle,
                  padding: padding,
                  count: state.items.length,
                  builder: (context, index) {
                    final item = state.items[index];

                    final fieldItem = DefaultTextStyle(
                      style: labelStyle ??
                          Theme.of(context).textTheme.bodyMedium!,
                      child: itemBuilder(context, item),
                    );

                    final radio = Transform.scale(
                      scale: radioSize / 24.0,
                      child: Radio<Value>(
                        value: item,
                        toggleable: fieldTheme.canDeselect,
                      ),
                    );

                    Widget content;
                    switch (direction) {
                      case RadioDirection.left:
                        content = Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: mainAxisAlignment,
                          crossAxisAlignment: crossAxisAlignment,
                          children: [
                            radio,
                            SizedBox(width: spacing),
                            fieldItem,
                          ],
                        );
                        break;
                      case RadioDirection.right:
                        content = Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: mainAxisAlignment,
                          crossAxisAlignment: crossAxisAlignment,
                          children: [
                            fieldItem,
                            SizedBox(width: spacing),
                            radio,
                          ],
                        );
                        break;
                      case RadioDirection.top:
                        content = Column(
                          mainAxisAlignment: mainAxisAlignment,
                          crossAxisAlignment: crossAxisAlignment,
                          children: [
                            radio,
                            SizedBox(height: spacing),
                            fieldItem,
                          ],
                        );
                        break;
                      case RadioDirection.bottom:
                        content =  Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: mainAxisAlignment,
                          crossAxisAlignment: crossAxisAlignment,
                          children: [
                            Column(
                              children: [
                                fieldItem,
                              ],
                            ),
                            SizedBox(height: spacing),
                            radio,
                          ],
                        );
                        break;
                    }

                    return InkWell(
                      onTap: isEnabled
                          ? () {
                              if (fieldTheme.canDeselect &&
                                  state.value == item) {
                                selectFieldBloc.changeValue(null);
                              } else {
                                selectFieldBloc.changeValue(item);
                              }
                            }
                          : null,
                      child: content,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
