import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:june/june.dart';
import 'package:koala/services/login.dart';
import 'package:koala/views/login_view.dart';
import 'package:koala/views/main_view.dart';
import 'package:koala/widgets/qrcode_widget.dart';
import 'package:koala/widgets/user_status_widget.dart';

const _khred = Color.fromARGB(1, 255, 0, 1);

class KoalaApp extends StatelessWidget {
  const KoalaApp({super.key});

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
        title: 'Koala',
        theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
        darkTheme: ThemeData(colorScheme: darkColorScheme, useMaterial3: true),
        home: const InitialLoadingPage(),
      );
    });
  }
}

class InitialLoadingPage extends StatefulWidget {
  const InitialLoadingPage({super.key});

  @override
  State<InitialLoadingPage> createState() => _InitialLoadingPageState();
}

class _InitialLoadingPageState extends State<InitialLoadingPage> {
  bool _hasCredentials = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCredentials();
  }

  Future<void> _checkCredentials() async {
    int loginRes = await refreshLogin();
    if (!mounted) return;
    if (loginRes <= 0) {
      var statusVM = June.getState(UserStatusVM());
      await statusVM.updateStatus();
      if (!mounted) return;
      setState(() {
        _hasCredentials = true;
        _isLoading = false;
      });
      statusVM.setState();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainWidget(),
        ),
      );
    } else {
      setState(() {
        _hasCredentials = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading) {
      if (!_hasCredentials) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginWidget(),
            ),
          );
        });
        return Scaffold(body: Container());
      } else {
        return const Scaffold(
          body: Center(
            child: Column(
              children: [],
            ),
          ),
        );
      }
    } else {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
