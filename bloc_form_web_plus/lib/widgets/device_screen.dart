import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

class DeviceScreen extends StatelessWidget {
  final Widget app;

  const DeviceScreen({
    super.key,
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height - (kIsWeb ? 135 : 160);
    height = height < 480 ? 480 : height;

    final width = MediaQuery.of(context).size.width > 350.0
        ? 350.0
        : MediaQuery.of(context).size.width;

    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Transform.scale(
                scale: kIsWeb ? 0.95 : 1.0,
                child: SizedBox(
                  height: height,
                  width: width,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    elevation: 2.0,
                    margin: const EdgeInsets.all(kIsWeb ? 0 : 15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: MaterialApp(
                        home: app,
                        theme: ThemeData(
                          fontFamily: 'JosefinSans',
                          // Slightly smaller icons avoid 2px InputDecorator
                          // prefix/suffix overflow in the 350px device frame.
                          iconTheme: const IconThemeData(size: 20),
                          inputDecorationTheme: const InputDecorationTheme(
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                            suffixIconConstraints: BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                          ),
                        ),
                        debugShowCheckedModeBanner: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
