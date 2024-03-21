import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

Future<Box> openSafeBox() async {
  const secureStorage = FlutterSecureStorage();
  final encryptionKeyString = await secureStorage.read(key: 'key');
  if (encryptionKeyString == null) {
    final key = Hive.generateSecureKey();
    await secureStorage.write(
      key: 'key',
      value: base64UrlEncode(key),
    );
  }
  final key = await secureStorage.read(key: 'key');
  final encryptionKeyUint8List = base64Url.decode(key!);
  final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  final encryptedBox = await Hive.openBox('safeBox',
      path: appDocumentsDir.path.toString(),
      encryptionCipher: HiveAesCipher(encryptionKeyUint8List));

  return encryptedBox;
}
