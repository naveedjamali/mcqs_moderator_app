import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mcqs_moderator_app/models.dart';
import 'package:url_launcher/url_launcher.dart';

class Save {
  static Function saveMCQs = (String subjectID, String topicID,
      List<Question> questions, BuildContext context, bool saveAsJSON) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose a location to save the file',
    );
    if (selectedDirectory == null) {
//user canceled the picker
      return;
    }

// Create a file in the selected directory
    String filePath =
        '$selectedDirectory/subject_$subjectID-topic_$topicID-questions_${questions.length}.${saveAsJSON ? 'json' : 'txt'}'
            .toLowerCase();

    File file = File(filePath);

    if (saveAsJSON) {
      await file.writeAsString(jsonEncode(questions));
    } else {
      const options = [
        '(A)',
        '(B)',
        '(C)',
        '(D)',
        '(E)',
        '(F)',
        '(G)',
        '(H)',
        '(I)',
        '(J)',
        '(K)',
      ];
      String mcqs =
          "Subject: $subjectID, Topic: $topicID, total questions: ${questions.length}\n";
      String keys = "\n\nKeys of correct Answers\n\n";

      for (int i = 0; i < questions.length; i++) {
        String q =
            "\n\nQ# ${i + 1}: ${questions[i].body?.content.toString()}\n";

        int totalAnswers = questions[i].answerOptions!.length;
        for (int j = 0; j < totalAnswers; j++) {
          q +=
              "\n\t${options[j]}: ${questions[i].answerOptions?[j].body?.content.toString()}";
          if (questions[i].answerOptions![j].isCorrect ?? false) {
            keys +=
                "Q# ${i + 1}: ${options[j]} ${questions[i].answerOptions?[j].body?.content.toString()}\n";
          }
        }
        mcqs += q;
      }

      final allText = mcqs + keys;
      await file.writeAsString(allText);
    }
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'))
          ],
        );
      },
    );

// jsonFileIo.writeJson('$subjectID-$topicID', jsonEncode(questions));
  };
}
