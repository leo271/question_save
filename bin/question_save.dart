import 'package:question_save/question_save.dart' as question_save;
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main(List<String> arguments) async {
  if (!validateJSON()) {
    print("JSONのバリデーションに失敗しました。修正してもう一度試してください。");
    return;
  } else {
    print("JSONのバリデーションに成功しました。");
  }
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
    print("質問内容を正常にアップロードできました");
  } else {
    print("エラーコード：${response.statusCode}で送信に失敗しました");
  }
}

bool validateJSON() {
  bool flag = true;
  for (int i = 0; i < question_save.data.length; i++) {
    Map<String, Object> question = question_save.data[i];
    if (question["項目ID"] == null || question["項目ID"].toString().isEmpty) {
      print("項目第$i番目：項目IDを設定してください");
      flag = false;
    }
    if (question["タイプ"] == null || question["タイプ"].toString().isEmpty) {
      print("項目第$i番目：タイプを設定してください");
      flag = false;
    } else {
      String type = question["タイプ"].toString();
      switch (type) {
        case "セクションバー":
          if (question["本文"] == null || question["本文"].toString().isEmpty) {
            print("項目第$i番目：本文を設定してください");
            flag = false;
          }
          break;
        case "選択肢":
        case "複数選択":
          if (question["選択肢"] is! List) {
            print("項目第$i番目：選択肢を設定してください。例）[\"選択肢1\",\"選択肢2\"]");
            flag = false;
          } else {
            List<String> choices = question["選択肢"] as List<String>;
            for (int j = 0; j < choices.length; j++) {
              if (choices[j].toString().isEmpty) {
                print("項目第$i番目：選択肢の第$j番目が空です");
                flag = false;
              }
            }
          }
          break;
        case "テキストフィールド":
          if (question["最小長さ"] != null && question["最小長さ"] is! int) {
            print("項目第$i番目：最小長さは整数で設定してください。例）\"最小長さ\":10");
            flag = false;
          }
          break;
        default:
          print("項目第$i番目：タイプが不正です。(セクションバー,選択肢,複数選択,テキストフィールドのいずれかを設定してください)");
          flag = false;
      }
    }
    if (question["必須"] != null && question["必須"] is! bool) {
      print("項目第$i番目：必須は真偽値で設定してください。例）\"必須\":true　または　\"必須\":false");
      flag = false;
    }
    if (question["出現フラグ"] != null) {
      final appFlag = question["出現フラグ"] as Map<String, dynamic>;
      if (appFlag["項目ID"] != null) {
        if (!question_save.data
            .any((element) => element["項目ID"] == appFlag["項目ID"])) {
          print(
              "項目第$i番目：出現フラグの項目ID「${appFlag["項目ID"]}」」が不正です。存在しているIDかどうか確認してください。");
          flag = false;
        } else {
          final destQuestion = question_save.data
              .firstWhere((element) => element["項目ID"] == appFlag["項目ID"]);
          if (!(destQuestion["タイプ"] == "選択肢" ||
              destQuestion["タイプ"] == "複数選択")) {
            print(
                "項目第$i番目：出現フラグの項目ID「${appFlag["項目ID"]}」には選択肢または複数選択のみ設定できます。");
            flag = false;
          } else if (!(destQuestion["選択肢"] as List<String>)
              .contains(appFlag["選択肢"])) {
            print(
                "項目第$i番目：出現フラグの項目ID「${appFlag["項目ID"]}」には選択肢「${appFlag["選択肢"]}」が存在しません。");
            flag = false;
          }
        }
      } else {
        print(
            "項目第$i番目：出現フラグの項目IDを設定してください。例）\"出現フラグ\":{\"項目ID\":\"試験の有無\",\"選択肢\":\"その他\",\"符号\":true}");
        flag = false;
      }
      if (appFlag["符号"] == null || appFlag["符号"] is! bool) {
        print(
            "項目第$i番目：出現フラグの符号を真偽値で設定してください。例）\"出現フラグ\":{\"項目ID\":\"試験の有無\",\"選択肢\":\"その他\",\"符号\":true}");
        flag = false;
      }
    }
  }
  return flag;
}
