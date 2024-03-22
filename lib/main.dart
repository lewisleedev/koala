import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:june/june.dart';
import 'package:koala/services/data.dart';
import 'package:koala/services/login.dart';
import 'package:koala/services/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

import 'app.dart';

class KoalaSessionVM extends JuneState {
  late CookieJar cookieJar;
  late Dio dio;
  late Box<dynamic> box;
  late bool isGlobalCampus;
  late bool isDarkMode;

  initialize() async {
    dio = await newDioClient();
    cookieJar = await setupCookieManager(dio);
    box = await openSafeBox();
    isDarkMode = box.get('darkMode') ?? ThemeMode.system == ThemeMode.dark ? true : false;
    isGlobalCampus = box.get('campus') ?? false;
    setState();
  }

  switchTheme(bool darkMode) {
    box.put('darkMode', darkMode);
    isDarkMode = darkMode;
    setState();
  }

  switchCampus(bool b) {
    box.put('campus', b);
    isGlobalCampus = b;
    setState();
  }

  refreshSession() async {
    await refreshLogin();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentsDir.path.toString());
  final session = June.getState(KoalaSessionVM());
  await session.initialize();

  runApp(const KoalaApp());
}
