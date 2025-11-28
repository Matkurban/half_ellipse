import 'package:flutter/material.dart';
import 'package:half_ellipse/half_ellipse.dart';

void main() {
  runApp(const HalfEllipseDemoApp());
}

class HalfEllipseDemoApp extends StatelessWidget {
  const HalfEllipseDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Half Ellipse Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HalfEllipseShowcase(),
    );
  }
}

class HalfEllipseShowcase extends StatefulWidget {
  const HalfEllipseShowcase({super.key});

  @override
  State<HalfEllipseShowcase> createState() => _HalfEllipseShowcaseState();
}

class _HalfEllipseShowcaseState extends State<HalfEllipseShowcase> {
  bool top = true;
  HalfEllipseShape shape = HalfEllipseShape.sag;
  double depth = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Half Ellipse Showcase')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Experiment with HalfEllipse by toggling the controls below.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                HalfEllipse(
                  height: 80,
                  width: double.infinity,
                  top: top,
                  depthFactor: depth,
                  shape: shape,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC371), Color(0xFFFF5F6D)],
                  ),
                  child: const Center(
                    child: Text(
                      'Gradient Banner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: HalfEllipse(
                        height: 60,
                        top: true,
                        shape: HalfEllipseShape.ellipse,
                        color: Colors.teal,
                        child: const Center(
                          child: Text(
                            'Ellipse top',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: HalfEllipse(
                        height: 60,
                        top: false,
                        shape: HalfEllipseShape.bezier,
                        color: Colors.indigo,
                        child: const Center(
                          child: Text(
                            'Bezier bottom',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 160,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade100,
                  ),
                  child: CustomPaint(
                    painter: HalfEllipsePainter(
                      color: Colors.orange,
                      gradient: null,
                      top: false,
                      shape: HalfEllipseShape.sag,
                      depthFactor: 1.2,
                    ),
                    child: const SizedBox.expand(
                      child: Center(child: Text('Painter example')),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  value: top,
                  title: const Text('Render top half'),
                  onChanged: (value) => setState(() => top = value),
                ),
                Slider(
                  value: depth,
                  min: 0.5,
                  max: 2,
                  label: depth.toStringAsFixed(1),
                  onChanged: (value) => setState(() => depth = value),
                ),
                Wrap(
                  spacing: 8,
                  children: HalfEllipseShape.values
                      .map(
                        (s) => ChoiceChip(
                          label: Text(s.name),
                          selected: s == shape,
                          onSelected: (_) => setState(() => shape = s),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
