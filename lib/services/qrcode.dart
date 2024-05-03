import 'package:dio/dio.dart';
import 'package:koala/services/utils.dart';
import '../models/session.dart';
import 'login.dart';

Future<EntryQRCode> getQRString(KoalaClient client) async {
  final mobileCardPageRes = await client.dio.get(
    "https://lib.khu.ac.kr/relation/mobileCard",
    options: Options(
      followRedirects: false,
      validateStatus: (status) => status! < 400,
    ),
  );

  final String midUserID = getMidUserID(mobileCardPageRes.data);

  final qrCodeRes = await client.dio.post(
    "https://lib.khu.ac.kr:8443/mconnect/makeCode",
    data: {"mid_user_id": midUserID},
    options: Options(
      followRedirects: false,
      validateStatus: (status) => status! < 400,
      headers: {'User-Agent': "Mozilla/5.0"},
      contentType: Headers.formUrlEncodedContentType,
    ),
  );
  String qrCodeString = extractQRText(qrCodeRes.data);
  EntryQRCode res = EntryQRCode(qrCodeString: qrCodeString);
  return res;
}
