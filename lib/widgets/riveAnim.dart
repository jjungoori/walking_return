
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class MyLogoAnim extends StatefulWidget {
  const MyLogoAnim({super.key});

  @override
  State<MyLogoAnim> createState() => _MyLogoAnimState();
}

class _MyLogoAnimState extends State<MyLogoAnim> {
  Artboard? _riveArtboard;
  RiveFile? file;

  Future<void> preload() async{
    await rootBundle.load('assets/videos/logoAnim.riv').then(
          (data) async {
        file = RiveFile.import(data);
      },
    );
  }

  @override
  void initState() {
    super.initState();

    if(file == null){
      preload().then((value) {
        final artboard = file!.mainArtboard;
        var controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
        if (controller != null) {
          artboard.addController(controller);
        }
        setState(() => _riveArtboard = artboard);
      });
    }
    else{
      final artboard = file!.mainArtboard;
      var controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
      if (controller != null) {
        artboard.addController(controller);
      }
      setState(() => _riveArtboard = artboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 250,
      child: _riveArtboard == null
          ? const SizedBox() // 로딩 중 상태를 보여줌
          : Rive(
        artboard: _riveArtboard!,
      ),
    );
  }
}


