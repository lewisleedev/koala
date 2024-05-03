
import 'package:dio/dio.dart';
import 'package:koala/services/utils.dart';

import 'login.dart';

Future<List<dynamic>> getLibraryStatus(bool isGlobalCampus) async {
  try {
    KoalaClient client = await newDioClient();
    final libStatusRes = await client.dio.get(
      "https://libseat.khu.ac.kr/libraries/lib-status/${isGlobalCampus ? 2 : 1}", // so clean
      options: Options(
        followRedirects: false,
        validateStatus: (status) => status == 200,
      ),
    );
    if (libStatusRes.data['code'] != 1) {
      throw Exception("Error while fetching library status");
    }
    List<dynamic> parsedData = libStatusRes.data['data']
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
      'maxRenewMi': item['maxRenewMi'],
      'startTm': item['startTm'],
      'endTm': item['endTm'],
      'usageTimeString': formatUsageTime(item['startTm'], item['endTm']),
      'isAvailable': isCurrentlyAvailable(item['startTm'], item['endTm']),
      'bgImg': parseImagePath(item['bgImg'])
    })
        .toList();
    if (!isGlobalCampus) { // 의학전용도서관
      parsedData.removeRange(5, 7);
    }
    return parsedData;
  } catch (e) {
    rethrow;
  }
}

bool isCurrentlyAvailable(String startTime, String endTime) {
  int startHour = int.parse(startTime.substring(0, 2));
  int startMinute = int.parse(startTime.substring(2, 4));
  int endHour = int.parse(endTime.substring(0, 2));
  int endMinute = int.parse(endTime.substring(2, 4));

  DateTime now = DateTime.now();
  DateTime startDate = DateTime(now.year, now.month, now.day, startHour, startMinute);
  DateTime endDate;

  if (startTime == "0000" && endTime == "0000") {
    return true;
  }

  if (startHour > endHour || (startHour == endHour && startMinute > endMinute)) {
    endDate = DateTime(now.year, now.month, now.day + 1, endHour, endMinute);
  } else {
    endDate = DateTime(now.year, now.month, now.day, endHour, endMinute);
  }
  return now.isAfter(startDate) && now.isBefore(endDate);
}

String formatUsageTime(String startTime, String endTime) {
  if (startTime == "0000" && endTime == "0000") {
    return "00:00 - 24:00"; // 24 hours availability
  }
  int startHour = int.parse(startTime.substring(0, 2));
  int startMinute = int.parse(startTime.substring(2, 4));
  int endHour = int.parse(endTime.substring(0, 2));
  int endMinute = int.parse(endTime.substring(2, 4));

  String formattedStartTime = "${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}";
  String formattedEndTime = "${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}";

  if (startHour > endHour || (startHour == endHour && startMinute > endMinute)) {
    formattedEndTime = "24:00";
  }

  return "$formattedStartTime - $formattedEndTime";
}
