import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mcqs_moderator_app/functions/save.dart';
import 'package:mcqs_moderator_app/models.dart';
import 'package:mcqs_moderator_app/widgets/ai_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool useAi = true;
  bool isAscendingOrder = true;
  FocusNode topicFocus = FocusNode();
  FocusNode subjectFocus = FocusNode();
  FocusNode inputFocus = FocusNode();

  // final scrollController = ScrollController(keepScrollOffset: true);
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();

  final randColors = [Colors.red, Colors.blue, Colors.yellow, Colors.brown];

  // final JsonFileIo jsonFileIo = JsonFileIo();

  final topicController = TextEditingController(
    text: 'Computer System',
  );
  final subjectController = TextEditingController(
    text: 'Computer Studies',
  );
  final jsonInputController = TextEditingController(
      text:
          'Who was the first prime minister of Islamic Republic of Pakistan?,,,Liaqat Ali Khan,,,Quaid e Azam Muhammad Ali Jinnah,,,Zulfiqar Ali Bhutto,,,Chaudhary Rahmat Ali,,,Liaqat Ali Khan');
  String topicID = 'Pakistan Study';
  String subjectID = 'General Knowledge';
  String inputText =
      'Who was the first prime minister of Islamic Republic of Pakistan?,,,Liaqat Ali Khan,,,Quaid e Azam Muhammad Ali Jinnah,,,Zulfiqar Ali Bhutto,,,Chaudhary Rahmat Ali,,,Liaqat Ali Khan';

  List<String> entries = [];
  List<Question> questions = [];
  bool generatingResponse = false;

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
                          label: Text("Topic ID or Name"),
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
                          label: Text("Subject ID or Name"),
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
              if (useAi)
                Boxed(
                  child: AiWidget(
                    clearEntries: clearEntries,
                    subject: subjectID,
                    topic: topicID,
                    addQuestions: addQuestions,
                    setCSV: setCSV,
                    addEntry: addEntry,
                    setResponseLoading: setGeneratingResponse,
                  ),
                ),
              if (useAi)
                Flexible(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: SelectableText(
                          entries[index],
                        ),
                      );
                    },
                  ),
                ),
              if (!useAi)
                Flexible(
                  child: Boxed(
                    child: TextField(
                      style: const TextStyle(fontFamily: "Courier"),
                      focusNode: inputFocus,
                      decoration: InputDecoration(
                          border: null,
                          hintText: "write or paste your text here...",
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
              if (!useAi)
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
                                      'Input text in the input box to add questions'),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 170,
                        height: 40,
                        child: MaterialButton(
                          color: Colors.green,
                          onPressed: () async {
                            final clipBoardData =
                                await Clipboard.getData(Clipboard.kTextPlain);
                            jsonInputController.text =
                                clipBoardData!.text.toString();

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
                                      'Input text in the input box to add questions'),
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
                          child: const Row(
                            children: [
                              Icon(
                                Icons.settings_applications_outlined,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "Reset | Paste | Add",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
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
                        },
                        icon: const Icon(Icons.clear),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SizedBox(
                          width: 120,
                          height: 40,
                          child: MaterialButton(
                            // icon: const Icon(Icons.copy, color: Colors.green,),
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(
                                  text: Save.questionToText(
                                      subjectID, topicID, questions)));
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
                                  'Copy Text',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
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
                          padding: const EdgeInsets.all(4.0),
                          child: SizedBox(
                            width: 118,
                            height: 40,
                            child: MaterialButton(
                              onPressed: () {
                                Save.saveMCQs(subjectID, topicID, questions,
                                    context, true);
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
                      if (!kIsWeb)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SizedBox(
                            width: 125,
                            height: 40,
                            child: MaterialButton(
                              onPressed: () {
                                Save.saveMCQs(subjectID, topicID, questions,
                                    context, false);
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
                                    'Save As Text',
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
                      key: const PageStorageKey<String>('page'),
                      itemBuilder: (context, questionIndex) {
                        return ListTile(
                          title: ListTile(
                            leading: IconButton(
                                onPressed: () => editQuestion(questionIndex),
                                icon: const Icon(Icons.edit)),
                            title: Text(
                              'Q ${questionIndex + 1}: ${questions[questionIndex].body?.content ?? ''}',
                              softWrap: true,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            trailing: IconButton(
                                onPressed: () => deleteQuestion(questionIndex),
                                icon: const Icon(Icons.delete_forever_rounded)),
                          ),
                          subtitle: ListView.builder(
                            key: UniqueKey(),
                            shrinkWrap: true,
                            // physics: PageScrollPhysics(),
                            itemBuilder: (context, answerIndex) {
                              int lastItemIndex = questions[questionIndex]
                                  .answerOptions!
                                  .length;
                              if (answerIndex == lastItemIndex) {
                                final newAnswerController =
                                    TextEditingController(
                                  text: '',
                                );

                                return ListTile(
                                  title: ListTile(
                                    leading: const Text(
                                        'Add new answer and press Enter:'),
                                    title: TextField(
                                      textInputAction: TextInputAction.go,
                                      controller: newAnswerController,
                                      onSubmitted: (value) {
                                        if (newAnswerController
                                            .text.isNotEmpty) {
                                          AnswerOptions newAns =
                                              AnswerOptions();
                                          newAns.isCorrect = false;
                                          newAns.body = Body(
                                              contentType: 'PLAIN',
                                              content:
                                                  newAnswerController.text);
                                          setState(() {
                                            questions[questionIndex]
                                                .answerOptions
                                                ?.add(newAns);
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                );
                              }

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
                                  leading: Switch(
                                      value: answer.isCorrect ?? false,
                                      onChanged: (value) {
                                        setState(() {
                                          answer.isCorrect = value;
                                        });
                                      }),
                                  title: Text(answer.body?.content ?? ''),
                                  trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        questions[questionIndex]
                                            .answerOptions
                                            ?.remove(answer);
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount:
                                questions[questionIndex].answerOptions!.length +
                                    1,
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
                SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Use AI'),
                      Switch(
                        value: useAi,
                        onChanged: (value) {
                          setState(() {
                            useAi = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 500,
                ),
                const Center(
                  child: Text('Powered by: Effordea LLC'),
                )
              ],
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: const Text(
              "Examiter MCQs Moderator",
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              if (generatingResponse)
                const Row(
                  children: [
                    Text(
                      'Gemini is working',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
            ],
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

  void setGeneratingResponse(bool value) {
    generatingResponse = value;
  }

  addEntry(String entry) {
    setState(() {
      entries.insert(0, entry);
    });
  }

  @override
  void initState() {
    super.initState();
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

  void setCSV(String csv) {
    setState(() {
      jsonInputController.text = csv;
    });
  }

  @override
  void dispose() {
    //scrollController.dispose();

    super.dispose();
  }

  void addQuestions() {
    topicID = topicController.text.trim();
    subjectID = subjectController.text.trim();
    int addedQuestionCount = 0;

    String input = jsonInputController.text.trim();
    List<Question> temp = [];

    String delimiter = ',,,';
    List<String> lists = input.split('\n');
    String joint = '';
    for (var s in lists) {
      s = s.replaceAll(RegExp(r',,,,'), delimiter);
      if (!s.contains(',,,')) {
        if (s.contains(',,')) {
          s = s.replaceAll(RegExp(r',,'), delimiter);
        }
      }
      joint = '$joint\n$s';
    }

    input = joint;

    List<List<dynamic>> rows = const CsvToListConverter().convert(
      input,
      fieldDelimiter: delimiter,
      eol: '\n',
      shouldParseNumbers: true,
      convertEmptyTo: '\n',
      allowInvalid: false,
    );
    // const csvConverter = CsvToListConverter();
    //csvConverter;
    for (List<dynamic> row in rows) {
      if (row.length < 3) {
        // Invalid question
        continue;
      }
      //Create question
      Question q = Question();

      Body qBody = Body(contentType: 'PLAIN', content: '${row[0]}');
      q.body = qBody;
      q.answerOptions = [];

      for (int i = 1; i < row.length; i++) {
        // create answer option.

        AnswerOptions answer = AnswerOptions(
            body: Body(content: row[i].toString().trim(), contentType: 'PLAIN'),
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

      shuffleAnswers(q.answerOptions);

      temp.add(q);
    }

    int questionsCount = questions.length;
    int lastIndex = questions.length - 1;
    copyQuestions(temp, questions);
    //itemScrollController.jumpTo(index: lastIndex + 1);

    addedQuestionCount = questions.length - questionsCount;

    if (kDebugMode) {
      print(questions.length);
      print(json.encode(temp));
    }

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

  void clearEntries() {
    entries.clear();
  }

  void editQuestion(int questionIndex) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        controller.text = questions[questionIndex].body?.content ?? '';
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
                  questions[questionIndex].body?.content = controller.text;
                });
                Navigator.of(context).pop();
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
  }

  deleteQuestion(int questionIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Text('Delete this Question'),
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
                  questions.removeAt(questionIndex);
                });
                Navigator.of(context).pop();
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
  }

  void shuffleAnswers(List<AnswerOptions>? answerOptions) {
    String all = 'all';
    String none = 'none';
    String both = "both";
    String neither = 'neither';
    bool shuffleAnswers = true;
    for (int i = 0; i < answerOptions!.length; i++) {
      String ans =
          answerOptions[i].body?.content.toString().toLowerCase() ?? "";
      if (ans.contains(all) ||
          ans.contains(none) ||
          ans.contains(both) ||
          ans.contains(neither)) {
        shuffleAnswers = false;
        return;
      }
    }
    answerOptions.shuffle();
  }

  Iterable<Widget> getAnswerList(List<Question> questions, int questionIndex) {
    return questions[questionIndex].answerOptions!.map<Widget>((answer) {
      return ListTile(
        leading: Container(
          width: 8,
          height: double.infinity,
          color: answer.isCorrect ?? false ? Colors.green : Colors.red[100],
        ),
        title: ListTile(
          leading: Switch(
              value: answer.isCorrect ?? false,
              onChanged: (value) {
                setState(() {
                  answer.isCorrect = value;
                });
              }),
          title: Text(answer.body?.content ?? ''),
          trailing: IconButton(
            onPressed: () {
              setState(() {
                questions[questionIndex].answerOptions?.remove(answer);
              });
            },
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.red,
            ),
          ),
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
