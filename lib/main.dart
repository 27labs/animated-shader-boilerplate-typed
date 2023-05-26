import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const HelloTime());
}

class HelloTime extends StatelessWidget {
  const HelloTime({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: ShadedArea(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ShadedArea extends StatelessWidget {
  const ShadedArea({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: FragmentProgram.fromAsset('shaders/animated.frag'),
    builder: (BuildContext innerContext, AsyncSnapshot<FragmentProgram> snapshot) {
      if(snapshot.hasData) {
        return TimedShader(shader: snapshot.data!.fragmentShader());
      }
      return const Center(child: CircularProgressIndicator(),);
    },
  );
}

class TimedShader extends StatefulWidget {
  final FragmentShader shader;
  const TimedShader({required this.shader, super.key});

  @override
  State<TimedShader> createState() => TimedShaderState();
}

class TimedShaderState extends State<TimedShader> with SingleTickerProviderStateMixin {
  Ticker? clock;
  double time = 0;

  @override
  void initState() {
    super.initState();
    clock = createTicker((Duration elapsed) {
      const double pace = 0.001;
      setState(() {
        time = elapsed.inMilliseconds * pace;
      });
    })..start();
  }

  @override
  void dispose() {
    clock?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
          size: const Size.square(double.infinity),
          painter: FragmentPainter(shader: widget.shader, time: time),
        );
}

class FragmentPainter extends CustomPainter {
  final FragmentShader shader;
  final double time;
  FragmentPainter({required this.shader, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, time);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader
    );
  }

  @override
  bool shouldRepaint(FragmentPainter oldDelegate) => oldDelegate.time != time;
}