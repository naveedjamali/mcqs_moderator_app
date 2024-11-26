import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiWidget extends StatefulWidget {
  AiWidget(
      {required this.addEntry,
      required this.subject,
      required this.topic,
      required this.addQuestions,
      required this.setCSV,
      required this.clearEntries,
      required this.setResponseLoading,
      super.key});

  String subject;
  String topic;
  Function addQuestions;
  Function setCSV;
  Function addEntry;
  Function clearEntries;
  Function setResponseLoading;

  @override
  State<AiWidget> createState() => _AiWidgetState();
}

class _AiWidgetState extends State<AiWidget> {
  var inputController =
      TextEditingController(text: 'RAM vs ROM: A brief guide');
  var inputFocusNode = FocusNode();

  bool editInstructions = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                widget.clearEntries();
              },
              label: const Text('Clear keywords'),
              icon: const Icon(
                Icons.clear,
                color: Colors.red,
              ),
            )
          ],
        ),
        SizedBox(
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: TextField(
                  focusNode: inputFocusNode,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (value) async {
                    if (inputController.text.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          title: Text('input text first'),
                        ),
                      );
                    } else {
                      String text = inputController.text;
                      widget.addEntry(text);
                      widget.setResponseLoading(true);

                      try {
                        getAIDescription(text);

                        inputController.text = "";
                        inputFocusNode.requestFocus();
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final errorTextController = TextEditingController();

                            return AlertDialog(
                              title: const Text('Error'),
                              content: Column(
                                children: [
                                  Text(e.toString()),
                                  const Text(
                                      'Re-write your query and try again'),
                                  TextFormField(
                                    controller: errorTextController,
                                  ),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {}, child: const Text('Go'))
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter your keywords',
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: inputController,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void getAIDescription(String keywords) async {
    final ins = Content.multi([
      TextPart('Subject: ${widget.subject}'),
      TextPart('Topic: ${widget.topic}'),
      TextPart('Generate a detailed essay on the given topic'),
      TextPart('essay length: 2000 words minimum'),
      TextPart('essay type: in-depth'),
      TextPart(
          'essay includes: history, actions, reactions, parts, sub-parts, examples, formulas, measurements, structure, importance, inventions, discoveries, scientists, artists, uses, involvements, dates, types, subtypes, etc'),
    ]);

    askAI(ins, keywords).then((desc) {
      if (desc != null) {
        if (desc ==
            "GenerativeAIException: Candidate was blocked due to recitation") {
          showDialog(
              context: context,
              builder: (context) {
                widget.setResponseLoading(false);
                return AlertDialog(
                  title: Text('Error'),
                  content: Text(
                      'GenerativeAIException: Candidate was blocked due to recitation'),
                );
              });
        } else {
          getCsvResponse(desc).then(
            (csv) {
              widget.setCSV(csv);
              widget.addQuestions();
              widget.setResponseLoading(false);
            },
          );
        }
      }
    });
  }

  Future<String?> getCsvResponse(String description) async {
    final ins = Content.multi(
      [
        TextPart(
            'CSV output format: Question ,,, Option1 ,,, Option2 ,,, Option3 ,,, Option4 ,,, CorrectAnswer'),
        TextPart('Generate minimum 30 MCQss in the csv format'),
        TextPart('use three commas \',,,\' as delimiter'),
        TextPart(
            'reconfirm that CSV values are separated with three commas ,,, '),
      ],
    );
    String? csv = await askAI(ins, description);
    return csv;
  }

  Future<String?> askAI(Content instructions, String query) async {
    // Access your API key as an environment variable (see "Set up your API key" above)
    const apiKey = String.fromEnvironment('API_KEY');

    if (apiKey.isEmpty) {
      if (kDebugMode) {
        print('No \$API_KEY environment variable');
      }
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API Key error'),
          content: const Text('No API key found, contact developers.'),
          icon: const Icon(
            Icons.error,
            color: Colors.red,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            )
          ],
        ),
      );
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-002',
      apiKey: apiKey,
      safetySettings: [
        SafetySetting(
          HarmCategory.sexuallyExplicit,
          HarmBlockThreshold.none,
        ),
      ],
      generationConfig: GenerationConfig(
        temperature: 1,
      ),
      // systemInstruction: Content.multi([TextPart('')]),
      systemInstruction: instructions,
    );

    var prompt = query;

    try {
      final response = await model.generateContent([Content.text(prompt)]);

      if (kDebugMode) {
        print(response.text);
      }
      return response.text;
    } catch (error) {
      return error.toString();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
