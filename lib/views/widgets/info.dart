import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      appName = info.appName;
      packageName = info.packageName;
      version = info.version;
      buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Koala'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text('Koala', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("KHU's Opensource App for Library Access",
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text('v$version($buildNumber)',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              const Text('by @lewisleedev', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              const Text('Licensed under MPLv2', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 15),
              const Text('Koala 제작에 도움을 주신 분들',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              FutureBuilder(
                  future: _getSponsorsList(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done){
                      if (!snapshot.hasError && snapshot.hasData) {
                        List<Widget> sponsorsResult = [
                          for (var i in snapshot.data!) Text("${i?["name"]}", style: TextStyle(fontSize: 16),)
                        ];
                        return Column(
                          children: sponsorsResult,
                        );
                      } else {
                        return const Text("Something went wrong while fetching sponsors list");
                      }
                    } else {
                      return const Text("Loading...");
                    }
                  }),
              const SizedBox(height: 6),
              const Text('감사합니다!', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 22),
              Text('이 소프트웨어는 "있는 그대로" 제공되며, 명시적이거나 묵시적인 어떠한 종류의 보증도 없이, 상품성, 특정 목적에의 적합성, 비침해성을 포함하되 이에 국한되지 않는 보증을 포함하지 않습니다. 저작권자나 저자는 소프트웨어와 관련하여 또는 소프트웨어의 사용이나 기타 거래로 인해 발생하는 어떠한 청구, 손해 또는 기타 책임에 대해서도 계약, 불법 행위 또는 그 밖의 사유로 인해 어떠한 경우에도 책임을 지지 않습니다.', style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<dynamic>> _getSponsorsList() async {
  try {
    Dio dio = Dio();
    var res = await dio.get(
        "https://gist.githubusercontent.com/lewisleedev/fd89da10525bf9e6b51b3ddb89ef59c2/raw/00707ad97651815aec1fef457e29aae5a888013e/koala_sponsors");
    List<dynamic> sponsorsList = jsonDecode(res.data)["sponsors"];
    return sponsorsList;
  } catch (e) {
    rethrow;
  }
}
