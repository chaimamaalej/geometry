import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';


void main() {
  runApp(MyApp());
}

class Point {
  Offset position;
  Point(this.position);
}

class DrawingArea {
  List<Point> points = [];
  Color color;
  DrawingArea(this.color);
}

class MyCustomPainter extends CustomPainter {
  List<DrawingArea> pointsToDraw = [];
  Color strokeColor;
  double strokeWidth;

  MyCustomPainter({required this.pointsToDraw, required this.strokeColor, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    for (var points in pointsToDraw) {
      var path = Path();
      if (points.points.isNotEmpty) {
        path.moveTo(points.points[0].position.dx, points.points[0].position.dy);
        for (var i = 1; i < points.points.length; i++) {
          path.lineTo(points.points[i].position.dx, points.points[i].position.dy);
        }
      }

      var paint = Paint()
        ..color = points.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<DrawingArea> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Finger Drawing'),
        ),
        body: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              RenderBox renderBox = context.findRenderObject() as RenderBox;
              points.add(DrawingArea(selectedColor)..points.add(Point(renderBox.globalToLocal(details.globalPosition))));
            });
          },
          onPanEnd: (details) {
            setState(() {
              points.add(DrawingArea(selectedColor));
            });
          },
          child: CustomPaint(
            painter: MyCustomPainter(pointsToDraw: points, strokeColor: selectedColor, strokeWidth: strokeWidth),
            child: Container(),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    points.clear();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.undo),
                onPressed: () {
                  setState(() {
                    if (points.isNotEmpty) {
                      points.removeLast();
                    }
                  });
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.color_lens),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Select a color'),
                  content: SingleChildScrollView(
                    child: BlockPicker(
                      pickerColor: selectedColor,
                      onColorChanged: (color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
