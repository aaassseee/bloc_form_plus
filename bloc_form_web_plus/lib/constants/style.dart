import 'package:material_ui/material_ui.dart';

final colors = <Color>[Color(0xff246bad), Color(0xff2164a4)];
final colors2 = <Color>[
  Colors.white,
  Colors.blueAccent.withAlpha(10),
];

final mainGradient = LinearGradient(colors: colors);

final drawerBodyGradient =
    LinearGradient(colors: colors2);

final scaffoldBodyGradient = LinearGradient(colors: colors);

bool displayMobileLayout(BuildContext context) =>
    MediaQuery.of(context).size.width < 720;
