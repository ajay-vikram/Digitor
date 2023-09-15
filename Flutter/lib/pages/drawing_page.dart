import 'package:flutter/material.dart';
import 'package:digit_app/dl_model/classifier.dart';

class DrawPage extends StatefulWidget {
  const DrawPage({Key? key}) : super(key: key);

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  Classifier classifier = Classifier();
  List<Offset?> points = [];
  int digit = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(Icons.close),
        onPressed: () {
          points.clear();
          digit = -1;
          setState(() {

          });
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Digit Recognizer"),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40,),
            Text("Draw digit inside the box", style: TextStyle(fontSize: 20),),
            SizedBox(height: 10,),
            Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2.0)
              ),
              child: GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                  Offset localPosition = details.localPosition;
                  setState(() {
                    if(localPosition.dx > 0 && localPosition.dx <= 300 && localPosition.dy > 0 && localPosition.dy <= 300){
                      points.add(localPosition);
                    }
                  });
                },
                onPanEnd: (DragEndDetails details) async{
                  points.add(null);
                  digit = await classifier.classifyDrawing(points);
                  setState(() {
                  });
                },
                child: CustomPaint(
                  painter: Painter(points),
                ),
              ),
            ),
            SizedBox(height: 45,),
            Text("Current Prediction:", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            SizedBox(height: 20,),
            Text(digit == -1 ? "" : "$digit", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),)
          ],
        ),
      ),
    );
  }
}

class Painter extends CustomPainter {
  final List<Offset?> points;
  Painter(this.points);

  final Paint paintDetails = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4.0
    ..color = Colors.black;

  @override
  void paint(Canvas canvas, Size size){
    for(int i = 0; i < points.length - 1; i++){
      final Offset? point1 = points[i];
      final Offset? point2 = points[i + 1];

      // Check if both points are not null before drawing the line
      if (point1 != null && point2 != null) {
        canvas.drawLine(point1, point2, paintDetails);
      }
    }
  }

  @override
  bool shouldRepaint(Painter oldDelegate){
    return true;
  }
}