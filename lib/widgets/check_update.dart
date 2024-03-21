import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/utils.dart';


Future<Map<String, dynamic>> _getLatestRelease(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  Dio dio = Dio();

  try {
    var ghReleaseRes = await dio.get("https://api.github.com/repos/lewisleedev/koala/releases");
    String ghVerString = ghReleaseRes.data[0]['tag_name'];
    String verString = packageInfo.version.toString();

    ghVerString = ghVerString.startsWith('v') ? ghVerString.substring(1) : ghVerString;

    Version ghVersion = Version.parse(ghVerString);
    Version localVersion = Version.parse(verString);

    if (ghVersion > localVersion) {
      return {
        "status": 0,
        "msg": "Update Available\n(Latest Release: $ghVersion)",
        "url": ghReleaseRes.data[0]['html_url'],
      };
    } else {
      return {
        "status": 1,
        "msg": "You are up to date!",
        "url": ghReleaseRes.data[0]['html_url']
      };
    }
  } on DioException catch (e) {
    if (e.response?.statusCode == 403) {
      return {
        "status": -1,
        "msg": "API call limit exceeded. Try again later...",
      };
    } else {
      return {
        "status": -1,
        "msg": "An error occurred",
      };
    }
  }
}

class UpdateCheckerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getLatestRelease(context),
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                child: SizedBox(
                  width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      child: Column(
                        children: [
                          const SizedBox(
                            width: double.infinity,
                            child:
                            Text("Check Update", style: TextStyle(fontSize: 20), textAlign: TextAlign.left),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            snapshot.data!['msg'],
                            style: TextStyle(fontSize: 16),
                          ),
                          snapshot.data!['status'] == 0 ? const SizedBox(
                            height: 16,
                          ) : const SizedBox(),
                          snapshot.data!['status'] == 0 ? OutlinedButton(
                              onPressed: () async {
                                String url =
                                snapshot.data!['url'];
                                if (!await launchUrl(Uri.parse(url))) {
                                  if (!context.mounted) return;
                                  showSnackbar(
                                      context, 'Can\'t launch url');
                                }
                              },
                              child: const Text("Download at Github")
                          ) : const SizedBox(), // Is this the way to do this?
                        ],
                      ),
                    ),
                  ),
                ),
            );
          }
        } else {
          return const SizedBox(
            width: double.infinity,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}