import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walking/Controllers/noteController.dart';
import 'package:walking/utils.dart';
import 'package:walking/widgets/alerts.dart';
import 'package:share_plus/share_plus.dart';

import '../datas.dart';
import 'busDataController.dart';

class ShareController extends GetxController{

  static ShareController get to => Get.find();

  bool isAttendance = true;

  void showStudentListShareDialog(BuildContext context){
    isAttendance = true;

    showDialog(
      context: context,
      builder: (context){
        return MyChildAlertDialog(
            title: "노트 공유",
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ToggleAttendanceButton(
                  onSelect: (bool isAttendance){
                    this.isAttendance = isAttendance;
                  },
                ),
              ),
            ),
            onConfirm: ()async{
              await ShareController.to.share(await getStudentListShareText2(isAttendance ? "등교하였습니다." : "하교하였습니다."));
              Navigator.pop(context);
            },
            onCancel: (){
              Navigator.pop(context);
            }
        );
      }
    );
  }

  Future<String> getStudentListShareText2(String followingText) async{
    String text = "${DateTime.now().month}월 ${DateTime.now().day}일 ${getDayOfWeek()}\n";
    try {
      // Firestore에서 학생 데이터를 가져옴
      List<dynamic> students = NoteViewModel.to.students.where((p0) => p0.isArrived && !p0.isAbsent).toList();

      // students 리스트를 'description'(학년)을 기준으로 정렬
      students.sort((a, b) => a.description.compareTo(b.description));

      // 학년별로 그룹화
      Map<String, List<dynamic>> groupedStudents = {};
      for (var student in students) {
        if (!groupedStudents.containsKey(student.description)) {
          groupedStudents[student.description] = [];
        }
        groupedStudents[student.description]!.add(student);
      }

      // 각 학년별로 처리
      groupedStudents.forEach((grade, gradeStudents) {
        text += "\n$grade\n";

        // 각 학년 내에서 출석 상태에 따라 정렬
        gradeStudents.sort((a, b) {
          if (!a.isAbsent == false && !b.isAbsent == true) return 1;
          if (a.isArrived && !b.isArrived) return -1;
          if (!a.isArrived && b.isArrived) return 1;
          return 0;
        });

        // 학생 이름 추가
        text += gradeStudents.map((student) => student.name).join(' ') + "\n";
      });
    } catch (e) {
      text = "Error fetching student list: $e";
    }
    text += "\n$followingText";

    return text;
  }



  Future<void> share(String text) async{
    await Share.share(text);
  }
}

class ToggleAttendanceButton extends StatefulWidget {
  final Function(bool) onSelect;

  const ToggleAttendanceButton({
    Key? key,
    required this.onSelect,
  }) : super(key: key);

  @override
  _ToggleAttendanceButtonState createState() => _ToggleAttendanceButtonState();
}

class _ToggleAttendanceButtonState extends State<ToggleAttendanceButton> {
  bool _isAttendance = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleAttendance,
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: _isAttendance ? 0 : 100,
              child: Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                  color: ColorDatas.secondary,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      '등교',
                      style: TextStyle(
                        color: _isAttendance ? Colors.white : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '하교',
                      style: TextStyle(
                        color: _isAttendance ? Colors.white : Colors.white,
                        fontWeight: FontWeight.bold,
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

  void _toggleAttendance() {
    setState(() {
      _isAttendance = !_isAttendance;
    });
    widget.onSelect(_isAttendance);
  }
}