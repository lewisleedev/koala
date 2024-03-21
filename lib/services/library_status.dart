import 'package:dio/dio.dart';
import 'package:koala/services/utils.dart';

Future<List<dynamic>> getLibraryStatus() async {
  Dio dio = await newDioClient();
  final libStatusRes = await dio.get(
    "https://libseat.khu.ac.kr/libraries/lib-status/1",
    options: Options(
      followRedirects: false,
      validateStatus: (status) => status == 200,
    ),
  );
  if (libStatusRes.data['code'] != 1) {
    throw Exception("Error while fetching library status");
  }
  var parsedData = libStatusRes.data['data']
      .map((item) => {
            'code': item['code'],
            'name': item['name'],
            'nameEng': item['nameEng'],
            'available': item['available'],
            'inUse': item['inUse'],
            'fix': item['fix'],
            'disabled': item['disabled'],
            'dayOff': item['dayOff'],
            'backgroundImg': item['bgImg'],
            'maxMi': item['maxMi'],
            'maxRenewMi': item['maxRenewMi']
          })
      .toList();

  return parsedData.sublist(0, 5);
}
