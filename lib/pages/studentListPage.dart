import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:walking/Controllers/busDataController.dart';
import 'package:walking/widgets/alerts.dart';
import 'package:walking/widgets/animations.dart';

import '../datas.dart';
import '../widgets/buttons.dart';

class StudentTextController extends GetxController{
  final nameController = TextEditingController().obs;
  final fromController = TextEditingController().obs;
  final phoneController = TextEditingController().obs;
  final parentPhoneController = TextEditingController().obs;

  void clear(){
    nameController.value.clear();
    fromController.value.clear();
    phoneController.value.clear();
    parentPhoneController.value.clear();
  }
}

class mainPage extends StatelessWidget {
  const mainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pageCon = Get.find<BottomBoxPageController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("학생 명단 관리하기", style: TextDatas.subtitle),
        SizedBox(height: 16),
        MyLineButton(
            text: "학생 직접 추가하기",
            onPressed: (){
              pageCon.pageNumber.value = 1;
            }
        ),
        // MyAnimatedButton(
        //     text: "학생 명단 엑셀로 추가하기",
        //     onPressed: (){
        //       pageCon.pageNumber.value = 2;
        //     }
        // ),
        MyLineButton(
            text: "엑셀 파일로 가져오기",
            onPressed: (){
              // Clipboard.setData(ClipboardData(text: "https://walking-school-bus-kr-application.web.app/?busID=${BusDataViewModel.to.targetBusId}&busName=${BusDataViewModel.to.processedBusData.value.busName}"));
                Get.snackbar('오류!', "구현중인 기능입니다.");
            }
        ),
        // MyLineButton(
        //     text: "학생 참여 링크 공유하기",
        //     onPressed: (){
        //       print("click");
        //       // KakaoController.to.shareFeed(testfeed);
        //       Get.snackbar('오류!', "구현중인 기능입니다.");
        //     }
        // ),
        // MyLineButton(
        //     text: "받은 참여 신청 보기",
        //     onPressed: (){
        //       Get.snackbar('오류!', "구현중인 기능입니다.");
        //       pageCon.pageNumber.value = 4;
        //     }
        // ),
      ],
    );
  }
}

class seeApplicationPage extends StatelessWidget {
  const seeApplicationPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyOpacityRisingWidget(startTime:0, child: Text("받은 참여 신청 보기", style: TextDatas.subtitle)),
        SizedBox(height: 16),
        // ApplicationsView()
      ],
    );
  }
}


class applicationController extends GetxController{
  RxList<dynamic> applications = <dynamic>[].obs;

  void getApplications() {
    print("Listening to Firestore changes");
    applications.clear();

    FirebaseFirestore.instance
        .collection('applications')
        .doc(BusDataViewModel.to.targetBusId.value)
        .collection('students')
        .snapshots()
        .listen((querySnapshot) {
      applications.clear();

      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.forEach((doc) {
          var dataWithId = doc.data() as Map<String, dynamic>;
          dataWithId['id'] = doc.id;
          applications.add(dataWithId);
          print(dataWithId);
        });
      } else {
        print("No documents found in students subcollection");
      }
    });
  }

  void acceptApplication(String studentID){
    FirebaseFirestore.instance
        .collection('applications')
        .doc(BusDataViewModel.to.targetBusId.value)
        .collection('students')
        .doc(studentID)
        .delete();
    BusDataViewModel.to.addStudent(
        StudentData(
            name: applications.firstWhere((element) => element["id"] == studentID)["name"],
            busId: BusDataViewModel.to.targetBusId.value,
            description: applications.firstWhere((element) => element["id"] == studentID)["description"],
            isArrived: false,
            isAbsent: false,
            temporary: false
        )
    );

    Get.snackbar("신청을 수락했습니다.", "해당 학생의 신청이 수락되었습니다.", colorText: Colors.green);
  }

  void rejectApplication(String studentID){

    FirebaseFirestore.instance
        .collection('applications')
        .doc(BusDataViewModel.to.targetBusId.value)
        .collection('students')
        .doc(studentID)
        .delete();

    Get.snackbar("신청을 거부했습니다.", "해당 학생의 신청이 거부되었습니다.", colorText: Colors.red);
  }
}


