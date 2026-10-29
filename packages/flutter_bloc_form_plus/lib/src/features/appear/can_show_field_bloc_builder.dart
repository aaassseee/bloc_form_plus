import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_form_plus/src/utils/accessibility.dart';
import 'package:bloc_form_plus/bloc_form.dart';

class CanShowFieldBlocBuilder extends StatefulWidget {
  const CanShowFieldBlocBuilder({
    super.key,
    required this.fieldBloc,
    required this.builder,
    this.animate = true,
  });

  final FieldBloc fieldBloc;
  final bool animate;
  final Widget Function(BuildContext context, bool canShow) builder;

  @override
  State<CanShowFieldBlocBuilder> createState() =>
      _CanShowFieldBlocBuilderState();
}

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
  ///
  /// It is used for the initial state and whenever the transitions must not be
  /// used, in these cases the field is shown/hidden on the spot and the
  /// animation is kept in sync with it.
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
