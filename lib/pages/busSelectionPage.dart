import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walking/Controllers/authController.dart';
import 'package:walking/Controllers/userDataController.dart';
import 'package:walking/utils.dart';
import 'package:walking/widgets/alerts.dart';
import 'package:walking/widgets/animations.dart';
import 'package:walking/widgets/buttons.dart';
import 'package:walking/widgets/textFields.dart';

import '../Controllers/busDataController.dart';
import '../datas.dart';

Future<void> initBusData() async {
  await CurrentUserDataViewModel.to.checkIfNewUserAndInit();
  CurrentUserDataViewModel.to.fetchBusesForLeader();
}

class BusSelectionPage extends StatefulWidget {
  const BusSelectionPage({super.key});

  @override
  State<BusSelectionPage> createState() => _BusSelectionPageState();
}
class _BusSelectionPageState extends State<BusSelectionPage> {
  final ScrollController _scrollController = ScrollController();
  // final Set<int> _alreadyDisplayed = {}; // 이미 표시된 항목의 인덱스를 추적
  int previousBusCount = 0;
  var busesCanLoad = false.obs;

  @override
  void initState() {
    super.initState();

    initBusData();

    // busData 변경 감지 및 스크롤 동작 추가
    ever(CurrentUserDataViewModel.to.buses, (_) {
      if (_scrollController.hasClients && previousBusCount != 0 && CurrentUserDataViewModel.to.buses.length > previousBusCount) {
        Future.delayed(Duration(milliseconds: 50), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCirc,
          );
        });
      }
      previousBusCount = CurrentUserDataViewModel.to.buses.length;
    });

    Future.delayed(Duration(milliseconds: 200), (){
      busesCanLoad.value = true;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              showDialog(context: context, builder: (_){
                return MyAlertDialog(
                    title: "로그아웃",
                    content: "정말 로그아웃 하시겠습니까?",
                    onConfirm: () async{
                      if(await AuthViewModel.to.logout()){
                        Get.offAllNamed("/login");
                      }
                    },
                    onCancel: (){
                      Navigator.pop(context);
                    }
                );
              });
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: DefaultDatas.pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyOpacityRisingWidget(
                startTime: 300,
                child: Padding(
                  padding: DefaultDatas.noRoundPadding,
                  child: Text('버스 선택하기', style: TextDatas.title),
                ),
              ),
              SizedBox(height: 24),
              Obx(() {
                var count = CurrentUserDataViewModel.to.buses.length
                    + (CurrentUserDataViewModel.to.isLoadingForAddedBus.value ? 1 : 0);
                // var busCount = CurrentUserDataViewModel.to.buses.length;

                // print(UserDataController.to.buses[0]);

                if((CurrentUserDataViewModel.to.isLoading.value && count == 0) || !busesCanLoad.value){
                  return Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ColorDatas.primary,

                      ),
                    ),
                  );
                }
                return Expanded(
                  child: ScrollConfiguration(
                    behavior: const ScrollBehavior().copyWith(overscroll: false),
                    child: ListView.builder(
                      controller: _scrollController, // ScrollController 연결
                      itemCount: count + 1,
                      itemBuilder: (context, index) {
                        if (index < count) {
                          if(CurrentUserDataViewModel.to.isLoadingForAddedBus.value && index == count-1){
                            return MyOpacityRisingWidget(
                              child: MyAnimatedBusLoadingButton(),
                              startTime: 30,
                            );
                          }
                          // 애니메이션이 이미 실행되었는지 확인
                          // final isDisplayed = _alreadyDisplayed.contains(index);
                          // if (!isDisplayed) {
                          //   _alreadyDisplayed.add(index);
                          // }
                          return MyAnimatedBusButton(
                            title: CurrentUserDataViewModel.to.buses[index]["data"]["name"],
                            onLongPress: (){
                              showDialog(context: context, builder: (_){
                                return MyAlertDialog(
                                    title: "버스 삭제",
                                    content: "정말로 삭제하시겠습니까?",
                                    onConfirm: () async{
                                      Navigator.pop(context);
                                      await CurrentUserDataViewModel.to.deleteBus(
                                          CurrentUserDataViewModel.to.buses[index]["id"]
                                          // CurrentUserDataViewModel.to.buses[index]["data"]
                                      );
                                    },
                                    confirmColor: Colors.redAccent,
                                    onCancel: (){
                                      Navigator.pop(context);
                                    }
                                );
                              });
                            },
                            onPressed: (){
                              BusDataViewModel.to.setTargetBusId(
                                  CurrentUserDataViewModel.to.buses[index]['id']
                              );
                              Get.toNamed("/home");
                              // Get.toNamed("/home");
                            },
                          );
                          // return MyOpacityRisingWidget(
                          //   child: MyAnimatedBusButton(
                          //     title: BusDataController.to.buses[index]["name"],
                          //   ),
                          //   startTime: isDisplayed ? 0 : index*50,
                          // );
                        }
                        return MyOpacityRisingWidget(
                          child: MyAnimatedAddBusButton(
                            only: count == 0,
                          ),
                          startTime: 100,
                        );
                      },
                    ),
                  ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}



class MyAnimatedBusButton extends StatefulWidget {
  String title;
  final Function onPressed;
  final Function onLongPress;

  MyAnimatedBusButton({
    super.key,
    required this.title,
    required this.onPressed,
    required this.onLongPress,
  });

  @override
  State<MyAnimatedBusButton> createState() => _MyAnimatedBusButtonState();
}

class _MyAnimatedBusButtonState extends State<MyAnimatedBusButton> with AutomaticKeepAliveClientMixin{

  bool hasPlayedAnimation = false;

  @override
  get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 100), (){
        hasPlayedAnimation = true;
      });
    });

    return MyOpacityRisingWidget(
      startTime: 30,
      hasRunned: hasPlayedAnimation,
      child: Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: MyAnimatedButton(
          onLongPress: (){
            widget.onLongPress();
          },
          onPressed: (){
            widget.onPressed();
          },
          child: Padding(
            padding: DefaultDatas.buttonPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(
                //   child: Image.asset("assets/images/plusIcon.png"),
                //   width: 24,
                //   height: 24,
                // ),
                // SizedBox(width: 18,),
                Text(widget.title,
                    style: TextDatas.description.copyWith(
                      color: ColorDatas.onPrimaryTitle,
                    )
                )
              ],
            ),
          ),
          color: Colors.white,
          gradient: LinearGradient(
              colors: [
                ColorDatas.primary,
                ColorDatas.secondary
              ],
              end: Alignment.topLeft,
              begin: Alignment.bottomRight
          ),
        ),
      ),
    );
  }
}


