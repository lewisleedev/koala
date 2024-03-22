import 'package:dio/dio.dart';
import 'package:june/june.dart';
import 'package:koala/main.dart';
import 'package:koala/models/rooms.dart';
import 'package:koala/services/utils.dart';

Future<List<dynamic>> getLibraryStatus() async {
  var session = June.getState(KoalaSessionVM());
  Dio dio = await newDioClient();
  final libStatusRes = await dio.get(
    "https://libseat.khu.ac.kr/libraries/lib-status/${session.isGlobalCampus ? 2 : 1}", // so clean
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
            'maxMi': item['maxMi'],
            'maxRenewMi': item['maxRenewMi']
          })
      .toList();
  return parsedData.sublist(0, session.isGlobalCampus? 4 : 5);
}
Future<List<Map<String, dynamic>>> libraryStatusHandler() async {
  List<dynamic> statusData = await getLibraryStatus();
  List<Map<String, dynamic>> handledData = [];

  for (var status in statusData) {
    LibraryRoom? room = findLibraryRoomByCode(status['code']);
    if (room != null) {
      Map<String, dynamic> roomData = {
        'code': status['code'],
        'name': status['name'],
        'nameEng': status['nameEng'],
        'available': status['available'],
        'inUse': status['inUse'],
        'fix': status['fix'],
        'disabled': status['disabled'],
        'dayOff': status['dayOff'],
        'maxMi': status['maxMi'],
        'maxRenewMi': status['maxRenewMi'],
        'fromHour': room.fromHour,
        'untilHour': room.untilHour,
        'is24hour': room.is24hour,
        'imagePath': room.imagePath,
      };
      handledData.add(roomData);
    }
  }
  return handledData;
}