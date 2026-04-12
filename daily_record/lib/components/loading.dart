import 'package:daily_record/core/themes/theme.dart';
import 'package:daily_record/core/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoadingAnimation extends StatefulWidget {
  final double width;
  final double height;
  const LoadingAnimation({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final themeItem = context.watch<ThemeProvider>().currentThemeItem!;
    return Center(
      child: Stack(
        children: [
          Box1(width: widget.width, height: widget.height, theme: themeItem),
          Box2(width: widget.width, height: widget.height, theme: themeItem),
        ],
      ),
    );
  }
}

class Box1 extends StatefulWidget {
  final double width;
  final double height;
  final ThemeItem theme;
  const Box1({
    super.key,
    required this.width,
    required this.height,
    required this.theme,
  });

  @override
  State<Box1> createState() => _Box1State();
}

class _Box1State extends State<Box1> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> scaleX;
  late Animation<double> scaleY;
  late Animation<Alignment> alignmentAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // Alignment ต้องเปลี่ยนตาม step:
    // Step1 (0→25%):   bottomRight (ลด height ลง ยึดล่างขวา)
    // Step2 (25→50%):  bottomRight (ขยาย width จากขวาไปซ้าย)
    // Step3 (50→75%):  bottomLeft  (ลด width จากขวาไปซ้าย = ยึดซ้าย)
    // Step4 (75→100%): bottomLeft  (คงที่)
    alignmentAnim = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomRight,
          end: Alignment.bottomRight,
        ),
        weight: 25, // Step1: 0→25%
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomRight,
          end: Alignment.bottomRight,
        ),
        weight: 25, // Step2: 25→50%
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomLeft,
          end: Alignment.bottomLeft,
        ),
        weight: 25, // Step3: 50→75%
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.bottomLeft,
          end: Alignment.bottomLeft,
        ),
        weight: 25, // Step4: 75→100%
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.centerLeft,
          end: Alignment.centerLeft,
        ),
        weight: 25, // Step4: 75→100%
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.centerRight,
          end: Alignment.centerRight,
        ),
        weight: 15, // Step4: 75→100%
      ),
    ]).animate(_controller);

    // scaleY:
    // Step1 (0→25%):    1.0 → 0.5  (ลด height)
    // Step2–4 (25→100%): 0.5 คงที่
    scaleY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.5,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25, // Step1
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.5),
        weight: 25, // Step2
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.5),
        weight: 25, // Step3
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.5,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25, // Step4
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 25, // Step5
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 15, // Step6
      ),
    ]).animate(_controller);

    // scaleX:
    // Step1 (0→25%):   0.5 คงที่  (ยังไม่เปลี่ยน width)
    // Step2 (25→50%):  0.5 → 1.0  (ขยายจากขวาไปซ้าย)
    // Step3 (50→75%):  1.0 → 0.5  (ลดจากขวาไปซ้าย = ยึด anchor ซ้าย)
    // Step4 (75→100%): 0.5 คงที่
    scaleX = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0.5),
        weight: 25, // Step1
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.5,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25, // Step2
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.5,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25, // Step3
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.5),
        weight: 25, // Step4
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.5,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25, // Step5
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.5,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15, // Step6
      ),
    ]).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            alignment: alignmentAnim.value,
            scaleX: scaleX.value,
            scaleY: scaleY.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(color: widget.theme.secondary),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Box2 extends StatefulWidget {
  final double width;
  final double height;
  final ThemeItem theme;
  const Box2({
    super.key,
    required this.width,
    required this.height,
    required this.theme,
  });

  @override
  State<Box2> createState() => _Box2State();
}

class _Box2State extends State<Box2> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> scaleX;
  late Animation<double> scaleY;
  late Animation<Alignment> alignmentAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    alignmentAnim = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: AlignmentTween(begin: Alignment.topLeft, end: Alignment.topLeft),
        weight: 25, // Step1: 0→25%
      ),
      TweenSequenceItem(
        tween: AlignmentTween(begin: Alignment.topLeft, end: Alignment.topLeft),
        weight: 25, // Step2: 25→50%
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.topRight,
          end: Alignment.topRight,
        ),
        weight: 25, // Step3: 50→75%
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.topRight,
          end: Alignment.topRight,
        ),
        weight: 25, // Step4: 75→100%
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.centerRight,
          end: Alignment.centerRight,
        ),
        weight: 25, // Step4: 75→100%
      ),
      TweenSequenceItem(
        tween: AlignmentTween(
          begin: Alignment.centerLeft,
          end: Alignment.centerLeft,
        ),
        weight: 15, // Step4: 75→100%
      ),
    ]).animate(_controller);

    // scaleY:
    scaleY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.5,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25, // Step1
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.5),
        weight: 25, // Step2
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.5),
        weight: 25, // Step3
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.5,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25, // Step4
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 25, // Step5
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 15, // Step6
      ),
    ]).animate(_controller);

    // scaleX:
    scaleX = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(0.5),
        weight: 25, // Step1
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.5,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25, // Step2
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.5,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25, // Step3
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.5),
        weight: 25, // Step4
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.5,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25, // Step5
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.5,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15, // Step6
      ),
    ]).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            alignment: alignmentAnim.value,
            scaleX: scaleX.value,
            scaleY: scaleY.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(color: widget.theme.primary),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
