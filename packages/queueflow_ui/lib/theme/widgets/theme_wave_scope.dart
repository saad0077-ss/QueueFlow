import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Wraps the app (use inside `MaterialApp.builder`) and plays a water-like
/// wave reveal when the theme changes.
///
/// How it works: the current screen is captured as an image, the theme is
/// switched underneath, and the old image is drawn on top with a wavy circular
/// hole growing from the tap point, so the new theme "flows" in.
class ThemeWaveScope extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ThemeWaveScope({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 900),
  });

  static ThemeWaveScopeState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<ThemeWaveScopeState>();

  /// Runs [applyTheme] with a wave reveal starting at [origin]
  /// (global coordinates). Falls back to a plain call if no scope exists.
  static Future<void> run(
    BuildContext context, {
    required Offset origin,
    required VoidCallback applyTheme,
  }) async {
    final scope = maybeOf(context);
    if (scope == null) {
      applyTheme();
      return;
    }
    await scope.start(origin: origin, applyTheme: applyTheme);
  }

  @override
  State<ThemeWaveScope> createState() => ThemeWaveScopeState();
}

class ThemeWaveScopeState extends State<ThemeWaveScope>
    with SingleTickerProviderStateMixin {
  final GlobalKey _boundaryKey = GlobalKey();
  late final AnimationController _controller;
  ui.Image? _snapshot;
  Offset _origin = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _clearSnapshot();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _snapshot?.dispose();
    super.dispose();
  }

  void _clearSnapshot() {
    final old = _snapshot;
    if (!mounted) {
      old?.dispose();
      return;
    }
    setState(() => _snapshot = null);
    old?.dispose();
  }

  Future<void> start({
    required Offset origin,
    required VoidCallback applyTheme,
  }) async {
    if (_controller.isAnimating) return;

    ui.Image? image;
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary != null) {
        image = await boundary.toImage(
          pixelRatio: MediaQuery.devicePixelRatioOf(context),
        );
      }
    } catch (e) {
      debugPrint('ThemeWaveScope: snapshot failed, switching instantly: $e');
    }

    if (!mounted) {
      image?.dispose();
      return;
    }
    if (image == null) {
      applyTheme();
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    final local = box != null ? box.globalToLocal(origin) : origin;

    setState(() {
      _snapshot = image;
      _origin = local;
    });
    applyTheme();
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        RepaintBoundary(key: _boundaryKey, child: widget.child),
        if (_snapshot != null)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _WaveRevealPainter(
                    image: _snapshot!,
                    origin: _origin,
                    progress: Curves.easeInOut.transform(_controller.value),
                    phase: _controller.value * math.pi * 6,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _WaveRevealPainter extends CustomPainter {
  final ui.Image image;
  final Offset origin;
  final double progress;
  final double phase;

  _WaveRevealPainter({
    required this.image,
    required this.origin,
    required this.progress,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Farthest corner so the wave fully clears the screen.
    final maxRadius = [
      (origin - rect.topLeft).distance,
      (origin - rect.topRight).distance,
      (origin - rect.bottomLeft).distance,
      (origin - rect.bottomRight).distance,
    ].reduce(math.max);

    // Extra headroom so the wavy edge is fully off-screen at progress == 1.
    final baseRadius = progress * maxRadius * 1.15;
    // Wave is strongest mid-animation, calm at start and end.
    final amplitude = math.sin(progress * math.pi) * (maxRadius * 0.06);

    const segments = 160;
    const lobes = 7;
    final hole = Path();
    for (var i = 0; i <= segments; i++) {
      final angle = (i / segments) * math.pi * 2;
      final r = baseRadius + amplitude * math.sin(angle * lobes + phase);
      final p = origin + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        hole.moveTo(p.dx, p.dy);
      } else {
        hole.lineTo(p.dx, p.dy);
      }
    }
    hole.close();

    // Old screen minus the growing wavy hole.
    final remaining =
        Path.combine(PathOperation.difference, Path()..addRect(rect), hole);

    canvas.save();
    canvas.clipPath(remaining);
    paintImage(
      canvas: canvas,
      rect: rect,
      image: image,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.low,
    );
    canvas.restore();

    // Soft light "foam" line along the water edge.
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withValues(alpha: 0.25 * math.sin(progress * math.pi));
    canvas.save();
    canvas.clipRect(rect);
    canvas.drawPath(hole, edge);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WaveRevealPainter old) =>
      old.progress != progress ||
      old.phase != phase ||
      old.image != image ||
      old.origin != origin;
}
