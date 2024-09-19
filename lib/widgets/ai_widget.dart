import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiWidget extends StatefulWidget {
  AiWidget(
      {required this.subject,
      required this.topic,
      required this.addQuestions,
      required this.setCSV,
      super.key});

  String subject;
  String topic;
  Function addQuestions;
  Function setCSV;

  @override
  State<AiWidget> createState() => _AiWidgetState();
}

class _AiWidgetState extends State<AiWidget> {
  var systemInstructionController = TextEditingController();
  var inputController = TextEditingController(text: '');

  bool editInstructions = false;

  // late SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    systemInstructionController.text = ""
        "Subject: ${widget.subject},\nTopic: ${widget.topic},\nMinimum Length: 500 words\n"
        "response includes: Actions, reactions, types, subtypes, uses, inventions, involvements and actors, dates, discoveries, formulas, history, and every detail in deep,"
        "\nresponse type: in depth,\n"
        "";

    return Column(
      children: [
        TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('System Instructions'),
                    content: SingleChildScrollView(
                      child: SizedBox(
                        width: 500,
                        child: Column(
                          children: [
                            TextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              controller: systemInstructionController,
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          label: const Text('Close'))
                    ],
                  );
                },
              );
            },
            child: const Text('System Instructions')),
        SizedBox(
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: TextField(
                  decoration:
                      const InputDecoration(labelText: 'Enter your keywords'),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: inputController,
                ),
              ),
              IconButton(
                  tooltip: 'Go',
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (inputController.text.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          title: Text('input text first'),
                        ),
                      );
                    } else {
                      String text = inputController.text;
                      getAIDescription(systemInstructionController.text, text)
                          .then(
                        (description) {
                          if (description != null) {
                            getCsvResponse(description).then(
                              (csv) {
                                widget.setCSV(csv);
                                widget.addQuestions();
                              },
                            );
                          }
                        },
                      );
                    }
                  }),
            ],
          ),
        ),
      ],
    );
  }

  Future<String?> getAIDescription(String sysIns, String keywords) async {
    return askAI(sysIns, keywords);
  }

  Future<String?> getCsvResponse(String description) async {
    String? csv = await askAI(
        ""
        "Generate minimum 30 MCQs from the given text into MCQs,"
        "The output should be in given csv format,"
        "use three commas ,,, as delimiter,"
        "the sample output is: Question,,,Option1,,,Option2,,,Option3,,,Option4,,,CorrectAnswer",
        description);
    return csv;
  }

  Future<String?> askAI(String instructions, String query) async {
    // Access your API key as an environment variable (see "Set up your API key" above)
    const apiKey = 'AIzaSyAPQfSUYwWpD8vIEa3flcukzeve63hLrG0';

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(),
      systemInstruction: Content.system(instructions),
    );

    var prompt = query;

    final response = await model.generateContent([Content.text(prompt)]);
    print(response.text);
    return response.text;
  }
}
