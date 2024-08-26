import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool isJSON = false;
  bool isAscendingOrder = true;
  FocusNode topicFocus = FocusNode();
  FocusNode subjectFocus = FocusNode();
  FocusNode inputFocus = FocusNode();
  final scrollController = ScrollController(keepScrollOffset: true);
  final randColors = [Colors.red, Colors.blue, Colors.yellow, Colors.brown];

  // final JsonFileIo jsonFileIo = JsonFileIo();

  final topicController = TextEditingController(
    text: '',
  );
  final subjectController = TextEditingController(
    text: '',
  );
  final jsonInputController = TextEditingController();
  String topicID = "";
  String subjectID = "";
  String inputText = "";

  List<Question> questions = [];

  @override
  Widget build(BuildContext context) {
    MediaQueryData query = MediaQuery.of(context);
    bool portrait = query.size.height > query.size.width;
    List<Widget> widgets = [
      Flexible(
        flex: 2,
        child: Padding(
          padding: !portrait
              ? const EdgeInsets.all(8.0)
              : const EdgeInsets.only(top: 8, left: 8, right: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!portrait)
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 1,
                      child: TextField(
                        focusNode: topicFocus,
                        controller: topicController,
                        onChanged: (text) => {
                          setState(() {
                            topicID = topicController.text;
                          })
                        },
                        decoration: const InputDecoration(
                          hintText: "Topic ID",
                          hintStyle: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Flexible(
                      flex: 1,
                      child: TextField(
                        focusNode: subjectFocus,
                        controller: subjectController,
                        canRequestFocus: true,
                        onChanged: (text) => {
                          setState(() {
                            subjectID = subjectController.text;
                          }),
                        },
                        decoration: const InputDecoration(
                          hintText: "Subject ID",
                          hintStyle: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 10,
              ),
              Flexible(
                child: Boxed(
                  child: TextField(
                    style: const TextStyle(fontFamily: "Courier"),
                    focusNode: inputFocus,
                    decoration: InputDecoration(
                        border: null,
                        hintText:
                            "write or paste your ${isJSON ? 'JSON' : 'CSV'} here...",
                        hintStyle: const TextStyle(
                            fontWeight: FontWeight.w300, color: Colors.grey)),
                    controller: jsonInputController,
                    autocorrect: false,
                    canRequestFocus: true,
                    dragStartBehavior: DragStartBehavior.start,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    onChanged: (text) {
                      setState(() {
                        inputText = jsonInputController.text;
                      });
                    },
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 100,
                      height: 40,
                      child: MaterialButton(
                        color: Colors.red,
                        onPressed: () {
                          setState(() {
                            jsonInputController.text = "";
                            inputText = "";
                            inputFocus.requestFocus();
                          });
                        },
                        child: const Text(
                          "Reset Input",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 100,
                      height: 40,
                      child: MaterialButton(
                        color: Colors.green,
                        onPressed: () {
                          if (topicID.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Error'),
                                content: const Text(
                                    'Enter Topic ID in the topic field'),
                                actions: [
                                  MaterialButton(
                                      onPressed: () {
                                        topicFocus.requestFocus();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'))
                                ],
                              ),
                            );
                          } else if (subjectID.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Error'),
                                content: const Text(
                                    'Enter Subject ID in the subject field'),
                                actions: [
                                  MaterialButton(
                                      onPressed: () {
                                        subjectFocus.requestFocus();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'))
                                ],
                              ),
                            );
                          } else if (jsonInputController.text.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Error'),
                                content: Text(
                                    'Input ${isJSON ? 'JSON' : 'CSV'} in the input box to add questions'),
                                actions: [
                                  MaterialButton(
                                      onPressed: () {
                                        inputFocus.requestFocus();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'))
                                ],
                              ),
                            );
                          } else {
                            try {
                              addQuestions();
                            } catch (e) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Error'),
                                  content: Text(
                                      'Entered JSON is not in correct format. looks like some keys or values are missing or invalid.\n${e.toString()}'),
                                  actions: [
                                    MaterialButton(
                                        onPressed: () {
                                          inputFocus.requestFocus();
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'))
                                  ],
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          "Add",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      if (portrait)
        const Divider(
          color: Colors.black,
          height: 0,
          thickness: 1,
        ),
      if (!portrait)
        const VerticalDivider(
          width: 0,
          color: Colors.black,
          thickness: 1,
        ),
      Flexible(
        flex: 3,
        child: Padding(
          padding: !portrait
              ? const EdgeInsets.only(top: 8.0)
              : const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            // decoration: BoxDecoration(
            //   border: Border.all(color: Colors.black, width: 1),
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      const Text(
                        "OUTPUT",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Text(
                        '${questions.length} Questions',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      IconButton(
                          onPressed: _sortByName,
                          icon: const Icon(Icons.sort_by_alpha)),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            questions.shuffle();
                          });
                        },
                        icon: const Icon(Icons.question_mark),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            for (var q in questions) {
                              q.answerOptions?.shuffle();
                            }
                          });
                        },
                        icon: const Icon(Icons.question_answer),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog.adaptive(
                                  icon: const Icon(
                                    Icons.warning,
                                    color: Colors.red,
                                  ),
                                  content: Text(
                                      'Do you want to remove all the ${questions.length} questions from the list?'),
                                  title: const Text('Warning'),
                                  actions: [
                                    FilledButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('No')),
                                    FilledButton(
                                        style: ButtonStyle(
                                          foregroundColor:
                                              WidgetStateColor.resolveWith(
                                            (states) {
                                              return Colors.white;
                                            },
                                          ),
                                          backgroundColor:
                                              WidgetStateColor.resolveWith(
                                            (states) {
                                              return Colors.red;
                                            },
                                          ),
                                        ),
                                        onPressed: () => setState(() {
                                              questions.clear();
                                              Navigator.of(context).pop();
                                            }),
                                        child: const Text(
                                          'Yes',
                                        ))
                                  ],
                                );
                              },
                            );
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 120,
                          height: 40,
                          child: MaterialButton(
                            // icon: const Icon(Icons.copy, color: Colors.green,),
                            onPressed: () async {
                              await Clipboard.setData(
                                  ClipboardData(text: jsonEncode(questions)));
                            },
                            color: Colors.green,
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.copy,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Copy JSON',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!kIsWeb)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 120,
                            height: 40,
                            child: MaterialButton(
                              onPressed: () async {
                                String? selectedDirectory =
                                    await FilePicker.platform.getDirectoryPath(
                                  dialogTitle:
                                      'Choose a location to save the file',
                                );
                                if (selectedDirectory == null) {
                                  //user canceled the picker
                                  return;
                                }

                                // Create a file in the selected directory
                                String filePath =
                                    '$selectedDirectory/subject_$subjectID-topic_$topicID-questions_${questions.length}.json'
                                        .toLowerCase();

                                File file = File(filePath);

                                await file.writeAsString(jsonEncode(questions));
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Examiter'),
                                      icon: const Icon(
                                        Icons.download_for_offline_sharp,
                                        color: Colors.green,
                                      ),
                                      content: Column(
                                        children: [
                                          const Text('File saved successfully'),
                                          TextButton(
                                              onPressed: () {
                                                Uri uri = Uri.file(filePath);
                                                launchUrl(uri);
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(filePath)),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('OK'))
                                      ],
                                    );
                                  },
                                );

                                // jsonFileIo.writeJson('$subjectID-$topicID', jsonEncode(questions));
                              },
                              color: Colors.green,
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.save,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Save JSON',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  height: 0,
                  thickness: 1,
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    //child: Text('Nothing to show'),
                    child: ListView.builder(
                      controller: scrollController,
                      key: UniqueKey(),
                      itemBuilder: (context, questionIndex) {
                        return ListTile(
                          title: ListTile(
                            leading: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      TextEditingController controller =
                                          TextEditingController();
                                      controller.text = questions[questionIndex]
                                              .body
                                              ?.content ??
                                          '';
                                      return AlertDialog.adaptive(
                                        title: const Text('Edit Question'),
                                        content: TextField(
                                          controller: controller,
                                        ),
                                        actions: [
                                          TextButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            label: const Text('Cancel'),
                                            icon: const Icon(
                                              Icons.cancel,
                                              color: Colors.red,
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                questions[questionIndex]
                                                    .body
                                                    ?.content = controller.text;
                                                Navigator.of(context).pop();
                                              });
                                            },
                                            label: const Text('Save'),
                                            icon: const Icon(
                                              Icons.save,
                                              color: Colors.green,
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.edit)),
                            title: Text(
                              'Q ${questionIndex + 1}: ${questions[questionIndex].body?.content ?? ''}',
                              softWrap: true,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            trailing: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog.adaptive(
                                        title:
                                            const Text('Delete this Question'),
                                        actions: [
                                          TextButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            label: const Text('Cancel'),
                                            icon: const Icon(
                                              Icons.cancel,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                questions
                                                    .removeAt(questionIndex);

                                                Navigator.of(context).pop();
                                              });
                                            },
                                            label: const Text('Delete'),
                                            icon: const Icon(
                                              Icons.delete_forever,
                                              color: Colors.red,
                                            ),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.delete_forever_rounded)),
                          ),
                          subtitle: ListView.builder(
                            key: UniqueKey(),
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, answerIndex) {
                              AnswerOptions answer = questions[questionIndex]
                                  .answerOptions![answerIndex];
                              final isCorrect = answer.isCorrect ?? false;
                              return ListTile(
                                leading: Container(
                                  width: 8,
                                  height: double.infinity,
                                  color: isCorrect
                                      ? Colors.green
                                      : Colors.red[100],
                                ),
                                title: ListTile(
                                  leading: IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.edit_note,
                                      )),
                                  title: Text(answer.body?.content ?? ''),
                                  trailing: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount:
                                questions[questionIndex].answerOptions?.length,
                          ),
                        );
                      },
                      itemCount: questions.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
    return SafeArea(
      child: Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Image.asset(
                    "assets/images/icon.png",
                    width: 80,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (portrait)
                  Column(
                    children: [
                      TextField(
                        focusNode: topicFocus,
                        controller: topicController,
                        onChanged: (text) => {
                          setState(() {
                            topicID = topicController.text;
                          })
                        },
                        decoration: const InputDecoration(
                          hintText: "Topic ID",
                          hintStyle: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextField(
                        focusNode: subjectFocus,
                        controller: subjectController,
                        canRequestFocus: true,
                        onChanged: (text) => {
                          setState(() {
                            subjectID = subjectController.text;
                          }),
                        },
                        decoration: const InputDecoration(
                          hintText: "Subject ID",
                          hintStyle: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.w400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Current Input Format: ',
                ),
                const SizedBox(
                  height: 16,
                ),
                DropdownButton(
                  //dropdownColor: Colors.white,
                  // elevation: 5,
                  isExpanded: true,
                  hint: const Text('Change input format'),
                  style: const TextStyle(fontWeight: FontWeight.bold),

                  icon: const Icon(
                    Icons.arrow_drop_down,
                  ),
                  value: isJSON ? 'JSON' : 'CSV',
                  items: <String>['JSON', 'CSV']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      alignment: Alignment.bottomLeft,
                      value: value,
                      child: Center(
                          child: Text(
                        value,
                        style: const TextStyle(color: Colors.green),
                      )),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      isJSON = value == 'JSON';
                    });
                    _savePreference(isJSON);
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: const Text(
              "Examiter MCQs Moderator",
              style: TextStyle(color: Colors.white),
            ),
            actions: const [],
          ),
          body: Column(
            children: [
              Flexible(
                flex: 1,
                child: portrait
                    ? Column(
                        children: widgets,
                      )
                    : Row(
                        children: widgets,
                      ),
              ),
            ],
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  _loadPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isJSON = prefs.getBool('isJson') ?? false;
    });
  }

  _savePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isJson', value);
  }

  void _sortByName() {
    setState(() {
      if (isAscendingOrder) {
        questions.sort((a, b) {
          if (a.body?.content == null && b.body?.content == null) {
            return 0;
          } else if (a.body?.content == null) {
            return 1;
          } else if (b.body?.content == null) {
            return -1;
          } else {
            return a.body!.content!.compareTo(b.body!.content!);
          }
        });
      } else {
        questions.sort((a, b) {
          if (a.body?.content == null && b.body?.content == null) {
            return 0;
          } else if (a.body?.content == null) {
            return -1;
          } else if (b.body?.content == null) {
            return 1;
          } else {
            return b.body!.content!.compareTo(a.body!.content!);
          }
        });
      }
      isAscendingOrder = !isAscendingOrder;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void addQuestions() {
    topicID = topicController.text.trim();
    subjectID = subjectController.text.trim();
    int addedQuestionCount = 0;

    String input = jsonInputController.text.trim();
    List<Question> temp = [];
    if (isJSON) {
      input = input.replaceAll('\r', ' ').replaceAll('\n', ' ');
      final l = json.decode(input);

      temp.insertAll(
        0,
        List<Question>.from(
          l.map(
            (model) {
              Question q = Question.fromJson(model);
              q.topicId = topicID;
              q.subjectId = subjectID;
              return q;
            },
          ),
        ),
      );
    } else {
      input.replaceAll('\n', '');
      List<List<dynamic>> rows = const CsvToListConverter().convert(
        input,
        fieldDelimiter: ',,,',
        eol: '\n',
        shouldParseNumbers: true,
        convertEmptyTo: '\n',
        allowInvalid: false,
      );
      // const csvConverter = CsvToListConverter();
      //csvConverter;
      for (List<dynamic> row in rows) {
        //Create question
        Question q = Question();

        Body qBody = Body(contentType: 'PLAIN', content: '${row[0]}');
        q.body = qBody;
        q.answerOptions = [];

        //

        for (int i = 1; i < row.length; i++) {
          // create answer option.

          AnswerOptions answer = AnswerOptions(
              body:
                  Body(content: row[i].toString().trim(), contentType: 'PLAIN'),
              // isCorrect: row[i] == row[row.length - 1]);
              isCorrect: false);
          // check if the answer is already added.

          if (containsAnswer(q.answerOptions ?? [], answer.body!.content)) {
            for (int i = 0; i < q.answerOptions!.length; i++) {
              if (q.answerOptions?[i].body?.content == answer.body?.content) {
                q.answerOptions?[i].isCorrect = true;
                break;
              }
            }
          } else {
            q.answerOptions?.add(answer);
          }
          //q.answerOptions?.add(answer);
        }

        //check that at least one answer is correct in the question.
        bool containCorrectAnswer = false;
        q.answerOptions?.forEach(
          (element) {
            if (element.isCorrect ?? false) {
              containCorrectAnswer = true;
            }
          },
        );
        if (!containCorrectAnswer) {
          continue;
        }

        q.subjectId = subjectID;
        q.topicId = topicID;
        q.assignedPoints = 1;
        q.status = 'ACTIVE';
        temp.add(q);
      }
    }
    int questionsCount = questions.length;
    copyQuestions(temp, questions);
    addedQuestionCount = questions.length - questionsCount;

    setState(() {
      questions.shuffle();
      for (var element in questions) {
        element.answerOptions?.shuffle();
      }
    });

    if (kDebugMode) {
      print(questions.length);
      print(json.encode(questions));
    }
    setState(() {
      // jsonInputController.text = "";
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarAnimationStyle: AnimationStyle(
            duration: const Duration(seconds: 1),
            curve: Curves.easeIn,
            reverseCurve: Curves.bounceIn,
            reverseDuration: const Duration(seconds: 1)),
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('$addedQuestionCount new questions added successfully'),
          width: 600,
          backgroundColor: Colors.green,
          padding: const EdgeInsets.all(16),
          behavior: SnackBarBehavior.floating,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          dismissDirection: DismissDirection.horizontal,
          showCloseIcon: true,
        ),
      );
    });
  }

  bool containsAnswer(
      List<AnswerOptions> answerOptionsList, String? answerText) {
    if (answerOptionsList.isEmpty) {
      return false;
    }

    for (int i = 0; i < answerOptionsList.length; i++) {
      if (answerOptionsList[i].body?.content == answerText) {
        return true;
      }
    }
    return false;
  }
}

class Boxed extends StatelessWidget {
  const Boxed({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: Colors.grey, width: 1, style: BorderStyle.solid)),
      child: child,
    );
  }
}

void copyQuestions(List<Question> temp, List<Question> mainList) {
  for (var quest in temp) {
    if (mainList.isEmpty) {
      mainList.add(quest);
    } else {
      bool exist = false;
      for (Question q in mainList) {
        if (q.body?.content == quest.body?.content) {
          exist = true;
          break;
        }
      }
      if (!exist) {
        mainList.add(quest);
      }
    }
  }
}

bool validateAllFieldsAreFilled(List<String> items) {
  for (int i = 0; i < items.length; i++) {
    if (items[i].isEmpty) {
      return false;
    }
  }
  return true;
}