class addStudentPage extends StatefulWidget {
  final bool forTemp;
  const addStudentPage({
    super.key,
    required this.forTemp
  });

  @override
  State<addStudentPage> createState() => _addStudentPageState();
}

class _addStudentPageState extends State<addStudentPage> {

  StudentTextController studentTextController = Get.put(StudentTextController());

  @override
  Widget build(BuildContext context) {
    final studentNameController = studentTextController.nameController.value;
    final studentFromController = studentTextController.fromController.value;
    final studentPhoneController = studentTextController.phoneController.value;
    final parentPhoneController = studentTextController.parentPhoneController.value;

    // var uuid = Uuid();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyOpacityRisingWidget(
              startTime: 0,
              child: Text(widget.forTemp ? "임시 학생 추가하기" : "직접 학생 추가하기",
                  style: TextDatas.subtitle)
          ),
          SizedBox(height: 16),
          MyOpacityRisingWidget(child: TextField(
            decoration: InputDecoration(
              labelText: '학생 이름',
              labelStyle: TextStyle(color: Colors.grey), // 기본 라벨 색상
              counterText: '${studentNameController.text.length}/20',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: ColorDatas.background,
            ),
            cursorColor: Colors.grey, // 커서 색상
            controller: studentNameController,
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
            ],
            onChanged: (text) {
              // Force the widget to rebuild to show the character count
              (context as Element).markNeedsBuild();
            },
          ), startTime: 50),
          SizedBox(height: 8),
          MyOpacityRisingWidget(child: TextField(
            decoration: InputDecoration(
              labelText: '학생 분류 (예: 6-3)',
              labelStyle: TextStyle(color: Colors.grey), // 기본 라벨 색상
              counterText: '${studentFromController.text.length}/20',
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: ColorDatas.background,
            ),
            cursorColor: Colors.grey, // 커서 색상
            controller: studentFromController,
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
            ],
            onChanged: (text) {
              // Force the widget to rebuild to show the character count
              (context as Element).markNeedsBuild();
            },
          ), startTime: 100),
          // SizedBox(height: 8),
          // TextField(
          //   decoration: InputDecoration(
          //     labelText: '학생 전화번호',
          //     labelStyle: TextStyle(color: Colors.grey), // 기본 라벨 색상
          //     counterText: '${studentPhoneController.text.length}/20',
          //     enabledBorder: OutlineInputBorder(
          //       borderSide: BorderSide(color: Colors.transparent),
          //       borderRadius: BorderRadius.circular(8.0),
          //     ),
          //     focusedBorder: OutlineInputBorder(
          //       borderSide: BorderSide(color: Colors.transparent),
          //       borderRadius: BorderRadius.circular(8.0),
          //     ),
          //     filled: true,
          //     fillColor: ColorDatas.background,
          //   ),
          //   cursorColor: Colors.grey, // 커서 색상
          //   controller: studentPhoneController,
          //   inputFormatters: [
          //     LengthLimitingTextInputFormatter(20),
          //   ],
          //   onChanged: (text) {
          //     // Force the widget to rebuild to show the character count
          //     (context as Element).markNeedsBuild();
          //   },
          // ),
          // SizedBox(height: 8),
          // TextField(
          //   decoration: InputDecoration(
          //     labelText: '학부모 전화번호',
          //     labelStyle: TextStyle(color: Colors.grey), // 기본 라벨 색상
          //     counterText: '${parentPhoneController.text.length}/20',
          //     enabledBorder: OutlineInputBorder(
          //       borderSide: BorderSide(color: Colors.transparent),
          //       borderRadius: BorderRadius.circular(8.0),
          //     ),
          //     focusedBorder: OutlineInputBorder(
          //       borderSide: BorderSide(color: Colors.transparent),
          //       borderRadius: BorderRadius.circular(8.0),
          //     ),
          //     filled: true,
          //     fillColor: ColorDatas.background,
          //   ),
          //   cursorColor: Colors.grey, // 커서 색상
          //   controller: parentPhoneController,
          //   inputFormatters: [
          //     LengthLimitingTextInputFormatter(20),
          //   ],
          //   onChanged: (text) {
          //     // Force the widget to rebuild to show the character count
          //     (context as Element).markNeedsBuild();
          //   },
          // ),
          SizedBox(height: 16),
          MyOpacityRisingWidget(child: SmallRoundedButton(
            buttonText: "추가하기",
            // width: double.infinity,
            height: 60.0,
            color: ColorDatas.secondary,
            textColor: ColorDatas.onPrimaryTitle,
            onPressed: ()async{
              var suc = await BusDataViewModel.to.addStudent(
                  StudentData(
                      name: studentTextController.nameController.value.text,
                      busId: BusDataViewModel.to.targetBusId,
                      description: studentTextController.fromController.value.text=="" ? "0-0" : studentTextController.fromController.value.text,
                      isArrived: false,
                      isAbsent: false,
                      temporary: widget.forTemp
                  )
              );
              if(!suc){
                Get.snackbar("학생 추가 실패", "학생 이름은 비워둘 수 없습니다.", colorText: Colors.red);
                return;
              }
              // Get.snackbar("학생이 추가되었습니다.", "", colorText: Colors.green);
              studentTextController.clear();
              Get.find<BottomBoxPageController>().pageNumber.value = 0;
              Get.find<BottomBoxAnimationController>().toggle();
              if(widget.forTemp)
                Navigator.pop(context);
            },
          ), startTime: 150)
          // SizedBox(height: 24),
        ],
      ),
    );
  }
}



