import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:koala/services/login.dart';

List<Map<String, String>> parseNotice(String htmlContent) {
  const String baseUrl = 'https://lib.khu.ac.kr';
  var document = parser.parse(htmlContent);
  List<Element> rows = document.querySelectorAll('.listTable tbody tr');
  List<Map<String, String>> data = [];

  for (var row in rows) {
    if (data.length >= 6) break;  // Stop adding items once we have 6 entries
    var titleElement = row.querySelector('.title a');
    var dateElement = row.querySelector('.reportDate');
    if (titleElement != null && dateElement != null) {
      String urlPath = titleElement.attributes['href'] ?? '';
      String fullUrl = urlPath.startsWith('http') ? urlPath : '$baseUrl$urlPath';
      data.add({
        'title': titleElement.text.trim(),
        'url': fullUrl,
        'date': dateElement.text.trim()
      });
    }
  }
  return data;
}

Future<List<Map<String, String>>> getNotice() async {
  KoalaClient client = await newDioClient();
  final res = await client.dio.get("https://lib.khu.ac.kr/bbs/list/1");
  return parseNotice(res.data);
}
