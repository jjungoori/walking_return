import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:walking/datas.dart';

//
// class MyMaskRisingWidget extends StatefulWidget {
//   final Widget child;
//   final int startTime; // 애니메이션 시작 시간 (초 단위)
//   final double height; // 위젯의 높이
//
//   MyMaskRisingWidget({
//     required this.child,
//     required this.startTime,
//     required this.height
//   });
//
//   @override
//   _MyMaskRisingWidgetState createState() => _MyMaskRisingWidgetState();
// }
//
// class _MyMaskRisingWidgetState extends State<MyMaskRisingWidget> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _positionAnimation;
//   late double _height;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // 애니메이션 컨트롤러 생성
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1000),
//     );
//
//     // 고정된 높이 설정
//     _height = widget.height;
//
//     // 위치 애니메이션 설정: 아래에서 위로 올라오는 애니메이션
//     _positionAnimation = Tween<Offset>(
//       begin: Offset(0, 1), // 아래에서 시작
//       end: Offset(0, 0),   // 제자리로 올라옴
//     ).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc),
//     );
//
//     // 딜레이 후 애니메이션 시작
//     Future.delayed(Duration(seconds: widget.startTime), () {
//       _controller.forward();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return ClipRect(
//           child: Container(
//             height: _height, // 높이를 고정하여 변경되지 않도록 설정
//             // color: Colors.red,
//             child: Stack(
//               alignment: Alignment.bottomCenter,
//               children: [
//                 // 위젯이 올라오는 애니메이션
//                 Positioned(
//                   bottom: -_height * _positionAnimation.value.dy, // 위치만 애니메이션
//                   child: widget.child,
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
class MyOpacityRisingWidget extends StatefulWidget {
  final int startTime; // 애니메이션 시작 시간 (밀리초 단위)
  final VoidCallback? onEnd;
  final bool hasRunned; // 애니메이션이 실행되었는지 여부
  final Widget child;

  MyOpacityRisingWidget({
    required this.child,
    required this.startTime,
    this.onEnd,
    this.hasRunned = false, // 기본값은 false
  });

  @override
  _MyOpacityRisingWidgetState createState() => _MyOpacityRisingWidgetState();
}

class _MyOpacityRisingWidgetState extends State<MyOpacityRisingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _positionAnimation;
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 생성
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 애니메이션 설정
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc),
    );

    _positionAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc));

    if (!widget.hasRunned) {
      _startAnimationWithDelay();
    }
    else{
      _controller.value = 1.0;
    }
  }

  void _startAnimationWithDelay() {
    if (_animationCompleted) return; // 이미 완료된 경우 실행 방지

    Future.delayed(Duration(milliseconds: widget.startTime), () {
      if (mounted && !_controller.isAnimating) {
        _controller.forward().then((_) {
          setState(() => _animationCompleted = true);
          widget.onEnd?.call();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant MyOpacityRisingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.startTime != widget.startTime) {
      // startTime 변경 시 상태 초기화
      _animationCompleted = false;
      _controller.reset();
      if (!widget.hasRunned) {
        _startAnimationWithDelay();
      }
      else{
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_animationCompleted) {
      // 애니메이션 완료 후 고정된 상태 반환
      return widget.child;
    }

    return SlideTransition(
      position: _positionAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}


class ShakingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double shakeOffset;

  const ShakingWidget({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.shakeOffset = 0.1,
  }) : super(key: key);

  @override
  _ShakingWidgetState createState() => _ShakingWidgetState();
}

class _ShakingWidgetState extends State<ShakingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -widget.shakeOffset, end: widget.shakeOffset)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}