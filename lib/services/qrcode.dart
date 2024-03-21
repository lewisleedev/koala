import 'package:dio/dio.dart';
import 'package:june/june.dart';
import 'package:koala/main.dart';
import 'package:koala/models/qrcode.dart';
import 'package:koala/services/data.dart';
import 'package:koala/services/login.dart';
import 'package:koala/services/utils.dart';

Future<EntryQRCode> getQRCode() async {
  if (await refreshLogin() > 0) {
    throw Exception("Login refresh failed");
  };
  var session = June.getState(KoalaSessionVM());
  Dio dio = session.dio;
  final mobileCardPageRes = await dio.get(
    "https://lib.khu.ac.kr/relation/mobileCard",
    options: Options(
      followRedirects: false,
      validateStatus: (status) => status! < 400,
    ),
  );

  final String midUserID = getMidUserID(mobileCardPageRes.data);

  final qrCodeRes = await dio.post(
    "https://lib.khu.ac.kr:8443/mconnect/makeCode",
    data: {"mid_user_id": midUserID},
    options: Options(
      followRedirects: false,
      validateStatus: (status) => status! < 400,
      headers: {'User-Agent': "Mozilla/5.0"},
      contentType: Headers.formUrlEncodedContentType,
    ),
  );
  String qrCode = extractQRText(qrCodeRes.data);

  var now = DateTime.now();
  DateTime expireDt = now.add(const Duration(minutes: 10));

  EntryQRCode res = EntryQRCode(qrCodeString: qrCode, expiresAt: expireDt.microsecondsSinceEpoch);

  return res;
}

Future<EntryQRCode> qrHandler({bool force = false}) async {
  // Hive box is used because it should save the data even when the app gets closed
  // Why not QRCode in box? Because I'm lazy and don't want to write code to make it work with Hive

  var box = await openSafeBox();
  var boxedQRData = await box.get("qrcode");

  DateTime? expiresAt;
  if (boxedQRData != null && boxedQRData['expires_at'] != null) {
    expiresAt = DateTime.fromMicrosecondsSinceEpoch(boxedQRData['expires_at']);
  }

  if (boxedQRData == null || expiresAt == null || DateTime.now().isAfter(expiresAt) || force) {
    var res = await getQRCode(); // This already handles session refresh.
    int expiresAtMicroseconds = res.expiresAt;
    await box.put("qrcode", {
      'qrcode': res.qrCodeString,
      'expires_at': expiresAtMicroseconds,
    });
    res.expiresAt = expiresAtMicroseconds;
    return EntryQRCode(qrCodeString: res.qrCodeString, expiresAt: res.expiresAt);
  } else {
    boxedQRData['expires_at'] = boxedQRData['expires_at']; // Already in epoch microseconds
    return EntryQRCode(qrCodeString: boxedQRData['qrcode'], expiresAt: boxedQRData['expires_at']);
  }
}
