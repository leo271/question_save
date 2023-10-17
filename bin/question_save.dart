import 'package:question_save/question_save.dart' as question_save;
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main(List<String> arguments) async {
  final questionSaveUri = Uri.parse(
      "https://us-central1-milestone-rest.cloudfunctions.net/saveQuestions");
  final response = await http.post(
    questionSaveUri,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({"questions": question_save.data}),
  );
  if (response.statusCode == 200) {
    print("Success");
  } else {
    print("Failed:${response.statusCode}");
  }
}
