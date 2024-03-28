import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:june/june.dart';
import 'package:koala/app.dart';
import 'package:koala/main.dart';
import 'package:koala/services/login.dart';
import 'package:koala/views/login_view.dart';
import 'package:koala/widgets/check_update.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/data.dart';
import '../services/utils.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}


class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          UpdateCheckerWidget(),
          JuneBuilder(() => KoalaSessionVM(),
              builder: (vm) => ListTile(
                  leading: const Icon(Icons.light_mode),
                  title: const Text('Theme'),
                  subtitle: const Text('Change the theme of the app'),
                  trailing: Switch(
                    value: vm.isDarkMode,
                    onChanged: vm.switchTheme,
                  ))
          ),
          JuneBuilder(() => KoalaSessionVM(),
              builder: (vm) => ListTile(
                  leading: const Icon(Icons.school_rounded),
                  title: const Text('Campus'),
                  subtitle: const Text('Turn this on if you\'re at Global campus. Restart recommended.'),
                  trailing: Switch(
                    value: vm.isGlobalCampus,
                    onChanged: (bool b) {
                      vm.switchCampus(b);
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const KoalaApp(),
                          ),
                              (Route<dynamic> route) => false);
                    },
                  ))
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('View Licenses'),
            subtitle: const Text('See open source licenses'),
            onTap: () {
              showLicensePage(
                  context: context,
                  applicationIcon:
                      Image.asset("assets/icon/icon.png", width: 100),
                  applicationName: "Koala",
                  applicationLegalese:
                      "This app is free & open-sourced.\nLogo from Fluent Emoji");
            },
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Source code'),
            subtitle: const Text('Visit the GitHub repository'),
            onTap: () async {
              const url = 'https://github.com/lewisleedev/koala';
              if (!await launchUrl(Uri.parse(url))) {
                if (!context.mounted) return;
                showSnackbar(context, 'Can\'t launch url');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            subtitle: const Text('Sign out of your account'),
            onTap: () async {
              final Directory appDocumentsDir =
                  await getApplicationDocumentsDirectory();
              var cookieJar = PersistCookieJar(
                  storage: FileStorage("${appDocumentsDir.path}/cookie"));
              await cookieJar.deleteAll();
              var box = await openSafeBox();
              await box.clear();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginWidget(),
                  ),
                  (Route<dynamic> route) => false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh'),
            subtitle: const Text('Refresh your session'),
            onTap: () async {
              if (await refreshLogin() <= 0) {
                if (!context.mounted) return;
                Navigator.of(context).pop();
                showSnackbar(context,
                    "Session refreshed. It is recommended that you restart the app.");
              } else {
                if (!context.mounted) return;
                showSnackbar(context, "Something went wrong");
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: const Text('Report Bug'),
            subtitle: const Text('Via Github Issues'),
            onTap: () async {
              const url = 'https://github.com/lewisleedev/koala/issues';
              if (!await launchUrl(Uri.parse(url))) {
                if (!context.mounted) return;
                showSnackbar(context, 'Can\'t launch url');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Feedback'),
            subtitle: const Text('Let me know what you think.'),
            onTap: () async {
              const url = 'https://github.com/lewisleedev/koala/discussions';
              if (!await launchUrl(Uri.parse(url))) {
                if (!context.mounted) return;
                showSnackbar(context, 'Can\'t launch url');
              }
            },
          ),
        ],
      ),
    );
  }
}
