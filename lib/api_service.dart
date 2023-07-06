import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ApiService extends GetxService {
  Future<String> fetchArticle(String lang) async {
    // get a random article title
    final response = await http.get(Uri.parse(
        'https://$lang.wikipedia.org/w/api.php?action=query&format=json&list=random&rnnamespace=0&rnlimit=1'));
    final jsonResponse = jsonDecode(response.body);
    final title = jsonResponse['query']['random'][0]['title'];
    // get the article content
    final contentResponse = await http.get(Uri.parse('https://$lang.wikipedia.org/api/rest_v1/page/summary/$title'));
    final contentJsonResponse = jsonDecode(contentResponse.body);
    final text = contentJsonResponse['extract'] ?? '';

    return text;
  }
}
