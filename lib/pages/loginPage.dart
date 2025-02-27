import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:walking/Controllers/authController.dart';
import 'package:walking/datas.dart';
import 'package:walking/pages/splashPage.dart';
import 'package:walking/widgets/animations.dart';
import 'package:walking/widgets/buttons.dart';

import '../widgets/riveAnim.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: DefaultDatas.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: DefaultDatas.noRoundPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: OverflowBox(
                          maxWidth: 154,
                          maxHeight: 154,
                          child: MyLogoAnim(),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    MyOpacityRisingWidget(
                      child: Text("워킹 스쿨버스에\n오신 것을 환영합니다.",
                          style: TextDatas.title
                      ),
                      startTime: 300,
                    ),
                    SizedBox(height: 12),
                    MyOpacityRisingWidget(
                      child: Text('"워킹 스쿨버스"는 워킹스쿨버스 지도자 분들을 위한 어플리케이션입니다. 온라인 공동 출석체크, 학부모, 학생 명단 관리 기능을 사용하실 수 있습니다.',
                          style: TextDatas.description
                      ),
                      startTime: 500,
                    ),
                  ],
                ),
              ),
              Expanded(child: SizedBox()),
              // MyOpacityRisingWidget(
              //   startTime: 900,
              //   child: Container(
              //     width: 100,
              //     height: 100,
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: DefaultDatas.borderRadius,
              //       boxShadow: [
              //         BoxShadow(
              //           color: ColorDatas.shadow,
              //           offset: Offset(0, 2),
              //           blurRadius: 4,
              //         )
              //       ].toList()
              //     ),
              //   ),
              // ),
              SizedBox(height: 16),
              MyOpacityRisingWidget(
                startTime: 900,
                child: SizedBox(
                  width: double.infinity,
                  child: Obx(() { // Obx로 Rx 상태를 감시
                    return MyAnimatedButton(
                      onPressed: AuthViewModel.to.isLoading.value
                          ? (){} // 로딩 중일 때 버튼 비활성화
                          : () {
                        AuthViewModel.to.loginWithKakao().then((value){
                          if(value)
                          Get.offAllNamed('/busSelection');
                        });
                      },
                      child: Center(
                        child: Padding(
                          padding: DefaultDatas.buttonPadding,
                          child: AuthViewModel.to.isLoading.value
                              ? SizedBox(
                            height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ColorDatas.onPrimaryContent,
                            ),
                          ),
                              )
                              : Text(
                            "지금 시작하기",
                            style: TextDatas.title.copyWith(
                              color: ColorDatas.onPrimaryContent,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      color: ColorDatas.secondary,
                    );
                  }),
                ),
              ),

              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
