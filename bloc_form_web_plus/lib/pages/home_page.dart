import 'package:auto_size_text/auto_size_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:bloc_form_web_plus/constants/style.dart';
import 'package:bloc_form_web_plus/routes.dart';
import 'package:bloc_form_web_plus/widgets/app_scaffold.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showParticlesBackground: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: displayMobileLayout(context)
            ? Builder(
                builder: (context) {
                  return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      });
                },
              )
            : null,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                AutoSizeText(
                  'bloc_form',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 100,
                    color: Colors.white.withAlpha(225),
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 6),
                _buildText('Easy Form State Management using BLoC pattern.'),
                const SizedBox(height: 6),
                _buildText(
                    'Separate the form state and Business Logic from the User Interface.'),
                const SizedBox(height: 12),
                Text(
                  'v0.3.0 · Flutter 3.44.2',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
                const SizedBox(height: 40),
                _buildText('bloc_form uses '),
                _buildText('Bloc Library', url: 'https://bloclibrary.dev/'),
                const SizedBox(height: 40),
                SizedBox(
                  height: 50,
                  width: 250,
                  child: TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(RouteNames.whatsNewExample),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(
                          width: 2,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                      child: const Text(
                        'WHAT\'S NEW 0.3.0',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  width: 250,
                  child: TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(RouteNames.simpleExample),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black38, shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: const BorderSide(
                          width: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
                      child: const Text(
                        'GET STARTED',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildText(String text, {String? url}) {
    return GestureDetector(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          color: Colors.white.withAlpha(225),
          decoration: url == null ? null : TextDecoration.underline,
        ),
      ),
      onTap: () async {
        final Uri urlPath = Uri.parse(url!);
        if (await canLaunchUrl(urlPath)) {
          await launchUrl(urlPath);
        }
      },
    );
  }
}
