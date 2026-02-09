import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;

  const Background({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: appBar,
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,

      body: Stack(
        children: [
          _BackGroundLayer(color: const Color(0xFFEB00B1), vMargin: 5),
          _BackGroundLayer(color: const Color(0xFFFFAAEA), vMargin: 15),
          _BackGroundLayer(color: Colors.white, vMargin: 25),

          SafeArea(child: child),
        ],
      ),
    );
  }

  Widget _BackGroundLayer({required Color color, double vMargin = 0}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: vMargin),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(40),
      ),
      width: double.infinity,
      height: double.infinity,
    );
  }
}
