import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:koala/services/notification.dart';
import 'package:koala/theme.dart';
import 'package:koala/views/dashboard.dart';
import 'package:koala/views/login.dart';
import 'package:koala/views/widgets/error.dart';
import 'package:provider/provider.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'models/seat_selection_state.dart';
import 'models/session.dart';

enum LoginState {
  loggedIn,
  noInternet,
  invalidCredentials,
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Notification Stuff
  await NotifService().init();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation("Asia/Seoul"));

  // Session
  final KoalaSession session = KoalaSession();
  await session.initializeApp();
  runApp(InitialLoading(session: session));
}

class InitialLoading extends StatelessWidget {
  final KoalaSession session;
  const InitialLoading({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
          Provider<KoalaSession>(create: (_) => session),
          Provider<SeatSelectionState>(create: (_) => SeatSelectionState()),
      ],
      child: Observer(
        builder: (_) {
          late ThemeMode themeSetting;
          if (session.settings['isDarkTheme'] != Null &&
              session.settings['useDeviceTheme'] != Null) {
            if (session.getSetting("useDeviceTheme")) {
              themeSetting = ThemeMode.system;
            } else {
              themeSetting = session.getSetting("isDarkTheme") ?? false
                  ? ThemeMode.dark
                  : ThemeMode.light;
            }
          } else {
            themeSetting = ThemeMode.system;
          }
          return ThemeWrapper(
            themeSetting: themeSetting,
            app: FutureBuilder<bool>(
              future: session
                  .refreshLogin(), // Use the refreshLogin() method to check login state
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  if (snapshot.error is DioException) {
                    return const Scaffold(body: ErrorCantConnect());
                  }
                  return Scaffold(
                      body: ErrorBox(
                    errMsg: "${snapshot.error}",
                  ));
                } else if (snapshot.data == true) {
                  session.refreshDashboard();
                  return const KoalaApp();
                } else {
                  return const LoginForm();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
