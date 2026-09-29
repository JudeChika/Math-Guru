import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'cartesian_intro_logic.dart';
import 'cartesian_intro_models.dart';

class CartesianIntroScreen extends StatefulWidget {
  const CartesianIntroScreen({super.key});

  @override
  State<CartesianIntroScreen> createState() => _CartesianIntroScreenState();
}

class _CartesianIntroScreenState extends State<CartesianIntroScreen> {
  String _selectedFeature = 'plane';
  late CartesianIntroResult _result;
  final TransformationController _graphTransformController = TransformationController();

  final List<Map<String, dynamic>> _features = [
    {'key': 'plane', 'label': 'Cartesian Plane', 'icon': Icons.map},
    {'key': 'axes', 'label': 'The Axes', 'icon': Icons.add},
    {'key': 'origin', 'label': 'The Origin (O)', 'icon': Icons.adjust},
    {'key': 'x_axis', 'label': 'x-axis (Horizontal)', 'icon': Icons.swap_horiz},
    {'key': 'y_axis', 'label': 'y-axis (Vertical)', 'icon': Icons.swap_vert},
  ];

  @override
  void initState() {
    super.initState();
    _loadFeature(_selectedFeature);

    // Auto-center the interactive viewer on the origin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width - 32;
      double dx = (800 - screenWidth) / 2;
      double dy = (800 - 350) / 2;
      _graphTransformController.value = Matrix4.identity()..translate(-dx, -dy);
    });
  }

  @override
  void dispose() {
    _graphTransformController.dispose();
    super.dispose();
  }

  void _loadFeature(String featureKey) {
    setState(() {
      _selectedFeature = featureKey;
      _result = CartesianIntroLogic.explainFeature(featureKey);
    });
  }

  Widget _buildFeatureSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade200)),
          child: const Row(
            children: [
              Icon(Icons.touch_app, color: Colors.amber),
              SizedBox(width: 12),
              Expanded(child: Text("Tap a vocabulary word below to highlight it on the graph and see its textbook definition.", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _features.map((f) {
            bool isSelected = _selectedFeature == f['key'];
            return ActionChip(
              backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
              side: BorderSide(color: isSelected ? Colors.deepPurple : Colors.grey.shade400),
              avatar: Icon(f['icon'], color: isSelected ? Colors.white : Colors.deepPurple, size: 18),
              label: Text(f['label'], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
              onPressed: () => _loadFeature(f['key']),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVisualizer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_result.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 20)),
            const Text("💡 Drag to Pan, Pinch to Zoom", style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
        const SizedBox(height: 12),

        // Custom Virtual Graph Paper
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.deepPurple.shade200, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: InteractiveViewer(
              transformationController: _graphTransformController,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(200),
              minScale: 0.2,
              maxScale: 4.0,
              child: Container(
                width: 800,
                height: 800,
                color: Colors.white,
                child: CustomPaint(
                  painter: CartesianIntroPainter(featureKey: _selectedFeature),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExplanations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Text("Definition & Properties:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 18)),
        const SizedBox(height: 12),
        ..._result.steps.asMap().entries.map((e) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              foregroundColor: Colors.deepPurple,
              child: const Icon(Icons.menu_book, size: 20),
            ),
            title: Text(e.value.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(e.value.description, style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
                if (e.value.mathLaTeX != null) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Math.tex(e.value.mathLaTeX!, textStyle: const TextStyle(fontSize: 18, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                  )
                ]
              ],
            ),
          ),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Introduction to the Cartesian Plane')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFeatureSelector(),
            _buildVisualizer(),
            _buildExplanations(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class CartesianIntroPainter extends CustomPainter {
  final String featureKey;

  CartesianIntroPainter({required this.featureKey});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = Colors.grey.shade300..strokeWidth = 1;
    final axisPaint = Paint()..color = Colors.black87..strokeWidth = 2;

    // Highlight Paints
    final highlightBlue = Paint()..color = Colors.blue.withOpacity(0.6)..strokeWidth = 6..strokeCap = StrokeCap.round;
    final highlightGreen = Paint()..color = Colors.green.withOpacity(0.6)..strokeWidth = 6..strokeCap = StrokeCap.round;
    final planeFill = Paint()..color = Colors.yellow.withOpacity(0.1)..style = PaintingStyle.fill;

    double maxBound = 10;
    double cx = size.width / 2;
    double cy = size.height / 2;
    double unitSize = (size.width / 2) / maxBound;

    // Optional: Highlight the entire plane
    if (featureKey == 'plane') {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), planeFill);
      _drawWatermark(canvas, "Descartes' Plane", cx, cy + 100, 40, Colors.black12);
    }

    for (int i = -maxBound.toInt(); i <= maxBound.toInt(); i++) {
      double px = cx + (i * unitSize);
      double py = cy - (i * unitSize);

      canvas.drawLine(Offset(px, 0), Offset(px, size.height), gridPaint);
      canvas.drawLine(Offset(0, py), Offset(size.width, py), gridPaint);

      if (i != 0 && i % 2 == 0) {
        _drawText(canvas, i.toString(), px, cy + 12);
        _drawText(canvas, i.toString(), cx - 12, py);
      }
    }

    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), axisPaint); // Y
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), axisPaint); // X

    if (featureKey == 'x_axis' || featureKey == 'axes') {
      canvas.drawLine(Offset(0, cy), Offset(size.width, cy), highlightBlue);
      _drawBoldBadge(canvas, "x-axis (negative)", 80, cy - 20, Colors.blue.shade800);
      _drawBoldBadge(canvas, "x-axis (positive)", size.width - 80, cy - 20, Colors.blue.shade800);
    }

    if (featureKey == 'y_axis' || featureKey == 'axes') {
      canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), highlightGreen);
      _drawBoldBadge(canvas, "y-axis (positive)", cx + 60, 40, Colors.green.shade800);
      _drawBoldBadge(canvas, "y-axis (negative)", cx + 60, size.height - 40, Colors.green.shade800);
    }

    if (featureKey == 'origin') {
      canvas.drawCircle(Offset(cx, cy), 12, Paint()..color = Colors.red);
      canvas.drawCircle(Offset(cx, cy), 16, Paint()..color = Colors.red.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth=4);
      _drawBoldBadge(canvas, "Origin (0,0)", cx + 50, cy - 30, Colors.red);
    } else {
      _drawText(canvas, 'O', cx - 12, cy + 12, isBold: true, fontSize: 16);
    }

    // Always draw standard end-of-axis labels unless overridden by badges
    if (featureKey != 'x_axis' && featureKey != 'axes') _drawText(canvas, 'x', size.width - 15, cy - 15, isBold: true, fontSize: 16);
    if (featureKey != 'y_axis' && featureKey != 'axes') _drawText(canvas, 'y', cx + 15, 15, isBold: true, fontSize: 16);
  }

  void _drawText(Canvas canvas, String text, double x, double y, {bool isBold = false, Color color = Colors.black87, double fontSize = 12}) {
    TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        textDirection: TextDirection.ltr
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width/2, y - tp.height/2));
  }

  void _drawBoldBadge(Canvas canvas, String text, double x, double y, Color color) {
    TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr
    );
    tp.layout();

    Rect bgRect = Rect.fromCenter(center: Offset(x, y), width: tp.width + 16, height: tp.height + 8);
    canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(8)), Paint()..color = color);

    tp.paint(canvas, Offset(x - tp.width/2, y - tp.height/2));
  }

  void _drawWatermark(Canvas canvas, String text, double x, double y, double fontSize, Color color) {
    TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
        textDirection: TextDirection.ltr
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width/2, y - tp.height/2));
  }

  @override bool shouldRepaint(covariant CartesianIntroPainter oldDelegate) {
    return oldDelegate.featureKey != featureKey;
  }
}