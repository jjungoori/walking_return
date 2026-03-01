import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:walking/Controllers/busDataController.dart';
import 'package:get/get.dart';
import 'package:walking/Controllers/noteController.dart';
import 'package:walking/Controllers/shareController.dart';
import 'package:walking/pages/studentListPage.dart';
import 'package:walking/widgets/alerts.dart';
import 'package:walking/widgets/animations.dart';
import 'package:walking/widgets/buttons.dart';
import 'package:shimmer/shimmer.dart';
import '../datas.dart';

//a function get all kind of from in students
List<String> getFromList(List<dynamic> students) {
  List<String> fromList = [];
  for (StudentData student in students) {
    if (!fromList.contains(student.description.trim())) {
      fromList.add(student.description.trim());
    }
  }
  fromList.sort((a, b) {
    // // a와 b를 학년과 반으로 분리하여 비교
    // List<String> splitA = a.split('-');
    // List<String> splitB = b.split('-');
    // int gradeA = int.parse(splitA[0]);
    // int classA = int.parse(splitA[1]);
    // int gradeB = int.parse(splitB[0]);
    // int classB = int.parse(splitB[1]);
    //
    // int gradeComparison = gradeA.compareTo(gradeB);
    // if (gradeComparison != 0) {
    //   return gradeComparison;
    // }
    // return classA.compareTo(classB);
    return a.compareTo(b);
  });
  return fromList;
}


class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {

  @override
  void initState() {
    // Get.put(NoteService());
    // Get.put(NoteViewModel());
  }

  @override
  void dispose() {
    Get.delete<NoteService>();
    Get.delete<NoteViewModel>();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorDatas.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        // leading: IconButton(
        //   icon: const Icon(
        //     Icons.arrow_back_ios,
        //     color: ColorDatas.onBackgroundSoft,
        //   ),
        //   onPressed: () {
        //     Get.back();
        //   },
        // ),
        // title: Text('출석 노트', style: TextDatas.title.copyWith(fontSize: 22)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: (){
              ShareController.to.showStudentListShareDialog(context);
              // NoteViewModel.to.editMode.value = !NoteViewModel.to.editMode.value;
            },
          ),
          Obx((){
            return IconButton(
              icon: Icon(NoteViewModel.to.editMode.value ? Icons.edit_outlined : Icons.edit),
              onPressed: (){
                NoteViewModel.to.editMode.value = !NoteViewModel.to.editMode.value;
                showDialog(context: context, builder: (_){
                  if(NoteViewModel.to.editMode.value)
                    return MyChildTipDialog(title: "결석 모드", child: Text("결석한 아이들을 표시할 수 있습니다.", style: TextDatas.description,));
                  else
                    return MyChildTipDialog(title: "출석 모드", child: Text("결석한 아이들을 표시할 수 있습니다.", style: TextDatas.description,));
                });
              },
            );
          })
          // IconButton(onPressed: ()async {
          //   //여기에 카카오 키 해시 출력
          //   print(await KakaoSdk.origin);
          //   ShareController.to.share(KakaoSdk.origin.toString());
          //
          // }, icon: Icon(Icons.more_vert)),

        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        child: Obx(() {
          List<StudentData>? students = NoteViewModel.to.students.value;

          // 데이터 로드 완료
          List<String> fromList = getFromList(students);

          if (fromList.isEmpty) {

            return Center(
              child: Text('아직 학생이 없습니다.', style: TextDatas.description),
            );
          }

          return ListView.builder(
            itemCount: fromList.length
                + (1), // Add button
            itemBuilder: (_, index) {
              if(index == 0){
                return Column(
                  children: [
                    Row(
                      children: [
                        MyAnimatedAddStudentButton(only: false),
                        SizedBox(width: 4),
                        MyAnimatedResetButton(only: false),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                );
              }
              var modifiedIndex = index - (1);
              return StudentSection(
                // editMode: NoteViewModel.to.editMode.value,
                from: fromList[modifiedIndex],
                students: students.where((element) => element.description.trim() == fromList[modifiedIndex]).toList(),
              );
            },
          );
        }),
      ),
    );
  }
}




class StudentSection extends StatelessWidget {

  final String from;
  final List<StudentData> students;
  // final bool editMode;

  const StudentSection({
    super.key,
    required this.from,
    required this.students,
    // required this.editMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: DefaultDatas.noRoundPadding,
            child: Text(from,
              style: TextDatas.title.copyWith(fontSize: 20),
            ),
          ),
          SizedBox(height: 8),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 2/1.3, crossAxisSpacing: 4, mainAxisSpacing: 4),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: students.length,
            itemBuilder: (_, index){
              return Obx(() => StudentItem(student: students[index], editMode: NoteViewModel.to.editMode.value));
            }
          ),
        ],
      ),
    );
  }
}