class StudentListPage extends StatelessWidget {
  const StudentListPage({super.key});

  Widget getPage(int a){

    if(a == 0){
      return mainPage();
    }
    else if(a == 1){
      return addStudentPage(
        forTemp: false,
      );
    }
    else if(a == 4){
      return seeApplicationPage();
    }
    return Text("error");
  }

  @override
  Widget build(BuildContext context) {
    final animCon = Get.put(BottomBoxAnimationController());
    final pageCon = Get.put(BottomBoxPageController());

    return Scaffold(
        backgroundColor: ColorDatas.background,
        appBar: AppBar(),
        body: Padding(
            padding: DefaultDatas.pagePadding,
            child: Stack(
              children: [
                Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Row(
                          children: [
                            const Text(
                              "학생 명단 관리하기",
                              style: TextDatas.title,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Obx(() {
                          if (BusDataViewModel.to.sortedStudents.isEmpty) {
                            return Center(
                              child: Text('아직 학생이 없습니다.', style: TextDatas.description),
                            );
                          }
                          return ListView.builder(
                            itemCount: BusDataViewModel.to.sortedStudents.length + 1,
                            itemBuilder: (context, index) {
                              if (index == BusDataViewModel.to.sortedStudents.length) {
                                return SizedBox(height: 80);
                              }
                              var item = BusDataViewModel.to.sortedStudents[index];
                              return UserListItem(
                                name: item.name,
                                description: item.description,
                                actions: [
                                  IconButton(
                                    icon: Icon(Icons.delete_outline),
                                    onPressed: () {
                                      showDialog(context: context, builder: (_)=>MyAlertDialog(
                                          title: "학생 삭제",
                                          content: "정말로 ${item.name} 학생을 삭제하시겠습니까?",
                                          confirmColor: Colors.red,
                                          onConfirm: (){
                                            // Get.snackbar("학생이 삭제되었습니다.\n-> ${item.name}", "", colorText: Colors.red);
                                            BusDataViewModel.to.removeStudent(item.ID);
                                            Navigator.pop(context);
                                          },
                                          onCancel: (){
                                            Navigator.pop(context);
                                          }
                                      ));
                                    },
                                  )
                                ],
                              );
                            },
                          );
                        }),
                      ),

                    ]),
                Align(
                  child: Obx(
                          (){
                        return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: double.infinity,
                            height: animCon.isExpanded.value ? 400 : 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorDatas.shadow,
                                  offset: const Offset(0, 4),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: animCon.isExpanded.value
                                ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:[
                                  Center(
                                    child: IconButton(
                                        onPressed: (){
                                          animCon.toggle();
                                          pageCon.pageNumber.value = 0;
                                          try {
                                            Get.find<StudentTextController>()
                                                .clear();
                                          }
                                          catch(e){
                                            print("no sttextcontroller");
                                          }
                                        },
                                        icon: Icon(Icons.keyboard_arrow_down)
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Expanded(
                                      child: ScrollConfiguration(
                                        behavior: ScrollBehavior().copyWith(overscroll: false),
                                        child: SizedBox( // singlechildscrollview
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 24),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: getPage(pageCon.pageNumber.value),
                                            ),
                                          ),
                                        ),
                                      )
                                  ),
                                ]
                            )
                                : Column(
                              children: [
                                IconButton(
                                    onPressed: (){
                                      animCon.toggle();
                                    },
                                    icon: Icon(Icons.keyboard_arrow_up)
                                ),
                              ],
                            )
                        );
                      }
                  ),
                  alignment: Alignment.bottomCenter,
                )
              ],
            )
        )
    );
  }
}


