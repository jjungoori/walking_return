import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:walking/Controllers/authController.dart';
import 'package:walking/Controllers/userDataController.dart';
import 'package:rive/rive.dart';
import 'package:flutter/services.dart';
import 'package:walking/datas.dart';
import 'package:walking/widgets/animations.dart';
import '../datas.dart';
import 'package:get/get.dart';

import '../widgets/riveAnim.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: DefaultDatas.pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyOpacityRisingWidget(
              child: Text(
                '오신 것을 환영해요!',
                style: TextDatas.splashTitle,
              ),
              startTime: 2000,
              onEnd: () async{
                while(AuthViewModel.to.isLoading.value){
                  await Future.delayed(Duration(milliseconds: 100));
                }
                if (AuthViewModel.to.isLoggedIn.value) {
                  while(CurrentUserDataViewModel.to.isLoading.value){
                    await Future.delayed(Duration(milliseconds: 100));
                  }
                  Get.offAllNamed('/busSelection');
                }
                else{
                  Get.offAllNamed('/login');
                }
              },
            ),
            Center(
              child:const MyLogoAnim(),
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
