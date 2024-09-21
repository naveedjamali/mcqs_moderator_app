import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  var descSysInsController = TextEditingController();
  var csvSysInsController = TextEditingController();

  String descSysIns = "";
  String mcqsSysIns = "";

  var inputController = TextEditingController(text: '');
  var inputFocusNode = FocusNode();

  bool editInstructions = false;

  void getSysIns() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      descSysIns = pref.getString('desc_sys_ins') ?? '';
      mcqsSysIns = pref.getString('mcqs_sys_ins') ?? '';

      descSysInsController.text = descSysIns;
      csvSysInsController.text = mcqsSysIns;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Description SysIns'),
                        content: SingleChildScrollView(
                          child: SizedBox(
                            width: 500,
                            child: Column(
                              children: [
                                Text(descSysIns),
                                Row(
                                  children: [
                                    FilledButton.icon(
                                      onPressed: () => setState(() {
                                        Navigator.of(context).pop();
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              content: Column(
                                                children: [
                                                  TextField(
                                                    decoration:
                                                        const InputDecoration(),
                                                    keyboardType:
                                                        TextInputType.multiline,
                                                    maxLines: null,
                                                    controller:
                                                        descSysInsController,
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                FilledButton(
                                                    onPressed: () {
                                                      descSysIns =
                                                          descSysInsController
                                                              .text;
                                                      saveSysIns();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text(
                                                        'Save and Close'))
                                              ],
                                            );
                                          },
                                        );
                                      }),
                                      icon: const Icon(Icons.edit_note),
                                      label: const Text('Edit'),
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    FilledButton(
                                        onPressed: () {
                                          defaultSysIns();
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Load default')),
                                  ],
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
                child: const Text('Description SysIns')),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('MCQs SysIns'),
                      content: SingleChildScrollView(
                        child: SizedBox(
                          width: 500,
                          child: Column(
                            children: [
                              Text(mcqsSysIns),
                              Row(
                                children: [
                                  FilledButton.icon(
                                    onPressed: () => setState(() {
                                      Navigator.of(context).pop();
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: Column(
                                              children: [
                                                TextField(
                                                  decoration:
                                                      const InputDecoration(),
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  maxLines: null,
                                                  controller:
                                                      csvSysInsController,
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              FilledButton(
                                                  onPressed: () {
                                                    mcqsSysIns =
                                                        csvSysInsController
                                                            .text;
                                                    saveSysIns();
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                      'Save and Close'))
                                            ],
                                          );
                                        },
                                      );
                                    }),
                                    icon: const Icon(Icons.edit_note),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  FilledButton(
                                      onPressed: () {
                                        defaultSysIns();

                                        Navigator.pop(context);
                                      },
                                      child: const Text('Load default')),
                                ],
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
              child: const Text('MCQs SysIns'),
            ),
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

                      getAIDescription(descSysInsController.text, text).then(
                        (description) {
                          if (description != null) {
                            getCsvResponse(description).then(
                              (csv) {
                                widget.setCSV(csv);
                                widget.addQuestions();
                                widget.setResponseLoading(false);
                              },
                            );
                          }
                        },
                      );

                      inputController.text = "";
                      inputFocusNode.requestFocus();
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

  Future<String?> getAIDescription(String sysIns, String keywords) async {
    return askAI(sysIns, keywords);
  }

  Future<String?> getCsvResponse(String description) async {
    String? csv = await askAI(csvSysInsController.text, description);
    return csv;
  }

  Future<String?> askAI(String instructions, String query) async {
    // Access your API key as an environment variable (see "Set up your API key" above)
    const apiKey = String.fromEnvironment('API_KEY');

    if (apiKey == null) {
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

  void saveSysIns() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('mcqs_sys_ins', mcqsSysIns);
    pref.setString('desc_sys_ins', descSysIns);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getSysIns();
  }

  void defaultSysIns() {
    setState(() {
      descSysIns =
          "Subject: ${widget.subject}, Topic: ${widget.topic}, Minimum Length: 1000 words response includes: Actions, reactions, types, subtypes, uses, inventions, involvements and actors, dates, discoveries, formulas, history, and every detail in deep, response type: in depth,";
      mcqsSysIns =
          "Generate minimum 30 MCQs from the given text into MCQs,The output should be in given csv format,use three commas ,,, as delimiter,the sample output is: Question,,,Option1,,,Option2,,,Option3,,,Option4,,,CorrectAnswer";
      saveSysIns();
    });
  }
}
