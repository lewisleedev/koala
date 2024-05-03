import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pub_semver/pub_semver.dart';

import '../utils.dart';

Future<Map<String, dynamic>> _getLatestRelease({bool forced = false}) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  Dio dio = Dio();

  Box settingsBox = await Hive.openBox("settings");
  var checkHistory = await settingsBox.get("updateHistory");
  DateTime? lastChecked = checkHistory?["lastChecked"];

  if (lastChecked != null && !forced) {
    if (lastChecked.add(const Duration(hours: 24)).isAfter(DateTime.now())) {
      return {
        "status": checkHistory['result']['status'],
        "msg": checkHistory['result']['msg'],
        "url": checkHistory['result']['url'],
      };
    }
  } else {
    try {
      var ghReleaseRes = await dio
          .get("https://api.github.com/repos/lewisleedev/koala/releases");
      Map<String, dynamic> result;

      String ghVerString = ghReleaseRes.data[0]['tag_name'];
      String verString = packageInfo.version.toString();

      ghVerString =
          ghVerString.startsWith('v') ? ghVerString.substring(1) : ghVerString;

      Version ghVersion = Version.parse(ghVerString);
      Version localVersion = Version.parse(verString);

      if (ghVersion > localVersion) {
        result = {
          "status": 0,
          "msg": "업데이트가 있습니다\n(최신 릴리스: $ghVersion)",
          "url": ghReleaseRes.data[0]['html_url'],
        };
        await settingsBox.put(
            "updateHistory", {"lastChecked": DateTime.now(), "result": result});
        return result;
      } else {
        result = {
          "status": 1,
          "msg": "Koala가 최신 버전입니다!",
          "url": ghReleaseRes.data[0]['html_url']
        };
        await settingsBox.put(
            "updateHistory", {"lastChecked": DateTime.now(), "result": result});
        return result;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        return {
          "status": -1,
          "msg": "API call limit exceeded. Try again later...",
        };
      }
    } catch (e) {
      return {
        "status": -1,
        "msg": "An error occurred: $e",
      };
    }
  }
  return {"status": -1, "msg": "Unknown Error"};
}

class UpdateCheckerWidget extends StatefulWidget {
  const UpdateCheckerWidget({super.key});

  @override
  State<UpdateCheckerWidget> createState() => _UpdateCheckerWidgetState();
}

class _UpdateCheckerWidgetState extends State<UpdateCheckerWidget> {
  Future<Map<String, dynamic>> _data = _getLatestRelease();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _data,
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Stack(
                children: [
                  Card(
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        child: Column(
                          children: [
                            const SizedBox(
                              width: double.infinity,
                              child: Text("업데이트 확인",
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.left),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              snapshot.data!['msg'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            snapshot.data!['status'] == 0
                                ? const SizedBox(
                                    height: 16,
                                  )
                                : const SizedBox(),
                            snapshot.data!['status'] == 0
                                ? OutlinedButton(
                                    onPressed: () async {
                                      String url = snapshot.data!['url'];
                                      if (!await launchUrl(Uri.parse(url))) {
                                        if (!context.mounted) return;
                                        showSnackbar(
                                            context, 'Can\'t launch url');
                                      }
                                    },
                                    child: const Text("Github에서 다운받기"))
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      top: 3,
                      right: 3,
                      child: IconButton(
                          onPressed: () {
                            setState(() {
                              _data = _getLatestRelease(forced: true);
                            });
                          },
                          icon: const Icon(Icons.refresh)))
                ],
              ),
            );
          }
        } else {
          return const SizedBox(
            width: double.infinity,
            child: Center(
                child: Card(
                    child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator()),
                          ],
                        )))),
          );
        }
      },
    );
  }
}
