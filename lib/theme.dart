import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

const _khred = Color.fromARGB(1, 157,28, 32);

class ThemeWrapper extends StatelessWidget{
  final Widget app;
  late ThemeMode themeSetting;

  ThemeWrapper({super.key, required this.app, required this.themeSetting});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          ColorScheme lightColorScheme;
          ColorScheme darkColorScheme;
          if (lightDynamic != null && darkDynamic != null) {
            lightColorScheme = lightDynamic.harmonized();
            lightColorScheme = lightColorScheme.copyWith(secondary: _khred);

            darkColorScheme = darkDynamic.harmonized();
            darkColorScheme = darkColorScheme.copyWith(secondary: _khred);
          } else {
            lightColorScheme = ColorScheme.fromSeed(
              seedColor: _khred,
            );
            darkColorScheme = ColorScheme.fromSeed(
              seedColor: _khred,
              brightness: Brightness.dark,
            );
          }
          return MaterialApp(
            theme: ThemeData.from(colorScheme: lightColorScheme),
            darkTheme: ThemeData.from(colorScheme: darkColorScheme),
            themeMode: themeSetting,
            home: app
          );
        }
    );
  }
}