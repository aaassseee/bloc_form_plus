import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc_form_plus/flutter_bloc_form.dart';
import 'package:bloc_form_web_plus/pages/home_page.dart';
import 'package:bloc_form_web_plus/routes.dart';
import 'package:bloc_form_web_plus/super_bloc_delegate.dart';

void main() {
  Bloc.observer = SuperBlocDelegate();
  runApp(const App());

}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bloc_form',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        primaryColor: Colors.blueAccent,
        fontFamily: 'JosefinSans',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: RouteNames.home,
      routes: routes,
      onUnknownRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }
}
