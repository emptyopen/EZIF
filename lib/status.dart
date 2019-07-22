import 'package:flutter/material.dart';
import 'dart:math' as math;

class Status extends StatefulWidget {
  final Color color;
  final AnimationController controller;

  const Status({Key key, this.color, this.controller}): super(key: key);

  @override
  _StatusState createState() => _StatusState();
}

class _StatusState extends State<Status> {

  String get timerString {
    Duration duration = widget.controller.duration * widget.controller.value;
    return '${(duration.inHours).toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 3600 % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
      Expanded(
      child: Align(
        alignment: FractionalOffset.center,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: widget.controller,
                  builder: (BuildContext context, Widget child) {
                    return CustomPaint(
                        painter: TimerPainter(
                          animation: widget.controller,
                          backgroundColor: Colors.white,
                          color: Colors.pinkAccent,
                        ));
                  },
                ),
              ),
              Align(
                alignment: FractionalOffset.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "EATING",
                      style: TextStyle(
                          fontSize: 30
                      ),
                    ),
                    AnimatedBuilder(
                        animation: widget.controller,
                        builder: (BuildContext context, Widget child) {
                          return Text(
                            timerString,
                            style: TextStyle(
                              fontSize: 70,
                            ),
                          );
                        }),
                    Text(
                        ''
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )]));
  }
}

class TimerPainter extends CustomPainter {
  TimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}

