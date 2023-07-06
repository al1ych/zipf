import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:language_support/text_analysis_service.dart';

import 'api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ApiService());
  Get.put(TextAnalysisService());
  runApp(App());
}

class App extends StatelessWidget {
  final languages = ["en", "es", "fr", "de", "it", "ru"];

  final targetLanguage = Get.find<TextAnalysisService>().targetLanguage;
  final textCorpus = Get.find<TextAnalysisService>().textCorpus;
  final tas = Get.find<TextAnalysisService>();
  final api = Get.find<ApiService>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Support',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: Scaffold(
        body: Obx(
          () => ListView(
            children: [
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64.0),
                child: Center(
                  child: SizedBox(
                    width: 64,
                    height: 32,
                    child: DropdownButton<String>(
                      value: targetLanguage.value,
                      onChanged: (String? newValue) {
                        tas.updateTextCorpus(newValue!);
                      },
                      items: languages.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 64.0),
                child: Text(
                  "Corpus fetched:",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 32),
              tas.isBusy.value
                  ? const SizedBox(
                      width: 32,
                      height: 16,
                      child: LinearProgressIndicator(),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 64.0),
                      child: tas.showCorpus.value
                          ? Text(
                              textCorpus.value,
                            )
                          : ElevatedButton(
                              onPressed: () {
                                tas.showCorpus.value = true;
                              },
                              child: const Text("Show corpus..."),
                            )),
              const SizedBox(height: 48),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 64.0),
                child: Text(
                  "Word count:",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 32),
              tas.isBusy.value
                  ? const SizedBox(
                      width: 32,
                      height: 16,
                      child: LinearProgressIndicator(),
                    )
                  : Column(
                      children: [
                        ...tas.getWordCount().map(
                              (e) => Column(
                                children: [
                                  SizedBox(
                                    height: 32,
                                    child: Text("#${e.value.value + 1}   ${e.key}: ${e.value.key}"),
                                  ),
                                  // index in map
                                  e.value.value == tas.lowerBoundIndex1.value
                                      ? Container(
                                          color: Colors.lightGreen[200],
                                          width: double.infinity,
                                          height: 16,
                                          child: const Text("20%"),
                                        )
                                      : Container(),
                                  e.value.value == tas.lowerBoundIndex2.value
                                      ? Container(
                                          color: Colors.orange[200],
                                          width: double.infinity,
                                          height: 16,
                                          child: const Text("50%"),
                                        )
                                      : Container(),
                                  e.value.value == tas.lowerBoundIndex3.value
                                      ? Container(
                                          color: Colors.red[200],
                                          width: double.infinity,
                                          height: 16,
                                          child: const Text("80%"),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