class MyAnimatedBusLoadingButton extends StatelessWidget {
  MyAnimatedBusLoadingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: MyAnimatedButton(
        onPressed: (){},
        child: Padding(
          padding: DefaultDatas.buttonPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // SizedBox(
              //   child: Image.asset("assets/images/plusIcon.png"),
              //   width: 24,
              //   height: 24,
              // ),
              // SizedBox(width: 18,),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: ColorDatas.primary,
                ),
              ),
            ],
          ),
        ),
        color: Colors.white,
        gradient: LinearGradient(
            colors: [
              ColorDatas.primary,
              ColorDatas.secondary
            ],
            end: Alignment.topLeft,
            begin: Alignment.bottomRight
        ),
      ),
    );
  }
}

class MyAnimatedAddBusButton extends StatelessWidget {

  final bool only;

  MyAnimatedAddBusButton({
    super.key,
    this.only = false
  });

  final minSize = 140.0;

  @override
  Widget build(BuildContext context) {
    return MyAnimatedButton(
      onPressed: (){
        // Get.bottomSheet(
        //
        // );
        myShowModalBottomSheet(context, Material(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Text("버스 추가하기",
              //   style: TextDatas.title,
              // ),
              // SizedBox(height: 22,),
              AspectRatio(
                aspectRatio: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          width: max(constraints.maxHeight*0.7, minSize),
                          // height: constraints.maxWidth < minSize ? constraints.maxWidth : minSize,
                          child: AspectRatio(
                              aspectRatio: 1, // 1:1 비율 유지
                              child: MyAnimatedSquareButton(
                                color: ColorDatas.background,
                                shadows: [
                                  BoxShadow(
                                    color: ColorDatas.shadow,
                                    offset: Offset(0, 0),
                                    blurRadius: 16,
                                  )
                                ],
                                title: Text("내가 만들기",
                                    style: TextDatas.subtitle
                                ),
                                description: SizedBox(),
                                onPressed: (){
                                  // UserDataController.to.createBus("busName", "busDescription");
                                  Navigator.pop(context);
                                  myShowModalBottomSheet(context,
                                    Builder(
                                      builder: (context) {
                                        TextEditingController busNameController = TextEditingController();
                                        TextEditingController busDescriptionController = TextEditingController();
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            MyTextField(
                                              title: "버스 이름",
                                              controller: busNameController,
                                              maxLength: 20,
                                            ),
                                            SizedBox(height: 8,),
                                            MyTextField(
                                              title: "버스 설명",
                                              controller: busDescriptionController,
                                              maxLength: 20,
                                            ),
                                            SizedBox(height: 16,),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 60,
                                              child: MyAnimatedButton(
                                                  onPressed: (){
                                                    CurrentUserDataViewModel.to.createBusAndAddToLeader(
                                                        busNameController.text,
                                                        busDescriptionController.text
                                                    );
                                                    Navigator.pop(context);
                                                  },
                                                  child: Center(
                                                    child: Text("버스 만들기!",
                                                      style: TextDatas.description.copyWith(
                                                        color: ColorDatas.onPrimaryTitle,
                                                      ),
                                                    ),
                                                  ),
                                                  color: ColorDatas.secondary,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    )
                                  );
                                },
                              )
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 8,),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          width: max(constraints.maxHeight*0.7, minSize),
                          child: AspectRatio(
                              aspectRatio: 1, // 1:1 비율 유지
                              child: MyAnimatedSquareButton(
                                color: ColorDatas.background,
                                shadows: [
                                  BoxShadow(
                                    color: ColorDatas.shadow,
                                    offset: Offset(0, 0),
                                    blurRadius: 16,
                                  )
                                ],
                                title: Text("참여하기",
                                  style: TextDatas.subtitle,
                                ),
                                description: SizedBox(),
                                onPressed: (){
                                  Navigator.pop(context);
                                  Get.toNamed('/scan');
                                },
                              )
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),);
        // BusDataController.to.addBusData(MyBusData(name: "Capybara"));
      },
      child: Padding(
        padding: DefaultDatas.buttonPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              child: Image.asset("assets/images/plusIcon.png",
                color: only ? ColorDatas.onPrimaryTitle : ColorDatas.onBackgroundSoft,
              ),
              width: 24,
              height: 24,
            ),
            SizedBox(width: 18,),
            Text("버스 추가하기",
                style: TextDatas.description.copyWith(
                  color: only ? ColorDatas.onPrimaryTitle : ColorDatas.onBackgroundSoft,
                )
            )
          ],
        ),
      ),
      color: only ? ColorDatas.secondary : Colors.transparent,
    );
  }
}