class StudentItem extends StatelessWidget {
  final StudentData student;
  final bool editMode;
  const StudentItem({
    super.key,
    required this.student,
    required this.editMode
  });

  @override
  Widget build(BuildContext context) {

    if(editMode)
      return ShakingWidget(
        child: SizedBox(
          child: MyAnimatedButton(
            padding: EdgeInsets.all(0),
            color: student.isAbsent ? Colors.redAccent : (student.isArrived ? ColorDatas.primary : ColorDatas.backgroundSoft),
            onPressed: (){
              NoteViewModel.to.updateStudent(student.copyWith(isAbsent: true, isArrived: false));
            },
            onLongPress: (){
              NoteViewModel.to.updateStudent(student.copyWith(isAbsent: false));
            },
            child: Center(child: Text(student.name, style: TextDatas.description.copyWith(
                fontSize: 18,
                color: student.isAbsent ? Colors.white : null,
              overflow: TextOverflow.fade,
            ),
            softWrap: false,
            )
            ),
          ),
        ),
      );
    return SizedBox(
      child: MyAnimatedButton(
        padding: EdgeInsets.all(0),
        color: student.isAbsent ? Colors.redAccent : (student.isArrived ? ColorDatas.primary : ColorDatas.backgroundSoft),
        onPressed: (){
          if(student.isAbsent) return;
          NoteViewModel.to.updateStudent(student.copyWith(isArrived: true));
        },
        onLongPress: (){
          NoteViewModel.to.updateStudent(student.copyWith(isArrived: false));
        },
        child: Center(child: Text(student.name, style: TextDatas.description.copyWith(
            fontSize: 18,
            color: student.isAbsent ? Colors.white : null,
            overflow: TextOverflow.fade,

        ),
          softWrap: false,

        )

        ),
      ),
    );
  }
}


class MyAnimatedAddStudentButton extends StatelessWidget {

  final bool only;

  MyAnimatedAddStudentButton({
    super.key,
    this.only = false
  });

  final minSize = 140.0;

  @override
  Widget build(BuildContext context) {
    return MyAnimatedButton(
      onPressed: (){
        showDialog(context: context, builder: (_){
          return AlertDialog(
            backgroundColor: ColorDatas.background,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
            ),
            content: Padding(
              padding: const EdgeInsets.only(
                bottom: 6,
                top: 12
              ),
              child: addStudentPage(
                forTemp: true,
              ),
            ),
          );
        });
      },
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(
            //   child: Image.asset("assets/images/plusIcon.png",
            //     color: only ? ColorDatas.onPrimaryTitle : ColorDatas.onBackgroundSoft,
            //   ),
            //   width: 24,
            //   height: 24,
            // ),
            // SizedBox(width: 18,),
            Text("학생 임시 추가하기",
                style: TextDatas.description.copyWith(
                  color: only ? ColorDatas.onPrimaryTitle : ColorDatas.onBackgroundSoft,
                )
            )
          ],
        ),
      ),
      color: ColorDatas.backgroundSoft,
    );
  }
}


class MyAnimatedResetButton extends StatelessWidget {

  final bool only;

  MyAnimatedResetButton({
    super.key,
    this.only = false
  });

  final minSize = 140.0;

  @override
  Widget build(BuildContext context) {
    return MyAnimatedButton(
      onPressed: (){
        showDialog(context: context, builder: (_){
          return MyAlertDialog(
            title: "노트 초기화",
            content: "모든 학생의 출석 정보를 초기화 하고, 임시 학생을 삭제하시겠습니까?",
            onConfirm: (){
              NoteViewModel.to.resetNote();
              Navigator.pop(context);
            },
            onCancel: (){
              Navigator.pop(context);
            },
            confirmColor: Colors.redAccent,
          );
        });
      },
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(
            //   child: Image.asset("assets/images/plusIcon.png",
            //     color: only ? ColorDatas.onPrimaryTitle : ColorDatas.onBackgroundSoft,
            //   ),
            //   width: 24,
            //   height: 24,
            // ),
            // SizedBox(width: 18,),
            Text("노트 초기화하기",
                style: TextDatas.description.copyWith(
                  color: only ? ColorDatas.onPrimaryTitle : ColorDatas.onBackgroundSoft,
                )
            )
          ],
        ),
      ),
      color: ColorDatas.backgroundSoft,
    );
  }
}