class BottomBoxAnimationController extends GetxController{
  var isExpanded = false.obs;
  void toggle() => isExpanded.value = !isExpanded.value;
}

class BottomBoxPageController extends GetxController{
  var pageNumber = 0.obs;
}

class SmallRoundedButton extends StatelessWidget {
  var buttonText = "";
  var height = 60.0;
  var color = ColorDatas.primary;
  var textColor = ColorDatas.onPrimaryContent;
  Function onPressed = (){};

  SmallRoundedButton({
    super.key,
    required this.buttonText,
    this.height = 60,
    this.color = ColorDatas.primary,
    this.textColor = ColorDatas.onPrimaryContent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height,
        child: MyAnimatedButton(
            onPressed: (){onPressed();},
            child: Center(
              child: Text(buttonText,
                style: TextDatas.description.copyWith(
                    color: textColor
                ),
              ),
            ),
            color: color
        )
    );
  }
}


class UserListItem extends StatelessWidget {

  final name;
  final description;
  List<Widget>? actions;

  UserListItem({
    super.key,
    required this.name,
    this.description,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyAnimatedButton(
          color: ColorDatas.background,
          onPressed: () {},
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24),
            child: Row(
              children: [
                Text(
                  truncateWithEllipsis(4, name, dotsAtEnd: false),
                  style: TextDatas.description.copyWith(
                    fontSize: 20,
                    // fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(width: 8),
                Text(
                  truncateWithEllipsis(4, description) ?? "",
                  style: TextDatas.description.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(child: SizedBox(),),
                if(actions != null)
                  Row(
                    children: actions!,
                  )
              ],
            ),
          ),
        ),
        Divider(
          color: ColorDatas.backgroundSoft,
        )
      ],
    );;
  }
}



String truncateWithEllipsis(int cutoff, String? text, {bool dotsAtEnd = true}) {
  if(text == null){
    return "";
  }
  if (text.length <= cutoff) {
    return text;
  } else {
    if(dotsAtEnd){
      return text.substring(0, cutoff) + "...";
    }
    return text.substring(0, cutoff);
  }
}


class MyLineButton extends StatelessWidget {

  String text;
  final onPressed;

  MyLineButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MyAnimatedButton(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: ColorDatas.onBackgroundSoft,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(
                text,
                style: TextDatas.description.copyWith(
                  fontSize: 18,
                ),
              ),
            ],
          )
        ],
      ),
    ),
        onPressed: onPressed ?? (){},
        color: Colors.transparent
    );
  }
}
