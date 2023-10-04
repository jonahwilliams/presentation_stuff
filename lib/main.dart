import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const AnimatingDiagram());
}

// Standard MSAA pattern on -8 to 8 scale.
const kMSAAPattern = [
  Offset(-2, -6),
  Offset(6, -2),
  Offset(-6, 2),
  Offset(2, 6)
];
final kScaledMSAAPAttern = [
  for (var pattern in kMSAAPattern)
    pattern.scale(5.0 / 8, 5.0 / 8)
];

class AnimatingDiagram extends StatefulWidget {
  const AnimatingDiagram({super.key});

  @override
  State<AnimatingDiagram> createState() => _AnimatingDiagramState();
}

class _AnimatingDiagramState extends State<AnimatingDiagram>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    Timer(const Duration(seconds: 1), () {
      _controller.addListener(() {
        setState(() {});
      });
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var data = MediaQuery.of(context).size;
    return Center(
      child: CustomPaint(
        painter: OverlappingEdge(_controller.value),
        size: data,
      ),
    );
  }
}

class Stage1 extends CustomPainter {
  Stage1(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    var pt1_t = Curves.decelerate.transform((value * 2).clamp(0.0, 1.0));
    var pt2_t = Curves.decelerate.transform((value - 0.5).clamp(0.0, 1.0));

    var linePaint = Paint()..color = Colors.grey;
    for (var i = 0.0; i < size.height; i += 10) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
    for (var i = 0.0; i < size.width; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    var center = Offset(size.width / 2, size.height / 2);
    var points = <Offset>[center, center, center, center, center, center];
    var endPoints = <Offset>[
      Offset(size.width / 4, size.height / 4),
      Offset(3 * size.width / 4, size.height / 4),
      Offset(size.width / 4, 3 * size.height / 4),
      Offset(3 * size.width / 4, size.height / 4),
      Offset(size.width / 4, 3 * size.height / 4),
      Offset(3 * size.width / 4, 3 * size.height / 4),
    ];

    var tweenedPoints = [
      for (var i = 0; i < 6; i++)
        Offset(lerpDouble(points[i].dx, endPoints[i].dx, pt1_t)!,
            lerpDouble(points[i].dy, endPoints[i].dy, pt1_t)!)
    ];

    canvas.drawPoints(
        PointMode.points,
        tweenedPoints,
        Paint()
          ..color = Colors.blue
          ..strokeWidth = 8);
    canvas.drawPoints(
        PointMode.polygon,
        [
          tweenedPoints[0],
          tweenedPoints[1],
          tweenedPoints[2],
          tweenedPoints[0]
        ],
        Paint()
          ..color = Colors.blue.withOpacity(pt2_t)
          ..strokeWidth = 2);
    canvas.drawPoints(
        PointMode.polygon,
        [
          tweenedPoints[3],
          tweenedPoints[4],
          tweenedPoints[5],
          tweenedPoints[3]
        ],
        Paint()
          ..color = Colors.blue.shade100.withOpacity(pt2_t)
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Stage2 extends CustomPainter {
  Stage2(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    var linePaint = Paint()..color = Colors.grey;
    for (var i = 0.0; i < size.height; i += 10) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
    for (var i = 0.0; i < size.width; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    var endPoints = <Offset>[
      Offset(size.width / 4, size.height / 4),
      Offset(3 * size.width / 4, size.height / 4),
      Offset(size.width / 4, 3 * size.height / 4),
      Offset(3 * size.width / 4, size.height / 4),
      Offset(size.width / 4, 3 * size.height / 4),
      Offset(3 * size.width / 4, 3 * size.height / 4),
    ];
    var t = Curves.decelerate.transform(value);

    canvas.drawPoints(
        PointMode.points,
        endPoints,
        Paint()
          ..color = Colors.blue.withOpacity((0.8 - t).clamp(0.0, 1.0))
          ..strokeWidth = 8);
    canvas.drawPoints(
        PointMode.polygon,
        [endPoints[0], endPoints[1], endPoints[2], endPoints[0]],
        Paint()
          ..color = Colors.blue.withOpacity((0.8 - t).clamp(0.0, 1.0))
          ..strokeWidth = 2);
    canvas.drawPoints(
        PointMode.polygon,
        [endPoints[3], endPoints[4], endPoints[5], endPoints[3]],
        Paint()
          ..color = Colors.blue.shade100.withOpacity((0.8 - t).clamp(0.0, 1.0))
          ..strokeWidth = 2);

    // Fill Grid.
    for (var i = 0.0; i < size.height; i += 10) {
      for (var j = 0.0; j < size.width; j += 10) {
        if (j >= size.width / 4 &&
            j < 3 * size.width / 4 &&
            i >= size.height / 4 &&
            i < 3 * size.height / 4) {
          canvas.drawRect(Rect.fromLTWH(j, i, 10, 10),
              Paint()..color = Colors.blue.withOpacity(t.clamp(0, 0.8)));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class AnalyticalCircle extends CustomPainter {
  AnalyticalCircle(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    var linePaint = Paint()..color = Colors.grey;
    for (var i = 0.0; i < size.height; i += 10) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
    for (var i = 0.0; i < size.width; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    var endPoints = <Offset>[
      Offset(size.width / 4, size.height / 4),
      Offset(3 * size.width / 4, size.height / 4),
      Offset(size.width / 4, 3 * size.height / 4),
      Offset(3 * size.width / 4, size.height / 4),
      Offset(size.width / 4, 3 * size.height / 4),
      Offset(3 * size.width / 4, 3 * size.height / 4),
    ];
    var t = Curves.decelerate.transform(value);

    canvas.drawPoints(
        PointMode.points,
        endPoints,
        Paint()
          ..color = Colors.blue.withOpacity((0.8 - t).clamp(0.0, 1.0))
          ..strokeWidth = 8);
    canvas.drawPoints(
        PointMode.polygon,
        [endPoints[0], endPoints[1], endPoints[2], endPoints[0]],
        Paint()
          ..color = Colors.blue.withOpacity((0.8 - t).clamp(0.4, 1.0))
          ..strokeWidth = 2);
    canvas.drawPoints(
        PointMode.polygon,
        [endPoints[3], endPoints[4], endPoints[5], endPoints[3]],
        Paint()
          ..color = Colors.blue.withOpacity((0.8 - t).clamp(0.4, 1.0))
          ..strokeWidth = 2);

    // Fill Grid.
    var r = math.min(size.width / 4, size.height / 4);
    var h = size.width / 2;
    var k = size.height / 2;
    for (var i = 0.0; i < size.height; i += 10) {
      for (var j = 0.0; j < size.width; j += 10) {
        if (math.pow(j - h + 5, 2) + math.pow(i - k + 5, 2) <= math.pow(r, 2)) {
          canvas.drawRect(Rect.fromLTWH(j, i, 10, 10),
              Paint()..color = Colors.blue.withOpacity(t.clamp(0, 0.8)));
        }
      }
    }
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        r,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class AnalyticalCircleWithAA extends CustomPainter {
  AnalyticalCircleWithAA(this.value, this.circles);

  final double value;
  final List<Color> circles;

  @override
  void paint(Canvas canvas, Size size) {
    var linePaint = Paint()..color = Colors.grey;
    for (var i = 0.0; i < size.height; i += 10) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
    for (var i = 0.0; i < size.width; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    var endPoints = <Offset>[
      Offset(size.width / 4, size.height / 4),
      Offset(3 * size.width / 4, size.height / 4),
      Offset(size.width / 4, 3 * size.height / 4),
      Offset(3 * size.width / 4, size.height / 4),
      Offset(size.width / 4, 3 * size.height / 4),
      Offset(3 * size.width / 4, 3 * size.height / 4),
    ];
    var t = Curves.decelerate.transform(value);

    canvas.drawPoints(
        PointMode.points,
        endPoints,
        Paint()
          ..color = Colors.blue.withOpacity((0.8 - t).clamp(0.0, 1.0))
          ..strokeWidth = 8);
    canvas.drawPoints(
        PointMode.polygon,
        [endPoints[0], endPoints[1], endPoints[2], endPoints[0]],
        Paint()
          ..color = Colors.blue.withOpacity((0.8 - t).clamp(0.4, 1.0))
          ..strokeWidth = 2);
    canvas.drawPoints(
        PointMode.polygon,
        [endPoints[3], endPoints[4], endPoints[5], endPoints[3]],
        Paint()
          ..color = Colors.blue.withOpacity((0.8 - t).clamp(0.4, 1.0))
          ..strokeWidth = 2);

    // Fill Grid.
    var r = math.min(size.width / 4, size.height / 4);
    var h = size.width / 2;
    var k = size.height / 2;
    for (var circle in circles) {
      for (var i = 0.0; i < size.height; i += 10) {
        for (var j = 0.0; j < size.width; j += 10) {
          var point = Offset(j + 5.0, i + 5.0);
          var percent = 0.0;
          for (var i = 0; i < 4; i++) {
            if (math.pow(point.dx - h + kScaledMSAAPAttern[i].dx, 2) +
                    math.pow(point.dy - k + kScaledMSAAPAttern[i].dy, 2) <=
                math.pow(r, 2)) {
              percent += 0.25;
            }
          }

          if (percent >= 0.0) {
            canvas.drawRect(Rect.fromLTWH(j, i, 10, 10),
                Paint()..color = circle.withOpacity(t.clamp(0, 1) * percent));
          }
        }
      }
    }

    //canvas.drawCircle(Offset(size.width / 2, size.height / 2), r, Paint()..color = Colors.red ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CircleSubdivision extends CustomPainter {
  CircleSubdivision(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    var linePaint = Paint()..color = Colors.grey;
    for (var i = 0.0; i < size.height; i += 10) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
    for (var i = 0.0; i < size.width; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    var t = Curves.decelerate.transform(value);
    var r = math.min(size.width / 4, size.height / 4);
    var h = size.width / 2;
    var k = size.height / 2;
    var center = Offset(size.width / 2, size.height / 2);

    var start = Offset(center.dx + r, center.dy);
    var points = <Offset>[start];
    var count = 16;
    for (var i = 1; i <= count; i++) {
      var angle = (i / count) * 2 * math.pi;
      var dx = math.cos(angle) * r + center.dx;
      var dy = math.sin(angle) * r + center.dy;
      points.add(Offset(dx, dy));
    }
    canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5);
    canvas.drawPoints(
        PointMode.polygon,
        points,
        Paint()
          ..color = Colors.blue.withOpacity(t)
          ..strokeWidth = 5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CircleTessellator extends CustomPainter {
  CircleTessellator(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    var linePaint = Paint()..color = Colors.grey;
    for (var i = 0.0; i < size.height; i += 10) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
    for (var i = 0.0; i < size.width; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    var t = Curves.decelerate.transform(value);
    var r = math.min(size.width / 4, size.height / 4);
    var h = size.width / 2;
    var k = size.height / 2;
    var center = Offset(size.width / 2, size.height / 2);

    var start = Offset(center.dx + r, center.dy);
    var points = <Offset>[start];
    var count = 32;
    for (var i = 1; i <= count; i++) {
      var angle = (i / count) * 2 * math.pi;
      var dx = math.cos(angle) * r + center.dx;
      var dy = math.sin(angle) * r + center.dy;
      points.add(Offset(dx, dy));
    }
    canvas.drawPoints(
        PointMode.polygon,
        points,
        Paint()
          ..color = Colors.blue.withOpacity(1.0 - t)
          ..strokeWidth = 5);
    for (var i = 2; i < (points.length * t).ceil(); i++) {
      canvas.drawPoints(
          PointMode.polygon,
          [
            points[0],
            points[i - 1],
            points[i],
            points[0],
          ],
          Paint()
            ..color = Colors.red
            ..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class TessellatedCircleRasterization extends CustomPainter {
  TessellatedCircleRasterization(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    var linePaint = Paint()..color = Colors.grey;
    for (var i = 0.0; i < size.height; i += 10) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
    for (var i = 0.0; i < size.width; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    var t = Curves.decelerate.transform(value);
    var r = math.min(size.width / 4, size.height / 4);
    var center = Offset(size.width / 2, size.height / 2);

    var start = Offset(center.dx + r, center.dy);
    var points = <Offset>[start];
    var count = 32;
    for (var i = 1; i <= count; i++) {
      var angle = (i / count) * 2 * math.pi;
      var dx = math.cos(angle) * r + center.dx;
      var dy = math.sin(angle) * r + center.dy;
      points.add(Offset(dx, dy));
    }
    var triangles = <List<Offset>>[];
    for (var i = 2; i < points.length; i++) {
      triangles.add([points[0], points[i - 1], points[i]]);
    }

    // From http://totologic.blogspot.com/2014/01/accurate-point-in-triangle-test.html
    bool pointInTriangle(double x1, double y1, double x2, double y2, double x3,
        double y3, double x, double y) {
      var denominator = ((y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3));
      var a = ((y2 - y3) * (x - x3) + (x3 - x2) * (y - y3)) / denominator;
      var b = ((y3 - y1) * (x - x3) + (x1 - x3) * (y - y3)) / denominator;
      var c = 1 - a - b;

      return 0 <= a && a <= 1 && 0 <= b && b <= 1 && 0 <= c && c <= 1;
    }

    for (var i = 0.0; i < size.height; i += 10) {
      for (var j = 0.0; j < size.width; j += 10) {
        var hit = false;

        for (var triangle in triangles) {
          var y = i + 5;
          var x = j + 5;
          if (pointInTriangle(triangle[0].dx, triangle[0].dy, triangle[1].dx,
              triangle[1].dy, triangle[2].dx, triangle[2].dy, x, y)) {
            hit = true;
            break;
          }
        }

        if (hit) {
          canvas.drawRect(Rect.fromLTWH(j, i, 10, 10),
              Paint()..color = Colors.blue.withOpacity(t.clamp(0, 0.8)));
        }
      }
    }

    for (var i = 2; i < points.length; i++) {
      canvas.drawPoints(
          PointMode.polygon,
          [
            points[0],
            points[i - 1],
            points[i],
            points[0],
          ],
          Paint()
            ..color = Colors.red.withOpacity(1.0)
            ..strokeWidth = 1);
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


class TessellatedCircleRasterizationMSAA extends CustomPainter {
  TessellatedCircleRasterizationMSAA(this.value, this.colors);

  final double value;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    var linePaint = Paint()..color = Colors.grey;
    for (var i = 0.0; i < size.height; i += 10) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
    for (var i = 0.0; i < size.width; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    var t = Curves.decelerate.transform(value);
    var r = math.min(size.width / 4, size.height / 4);
    var center = Offset(size.width / 2, size.height / 2);

    var start = Offset(center.dx + r, center.dy);
    var points = <Offset>[start];
    var count = 32;
    for (var i = 1; i <= count; i++) {
      var angle = (i / count) * 2 * math.pi;
      var dx = math.cos(angle) * r + center.dx;
      var dy = math.sin(angle) * r + center.dy;
      points.add(Offset(dx, dy));
    }
    var triangles = <List<Offset>>[];
    for (var i = 2; i < points.length; i++) {
      triangles.add([points[0], points[i - 1], points[i]]);
    }

    // From http://totologic.blogspot.com/2014/01/accurate-point-in-triangle-test.html
    bool pointInTriangle(double x1, double y1, double x2, double y2, double x3,
        double y3, double x, double y) {
      var denominator = ((y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3));
      var a = ((y2 - y3) * (x - x3) + (x3 - x2) * (y - y3)) / denominator;
      var b = ((y3 - y1) * (x - x3) + (x1 - x3) * (y - y3)) / denominator;
      var c = 1 - a - b;

      return 0 <= a && a <= 1 && 0 <= b && b <= 1 && 0 <= c && c <= 1;
    }

    Color srcOverBlend(Color src, Color dst) {
      var srcO = src.opacity;
      var srcR = (src.red / 255.0) * srcO;
      var srcG = (src.green / 255.0) * srcO;
      var srcB = (src.blue / 255.0) * srcO;

      var dstO = dst.opacity;
      var dstR = (dst.red / 255.0) * dstO;
      var dstG = (dst.green / 255.0) * dstO;
      var dstB = (dst.blue / 255.0) * dstO;

      var resR = srcR + (dstR * (1 - srcO));
      var resG = srcG + (dstG * (1 - srcO));
      var resB = srcB + (dstB * (1 - srcO));
      var resO = srcO + (dstO * (1 - srcO));
      if (resO <= 0.0) {
        return Colors.transparent;
      }

      return Color.fromRGBO(
        ((resR / resO) * 255).round(),
        ((resG / resO) * 255).round(),
        ((resB / resO) * 255).round(),
        resO.clamp(0, 1.0)
      );
    }

    // pattern goes clockwise from top left.
    var surfaceMSAA = <Offset, List<Color>>{};

    for (var color in colors) {
      var lerped = color.withOpacity(t);
      for (var i = 0.0; i < size.height; i += 10) {
        for (var j = 0.0; j < size.width; j += 10) {
          var hits = <bool>[false, false, false, false];
          var hitOne = false;

          for (var triangle in triangles) {
            for (var z = 0; z < 4; z++) {
              var y = i + kScaledMSAAPAttern[z].dy + 5;
              var x = j + kScaledMSAAPAttern[z].dx + 5;
              if (pointInTriangle(triangle[0].dx, triangle[0].dy, triangle[1].dx,
                  triangle[1].dy, triangle[2].dx, triangle[2].dy, x, y)) {
                hits[z] = true;
                hitOne = true;
              }
            }
          }
          if (hitOne) {
            var colors = surfaceMSAA.putIfAbsent(Offset(j, i), () => [Colors.transparent, Colors.transparent, Colors.transparent, Colors.transparent]);

            for (var i = 0; i < 4; i++) {
              if (hits[i]) {
                colors[i] = srcOverBlend(lerped, colors[i]);
              }
            }
          }
        }
      }
    }

    // for (var pair in surfaceMSAA.entries) {
    //   var values = pair.value;
    //   var red = values[0].red + values[1].red + values[2].red + values[3].red;
    //   var green = values[0].green + values[1].green + values[2].green + values[3].green;
    //   var blue = values[0].blue + values[1].blue + values[2].blue + values[3].blue;
    //   var alpha = values[0].opacity + values[1].opacity + values[2].opacity + values[3].opacity;
    //   var average = Color.fromRGBO(red ~/ 4, green ~/ 4, blue ~/ 4, alpha / 4);

    //   for (var i = 0; i < 4; i++) {
    //     if (values[i] == Colors.transparent) {
    //       values[i] = Colors.white;
    //     }
    //     canvas.drawCircle(pair.key + kScaledMSAAPAttern[i] + Offset(5, 5),  2, Paint()..color = values[i]);
    //   }
    // }
    // canvas.drawCircle(
    //     center,
    //     r,
    //     Paint()
    //       ..color = Colors.red
    //       ..style = PaintingStyle.stroke
    //       ..strokeWidth = 1);

    // for (var i = 2; i < points.length; i++) {
    //   canvas.drawPoints(
    //       PointMode.polygon,
    //       [
    //         points[0],
    //         points[i - 1],
    //         points[i],
    //         points[0],
    //       ],
    //       Paint()
    //         ..color = Colors.red.withOpacity(1.0)
    //         ..strokeWidth = 1);
    // }


    for (var pair in surfaceMSAA.entries) {
      var values = pair.value;
      var red = values[0].red + values[1].red + values[2].red + values[3].red;
      var green = values[0].green + values[1].green + values[2].green + values[3].green;
      var blue = values[0].blue + values[1].blue + values[2].blue + values[3].blue;
      // var opacity = values[0].opacity + values[1].opacity + values[2].opacity + values[3].opacity;
      var average = Color.fromRGBO(red ~/ 4, green ~/ 4, blue ~/ 4, 1.0);
      canvas.drawRect(Rect.fromLTWH(pair.key.dx, pair.key.dy, 10, 10), Paint()..color = average);
    }

        for (var i = 2; i < points.length; i++) {
      canvas.drawPoints(
          PointMode.polygon,
          [
            points[0],
            points[i - 1],
            points[i],
            points[0],
          ],
          Paint()
            ..color = Colors.red.withOpacity(1.0)
            ..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}


class OverlappingEdge extends CustomPainter {
  OverlappingEdge(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    var linePaint = Paint()..color = Colors.grey;
    for (var i = 0.0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
    for (var i = 0.0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    var t = Curves.decelerate.transform(value);

    var approxCenter = (size.height / 2).floorToDouble();
    var prevPixel = (approxCenter - (approxCenter % 40)) + 20;
    var topRect = Offset.zero & Size(size.width, prevPixel);
    var bottomRect = Offset(0, prevPixel) & Size(size.width, prevPixel);
    var rects = [topRect, bottomRect];

    var kScaledMSAAPAttern = [
      for (var pattern in kMSAAPattern)
        pattern.scale(20.0 / 8, 20.0 / 8)
    ];

    for (var rect in rects) {
      for (var i = 0.0; i < size.height; i += 40) {
        for (var j = 0.0; j < size.width; j += 40) {
          for (var z = 0; z < 4; z++) {
            var offset = Offset(j, i) + kScaledMSAAPAttern[z] + const Offset(20, 20);
            if (offset.dx > rect.left &&
                offset.dy > rect.top &&
                offset.dx < rect.right &&
                offset.dy < rect.bottom) {
              canvas.drawCircle(offset, 4, Paint()..color = Colors.red);
            } else {
             // canvas.drawCircle(offset, 4, Paint()..color = Colors.white);
            }
          }
        }
      }
      canvas.drawRect(rect, Paint()..style = PaintingStyle.stroke ..color = Colors.white);
      //break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
