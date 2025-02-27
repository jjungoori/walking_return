import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:lottie/lottie.dart';
import 'package:walking/datas.dart';
import 'package:walking/widgets/animations.dart';
import 'package:walking/widgets/buttons.dart';
import 'package:walking/widgets/textFields.dart';
import 'package:rive/rive.dart';

class WidgetsPage extends StatelessWidget {
  const WidgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // MyTextButton(
            //   onPressed: (){},
            //   text: "text",
            //   color: ColorDatas.button,
            // ), //center widget -> expand 효과
            // MyButton(
            //     onPressed: (){},
            //     child: Text("text"),
            //   color: ColorDatas.button,
            // ),
            // SizedBox(
            //   height: 200,
            //   child:
            //   MySquareButton(
            //     title: "title",
            //     description: "description",
            //     color: ColorDatas.button,
            //   ),
            // ),
            // MyAnimatedButton(
            //   child: Text("text"),
            //   color: ColorDatas.button,
            //   onPressed: (){},
            // ),
            // MyTextField(
            //   hintText: "hintText",
            //   title: "title",
            // ),
            // SizedBox(
            //   child: MyRiveLogoAnimation(),
            //   height: 800,
            // )
            // SizedBox(
            //   height: 200,
            //   child: MyAnimatedSquareButton(
            //       title: "title",
            //       description: "description",
            //       color: ColorDatas.button
            //   )
            // ),
            // SizedBox(
            //   height: 200,
            //   child: MyAnimatedAddButton()
            // ),
            // MyAnimatedBusButton(
            //   title: "asdlfj",
            // )

            // Lottie.asset(
            //   'assets/videos/logoAnim.json',
            //   width: 200,
            //   height: 200,
            //   fit: BoxFit.fill,
            //   repeat: false,
            //   options: LottieOptions(enableApplyingOpacityToLayers: true),
            // )
          ],
        ),
      ),
    );
  }
}

//
// class MyRiveLogoAnimation extends StatefulWidget {
//   const MyRiveLogoAnimation({super.key});
//
//   @override
//   State<MyRiveLogoAnimation> createState() => _MyRiveLogoAnimationState();
// }
//
// class _MyRiveLogoAnimationState extends State<MyRiveLogoAnimation> {
//
//   Artboard? _riveArtboard;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadRiveFile();
//   }
//
//   /// Rive 파일 로드 및 State Machine 초기화
//   void _loadRiveFile() async {
//     final data = await rootBundle.load('assets/videos/newlogoanim.riv');
//     final file = RiveFile.import(data);
//
//     final artboard = file.mainArtboard;
//     final stateMachineController = StateMachineController.fromArtboard(
//       artboard,
//       'State Machine 1', // Rive 편집기에서 정의한 State Machine 이름
//     );
//
//     if (stateMachineController != null) {
//       artboard.addController(stateMachineController);
//
//     }
//
//     setState(() {
//       _riveArtboard = artboard;
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 250,
//       height: 250,
//       child: Rive(artboard: _riveArtboard!),
//     );
//   }
// }