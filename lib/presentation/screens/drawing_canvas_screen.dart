import 'package:flutter/material.dart';
import '../../data/models/note_model.dart';

/// KiteTech "Handwriting and drawing" Interactive Canvas Screen
class DrawingCanvasScreen extends StatefulWidget {
  final List<DrawingStroke> initialStrokes;

  const DrawingCanvasScreen({super.key, this.initialStrokes = const []});

  @override
  State<DrawingCanvasScreen> createState() => _DrawingCanvasScreenState();
}

class _DrawingCanvasScreenState extends State<DrawingCanvasScreen> {
  late List<DrawingStroke> _strokes;
  final List<DrawingStroke> _redoStack = [];
  List<Offset> _currentPoints = [];
  Color _selectedColor = const Color(0xFF0048FF);
  double _strokeWidth = 5.0;
  bool _isEraser = false;

  static const List<Color> _quickBrushColors = [
    Color(0xFF000000),
    Color(0xFF0048FF),
    Color(0xFF22C55E),
    Color(0xFFEF4444),
    Color(0xFFEAB308),
    Color(0xFFF97316),
    Color(0xFF8B5CF6),
    Color(0xFF6B3410),
  ];

  @override
  void initState() {
    super.initState();
    _strokes = List<DrawingStroke>.from(widget.initialStrokes);
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _redoStack.add(_strokes.removeLast());
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    setState(() {
      _strokes.add(_redoStack.removeLast());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF55B535),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'حفظ الرسمة',
          onPressed: () => Navigator.pop(context, _strokes),
        ),
        title: const Text('Handwriting & Drawing — رسم حر'),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: _redo),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() {
              _strokes.clear();
              _redoStack.clear();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _currentPoints = [details.localPosition];
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _currentPoints.add(details.localPosition);
                });
              },
              onPanEnd: (_) {
                setState(() {
                  _strokes.add(
                    DrawingStroke(
                      points: List<Offset>.from(_currentPoints),
                      colorValue: _selectedColor.value,
                      strokeWidth: _strokeWidth,
                      isEraser: _isEraser,
                    ),
                  );
                  _currentPoints = [];
                  _redoStack.clear();
                });
              },
              child: CustomPaint(
                painter: _SketchCanvasPainter(
                  strokes: _strokes,
                  currentPoints: _currentPoints,
                  currentColor: _selectedColor,
                  currentWidth: _strokeWidth,
                  isEraser: _isEraser,
                ),
                size: Size.infinite,
              ),
            ),
          ),

          // KiteTech Bottom Drawing Toolbar (#B8F597)
          Container(
            color: const Color(0xFFB8F597),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('سُمك القلم:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: _strokeWidth,
                        min: 2,
                        max: 28,
                        activeColor: const Color(0xFF15803D),
                        onChanged: (v) => setState(() => _strokeWidth = v),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.CleaningServices, color: _isEraser ? Colors.red : Colors.black87),
                      tooltip: 'الممحاة (Eraser)',
                      onPressed: () => setState(() => _isEraser = !_isEraser),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: !_isEraser ? Colors.teal.shade900 : Colors.black54),
                      tooltip: 'القلم (Pen)',
                      onPressed: () => setState(() => _isEraser = false),
                    ),
                  ],
                ),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _quickBrushColors.map((c) {
                      final selected = !_isEraser && _selectedColor.value == c.value;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedColor = c;
                          _isEraser = false;
                        }),
                        child: Container(
                          width: 30,
                          height: 30,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? Colors.white : Colors.black26,
                              width: selected ? 3 : 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SketchCanvasPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final List<Offset> currentPoints;
  final Color currentColor;
  final double currentWidth;
  final bool isEraser;

  _SketchCanvasPainter({
    required this.strokes,
    required this.currentPoints,
    required this.currentColor,
    required this.currentWidth,
    required this.isEraser,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Colors.white,
    );

    for (final s in strokes) {
      _drawStroke(
        canvas,
        s.points,
        s.isEraser ? Colors.white : Color(s.colorValue),
        s.strokeWidth,
      );
    }

    if (currentPoints.isNotEmpty) {
      _drawStroke(
        canvas,
        currentPoints,
        isEraser ? Colors.white : currentColor,
        currentWidth,
      );
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> pts, Color color, double width) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (pts.length == 1) {
      canvas.drawCircle(pts.first, width / 2, paint..style = PaintingStyle.fill);
      return;
    }
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SketchCanvasPainter oldDelegate) => true;
}
