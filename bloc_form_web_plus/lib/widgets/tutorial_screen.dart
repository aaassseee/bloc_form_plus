import 'package:material_ui/material_ui.dart';
import 'package:bloc_form_web_plus/widgets/widgets.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({
    super.key,
    required this.children,
  });
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: <Widget>[
            ...children,
            const ShowAllCodeButton(),
          ],
        ),
      ),
    );
  }
}
