import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TouchScreen(),
    );
  }
}

class TouchScreen extends StatefulWidget {
  @override
  _TouchScreenState createState() => _TouchScreenState();
}

class _TouchScreenState extends State<TouchScreen>
    with SingleTickerProviderStateMixin {
  List<Circle> circles = [];
  Color? selectedColor;
  Offset? selectedPosition;
  AnimationController? _cont;
  Animation<double>? _ani;
  List<Color> colors = [...Colors.accents];

  @override
  void initState() {
    super.initState();
    _cont = AnimationController(
      vsync: this,
    );
    _ani = Tween<double>(begin: 120, end: 2000).animate(CurvedAnimation(
      parent: _cont!,
      curve: Curves.easeOut,
    ))
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _cont?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (details) {
              if (_cont!.isAnimating) {
                return;
              }

              if (_cont!.status == AnimationStatus.completed) {
                _cont?.duration = const Duration(milliseconds: 800);
                _cont?.reverse();
                setState(() {
                  circles.clear();
                });
                return;
              }

              setState(() {
                circles.add(
                  Circle(
                    position: details.localPosition,
                    color: pickColor(),
                  ),
                );

                selectedColor = null;
              });
            },
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  // Draw all circles at touched positions
                  for (Circle circle in circles)
                    Positioned(
                      left: circle.position.dx - 60,
                      top: circle.position.dy - 60,
                      child: CircleWidget(
                        color: circle.color,
                        dimen: 120,
                      ),
                    ),
                  if (selectedColor != null && selectedPosition != null)
                    Positioned(
                      left: selectedPosition!.dx - (_ani!.value / 2),
                      top: selectedPosition!.dy - (_ani!.value / 2),
                      child: CircleWidget(
                        color: selectedColor!,
                        dimen: _ani!.value,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_cont!.isAnimating) {
                  return;
                }

                if (_cont!.status == AnimationStatus.completed) {
                  _cont?.duration = const Duration(milliseconds: 800);
                  _cont?.reverse();
                  setState(() {
                    circles.clear();
                  });
                  return;
                }

                if (circles.isNotEmpty) {
                  final selectedCircle = pick(circles);
                  setState(() {
                    selectedColor = selectedCircle.color;
                    selectedPosition = selectedCircle.position;
                    colors = [...Colors.accents];
                  });

                  _cont?.duration = const Duration(seconds: 2);
                  _cont?.forward();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pick(li) {
    return ([...li]..shuffle()).first;
  }

  pickColor() {
    colors.shuffle();
    Color selectedColor = colors.first;
    setState(() {
      colors.remove(selectedColor);
    });
    return selectedColor;
  }
}

class Circle {
  final Offset position;
  final Color color;

  Circle({required this.position, required this.color});
}

class CircleWidget extends StatelessWidget {
  final Color color;
  final double dimen;

  const CircleWidget({required this.color, required this.dimen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dimen,
      height: dimen,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
