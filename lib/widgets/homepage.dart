import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcqs_moderator_app/json_file_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool isJSON = true;
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: const Text(
            "Examiter MCQs Moderator",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton.icon(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.white)),
                onPressed: () {
                  setState(() {
                    questions.shuffle();
                  });
                },
                icon: const Icon(
                  Icons.shuffle,
                ),
                label: const Text('Shuffle Questions'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FilledButton.icon(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.green)),
                onPressed: () {
                  setState(() {
                    for (var q in questions) {
                      q.answerOptions?.shuffle();
                    }
                  });
                },
                icon: const Icon(Icons.shuffle),
                label: const Text('Shuffle Answers'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FilledButton.icon(
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
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('No')),
                            FilledButton(
                                style: ButtonStyle(
                                  foregroundColor: WidgetStateColor.resolveWith(
                                    (states) {
                                      return Colors.white;
                                    },
                                  ),
                                  backgroundColor: WidgetStateColor.resolveWith(
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
                label: const Text('Clear Questions'),
                style: ButtonStyle(
                  foregroundColor: WidgetStateColor.resolveWith(
                    (states) {
                      return Colors.white;
                    },
                  ),
                  backgroundColor: WidgetStateColor.resolveWith(
                    (states) {
                      return Colors.red;
                    },
                  ),
                ),
              ),
            ),
            const Text(
              'Current Input Format: ',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(
              width: 20,
            ),
            DropdownButton(
              dropdownColor: Colors.purple,
              elevation: 5,
              hint: const Text('Change input format'),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              underline: const Text(
                '____________________',
                style: TextStyle(color: Colors.white),
              ),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              value: isJSON ? 'JSON' : 'CSV',
              items: <String>['JSON', 'CSV']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  alignment: Alignment.bottomLeft,
                  value: value,
                  child: Center(child: Text(value)),
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
        body: Column(
          children: [
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Topic ID",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
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
                                      hintText:
                                          "Enter topic ID here e.g. c7918742-64a4-4767-bd29-3e23ed88d1c9",
                                      hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      topicController.text = "";
                                      topicID = "";
                                      topicFocus.requestFocus();
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Subject ID",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                                      hintText:
                                          "Enter Subject ID here e.g. c7918742-64a4-4767-bd29-3e23ed88d1c9",
                                      hintStyle: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      subjectController.text = "";
                                      subjectID = "";
                                      subjectFocus.requestFocus();
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Row(
                              children: [],
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Enter ${isJSON ? 'JSON' : 'CSV'} to convert:",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                                          fontWeight: FontWeight.w300,
                                          color: Colors.grey)),
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
                          ],
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                    'Total questions: ${questions.length}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  IconButton(
                                      onPressed: _sortByName,
                                      icon: const Icon(Icons.sort_by_alpha)),
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
                                                  TextEditingController
                                                      controller =
                                                      TextEditingController();
                                                  controller.text =
                                                      questions[questionIndex]
                                                              .body
                                                              ?.content ??
                                                          '';
                                                  return AlertDialog.adaptive(
                                                    title: const Text(
                                                        'Edit Question'),
                                                    content: TextField(
                                                      controller: controller,
                                                    ),
                                                    actions: [
                                                      TextButton.icon(
                                                        onPressed: () {
                                                          Navigator.of(
                                                                  context)
                                                              .pop();
                                                        },
                                                        label: const Text(
                                                            'Cancel'),
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
                                                                    ?.content =
                                                                controller
                                                                    .text;
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          });
                                                        },
                                                        label: const Text(
                                                            'Save'),
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
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        trailing: IconButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog.adaptive(
                                                    title: const Text(
                                                        'Delete this Question'),
                                                    actions: [
                                                      TextButton.icon(
                                                        onPressed: () {
                                                          Navigator.of(
                                                                  context)
                                                              .pop();
                                                        },
                                                        label: const Text(
                                                            'Cancel'),
                                                        icon: const Icon(
                                                          Icons.cancel,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      TextButton.icon(
                                                        onPressed: () {
                                                          setState(() {
                                                            questions.removeAt(
                                                                questionIndex);

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          });
                                                        },
                                                        label: const Text(
                                                            'Delete'),
                                                        icon: const Icon(
                                                          Icons
                                                              .delete_forever,
                                                          color: Colors.red,
                                                        ),
                                                      )
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: const Icon(Icons
                                                .delete_forever_rounded)),
                                      ),
                                      subtitle: ListView.builder(
                                        key: UniqueKey(),
                                        shrinkWrap: true,
                                        physics:
                                            const ClampingScrollPhysics(),
                                        itemBuilder: (context, answerIndex) {
                                          AnswerOptions answer = questions[
                                                  questionIndex]
                                              .answerOptions![answerIndex];
                                          final isCorrect =
                                              answer.isCorrect ?? false;
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
                                              title: Text(
                                                  answer.body?.content ?? ''),
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
                                        itemCount: questions[questionIndex]
                                            .answerOptions
                                            ?.length,
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
                  ],
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
                              content: const Text(
                                  'Input JSON in the input box to add questions'),
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
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 120,
                    height: 40,
                    child: MaterialButton(
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
                      width: 100,
                      height: 40,
                      child: MaterialButton(
                        onPressed: () async {
                          String? selectedDirectory =
                              await FilePicker.platform.getDirectoryPath(
                            dialogTitle: 'Choose a location to save the file',
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
                        child: const Text(
                          'Save JSON',
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
      isJSON = prefs.getBool('isJson') ?? true;
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
    if (isJSON) {
      input = input.replaceAll('\r', ' ').replaceAll('\n', ' ');
      final l = json.decode(input);

      List<Question> temp = [];

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
      int questionsCount = questions.length;
      copyQuestions(temp, questions);
      addedQuestionCount = questions.length - questionsCount;
    } else {
      List<List<dynamic>> rows =
          const CsvToListConverter().convert(input, fieldDelimiter: ',,,');
      for (List<dynamic> row in rows) {
        Question q = Question();
        Body qBody = Body(contentType: 'PLAIN', content: '${row[0]}');
        q.body = qBody;
        q.answerOptions = [];
        for (int i = 1; i < row.length - 1; i++) {
          AnswerOptions answer = AnswerOptions(
              body: Body(content: '${row[i]}', contentType: 'PLAIN'),
              isCorrect: row[i] == row[row.length - 1]);
          q.answerOptions?.add(answer);
        }
        questions.add(q);
        q.subjectId = subjectID;
        q.topicId = topicID;
        q.assignedPoints = 1;
        q.status = 'ACTIVE';
      }
    }

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
  temp.forEach(
    (quest) {
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
    },
  );
}

bool validateAllFieldsAreFilled(List<String> items) {
  for (int i = 0; i < items.length; i++) {
    if (items[i].isEmpty) {
      return false;
    }
  }
  return true;
}
