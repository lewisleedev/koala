import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:koala/services/notification.dart';
import 'package:koala/views/login.dart';
import 'package:koala/views/utils.dart';
import 'package:koala/views/widgets/info.dart';
import 'package:koala/views/widgets/update_checker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/session.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<KoalaSession>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: ListView(
          children: [
            UpdateCheckerWidget(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: const Text("앱 설정", style: TextStyle(fontSize: 16),),
            ),
            Observer(builder: (_) {
              bool isGlobalCampus = session.settings['isGCampus'];
              return ListTile(
                leading: const Icon(Icons.school),
                title: const Text('캠퍼스'),
                subtitle: const Text("캠퍼스를 변경합니다."),
                trailing: MenuAnchor(
                  builder: (BuildContext context, MenuController controller,
                      Widget? child) {
                    return FilledButton.tonal(
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        child: Text(isGlobalCampus ? "글로벌" : "서울"));
                  },
                  menuChildren: [
                    MenuItemButton(
                      child: const Text("서울"),
                      onPressed: () {
                        session.setSetting("isGCampus", false);
                        session.refreshDashboard();
                        Navigator.of(context).pop();
                        showSnackbar(context, "변경되었습니다");
                      },
                    ),
                    MenuItemButton(
                      child: const Text("글로벌"),
                      onPressed: () {
                        session.setSetting("isGCampus", true);
                        session.refreshDashboard();
                        Navigator.of(context).pop();
                        showSnackbar(context, "변경되었습니다");
                      },
                    )
                  ],
                ),
              );
            }),
            ListTile(
                leading: const Icon(Icons.brightness_7),
                title: const Text('QR코드 화면 밝기 조절'),
                subtitle: const Text("활성화 시 QR코드를 열 때마다 화면 밝기를 최대로 설정합니다"),
                trailing: Observer(
                  builder: (_) {
                    return Switch(
                        value: session.settings["changeBrightnessQr"]!,
                        onChanged: (bool b) {
                          session.setSetting("changeBrightnessQr", b);
                        });
                  },
                )),
            ListTile(
                leading: const Icon(Icons.notifications_active),
                title: const Text('이용시간 종료 임박 알람'),
                subtitle: const Text("이용시간 종료 약 30분 전에 알람을 울립니다."),
                trailing: Observer(
                  builder: (_) {
                    return Switch(
                        value: session.settings["useNotif"]!,
                        onChanged: (bool switchVal) async {
                          if (switchVal == true) {
                            bool permissionResult = await NotifService().askPermission();
                            if (!permissionResult) {
                              if (!context.mounted) return ;
                              showSnackbar(context, "알람 권한이 필요합니다. 설정에서 Koala의 알람권한을 허용해주세요.", duration: 5);
                            } else {
                              if (!context.mounted) return ;
                              showDialog(context: context, builder: (context) {
                                return const AlertDialog(
                                  title: Text("경고") ,
                                  content: Text("이 기능은 실험적 기능입니다. 배터리 최적화를 비활성화하는 것을 권장합니다.\n알람은 예기치 못하게 작동하지 않을 수 있습니다. 연장이 꼭 필요하다면 알람 여부와 관계없이 잊지 말고 연장해주세요!\n\nKoala 앱이 아닌 다른 경로를 통해 입실/퇴실 시 알람이 작동하지 않거나 오작동 할 수 있습니다"),
                                );
                              });
                              session.setSetting("useNotif", switchVal);
                            }
                          } else {
                            session.setSetting("useNotif", false);
                          }
                        });
                  },
                )),
            const Divider(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: const Text("디스플레이 설정", style: TextStyle(fontSize: 16),),
            ),
            ListTile(
                leading: const Icon(Icons.phonelink_setup_sharp),
                title: const Text('디바이스 테마 사용'),
                subtitle: const Text("다크모드 설정을 디바이스의 설정에 따릅니다"),
                trailing: Observer(
                  builder: (_) {
                    return Switch(
                        value: session.getSetting("useDeviceTheme")!,
                        onChanged: (bool b) {
                          session.setSetting("useDeviceTheme", b);

                        });
                  },
                )),
            Observer(builder: (_) {
              return !session.getSetting("useDeviceTheme")
                  ? ListTile(
                      leading: const Icon(Icons.light_mode),
                      title: const Text('다크 모드'),
                      subtitle: const Text('다크모드를 설정합니다'),
                      trailing: Switch(
                          value: session.getSetting("isDarkTheme") ?? false,
                          onChanged: (bool b) {
                            session.setSetting("isDarkTheme", b);
                          }))
                  : Container();
            }),
            const Divider(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: const Text("세션 설정", style: TextStyle(fontSize: 16),),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('로그아웃'),
              subtitle: const Text("기기에 저장된 정보와 세션을 삭제합니다. 재로그인이 필요합니다."),
              onTap: () async {
                session.logout();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {return const LoginForm();}), (route) => false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh_sharp),
              title: const Text('세션 새로고침'),
              subtitle: const Text("저장된 정보로 로그인을 재시도합니다. 많은 경우 세션을 새로고쳐 인증 오류를 해결 할 수 있습니다."),
              onTap: () async {
                session.refreshLogin();
                session.refreshDashboard();
                Navigator.of(context).pop();
                showSnackbar(context, "새로고침 되었습니다");
              },
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: const Text("앱 정보", style: TextStyle(fontSize: 16),),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text("오픈소스 라이센스"),
              subtitle: const Text("Koala에 사용된 오픈소스 라이브러리의 라이센스입니다."),
              onTap: () {
                showLicensePage(
                    context: context,
                    applicationIcon:
                        Image.asset("assets/images/logo.png", width: 100),
                    applicationName: "Koala",
                    applicationLegalese:
                        "This app is free & open-sourced.\nLogo from Fluent Emoji");
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('소스코드'),
              subtitle: const Text('Github Repo'),
              onTap: () async {
                const url = 'https://github.com/lewisleedev/koala';
                if (!await launchUrl(Uri.parse(url))) {
                  if (!context.mounted) return;
                  showSnackbar(context, 'Can\'t launch url');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('버그 신고'),
              subtitle: const Text('버그를 발견하셨다면 알려주세요'),
              onTap: () async {
                const url = 'https://github.com/lewisleedev/koala/issues';
                if (!await launchUrl(Uri.parse(url))) {
                  if (!context.mounted) return;
                  showSnackbar(context, 'Can\'t launch url');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("정보"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => InfoPage()));
              },
            ),
          ],
        ));
  }
}
