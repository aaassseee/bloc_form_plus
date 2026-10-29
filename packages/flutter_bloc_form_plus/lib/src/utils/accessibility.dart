import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart' show ContentSensitivity;

/// Whether field visibility / transition animations should run.
bool shouldAnimateFieldTransitions(BuildContext context, bool animate) {
  if (!animate) return false;
  return !MediaQuery.disableAnimationsOf(context);
}

/// Scroll padding that keeps focused fields visible above mobile web keyboards.
EdgeInsets effectiveScrollPadding(BuildContext context, EdgeInsets scrollPadding) {
  if (!kIsWeb) return scrollPadding;

  const defaultPadding = EdgeInsets.all(20.0);
  if (scrollPadding != defaultPadding) return scrollPadding;

  return const EdgeInsets.fromLTRB(20, 40, 20, 80);
}

/// Wraps [child] with [SensitiveContent] when [enabled] on supported platforms.
///
/// On Android this hides content from screen capture while obscured. On other
/// platforms [child] is returned unchanged.
Widget wrapSensitiveContent({required bool enabled, required Widget child}) {
  if (!enabled) return child;

  return SensitiveContent(
    sensitivity: ContentSensitivity.sensitive,
    child: child,
  );
}

/// Exposes an indeterminate loading indicator to assistive technologies.
Widget semanticProgressIndicator({
  required Widget child,
  String label = 'Loading',
}) {
  return Semantics(
    label: label,
    value: label,
    child: ExcludeSemantics(child: child),
  );
}
