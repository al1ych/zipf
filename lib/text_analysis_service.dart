import 'package:get/get.dart';

import 'api_service.dart';

class TextAnalysisService extends GetxService {
  final isBusy = false.obs;
  final showCorpus = false.obs;

  final targetLanguage = "en".obs;
  final textCorpus = "".obs;

  final corpusSize = 100;

  final lowerBound1 = 0.obs;
  final lowerBoundIndex1 = 0.obs;
  final lowerBound2 = 0.obs;
  final lowerBoundIndex2 = 0.obs;
  final lowerBound3 = 0.obs;
  final lowerBoundIndex3 = 0.obs;

  final api = Get.find<ApiService>();

  Future<String> _getTextCorpus(String lang) async {
    isBusy.value = true;

    String text = "";
    List<Future> futures = <Future>[];
    for (var i = 0; i < corpusSize; i++) {
      futures.add(api.fetchArticle(lang));
    }
    await Future.wait(futures).then((List articles) {
      text += articles.join('\n\n');
      // print("Text final: $text");
    }).catchError((e) {
      print("Error fetching articles: $e");
    });

    isBusy.value = false;

    return text;
  }

  List<String> _getWords(String text) {
    return text.split(' ');
  }

  Map<String, int> _getWordCount(String text) {
    Map<String, int> wordCount = {};
    _getWords(text).forEach((word) {
      if (wordCount.containsKey(word)) {
        wordCount[word] = wordCount[word]! + 1;
      } else {
        wordCount[word] = 1;
      }
    });
    return wordCount;
  }

  List<MapEntry<String, MapEntry<int, int>>> getWordCount() {
    final k = _getWordCount(textCorpus.value);
    // get list of pairs
    final pairs = k.entries.toList();
    // sort the list in descending order
    pairs.sort((a, b) => b.value.compareTo(a.value));

    List<MapEntry<String, MapEntry<int, int>>> result = [];

    int wordsTotal = textCorpus.value.split(' ').length;
    int wordsCounted = 0;
    int index = 0;
    for (var pair in pairs) {
      wordsCounted += pair.value;
      result.add(MapEntry(pair.key, MapEntry(pair.value, index)));
      if (wordsCounted <= wordsTotal * 0.2) {
        lowerBound1.value = wordsCounted;
        lowerBoundIndex1.value = index;
      }
      if (wordsCounted <= wordsTotal * 0.5) {
        lowerBound2.value = wordsCounted;
        lowerBoundIndex2.value = index;
      }
      if (wordsCounted <= wordsTotal * 0.8) {
        lowerBound3.value = wordsCounted;
        lowerBoundIndex3.value = index;
      }
      index++;
    }

    print("total words: $wordsTotal");
    print("bounds: ${lowerBound1.value}, ${lowerBound2.value}, ${lowerBound3.value}");
    print("indices: ${lowerBoundIndex1.value}, ${lowerBoundIndex2.value}, ${lowerBoundIndex3.value}");

    return result;
  }

  void updateTextCorpus(String lang) async {
    targetLanguage.value = lang;
    textCorpus.value = await _getTextCorpus(lang);
  }
}
