import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walking/pages/studentListPage.dart';

import '../datas.dart';

class AllFunctionsPage extends StatefulWidget {
  const AllFunctionsPage({super.key});

  @override
  State<AllFunctionsPage> createState() => _AllFunctionsPageState();
}

class _AllFunctionsPageState extends State<AllFunctionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Stack(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                        const Text(
                          "추가 기능 보기",
                          style: TextDatas.title,
                        ),
                      ],
                  ),
                const SizedBox(height: 16),
                MyLineButton(
                    text: "연속으로 학생 추가하기",
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
                            forTemp: false,
                          ),
                        ),
                      );
                    });
                  },
                ),
                MyLineButton(
                    text: "지도자 목록 보기",
                    onPressed: (){
                      Get.toNamed('/leaderList');
                    },
                ),
                MyLineButton(
                  text: "학생 목록 보기",
                  onPressed: (){
                    Get.toNamed('/studentList');
                  },
                ),
              ]
            ),
          ]
        )
      )
    );
  }
}
