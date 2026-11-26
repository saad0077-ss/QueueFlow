import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Marks child card shells so [ClinicRevenueEqualHeightRow] paints their frames.
class ClinicRevenueEmbeddedFrameScope extends InheritedWidget {
  const ClinicRevenueEmbeddedFrameScope({super.key, required super.child});

  static bool isEmbedded(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ClinicRevenueEmbeddedFrameScope>() !=
      null;

  @override
  bool updateShouldNotify(covariant ClinicRevenueEmbeddedFrameScope oldWidget) =>
      false;
}

/// Lays out two cards side-by-side at equal width and matches their painted
/// card frames to the taller child without constraining child Columns tightly.
class ClinicRevenueEqualHeightRow extends MultiChildRenderObjectWidget {
  final double gap;
  final BoxDecoration decoration;

  ClinicRevenueEqualHeightRow({
    super.key,
    required this.gap,
    required this.decoration,
    required Widget left,
    required Widget right,
  }) : super(
         children: [
           ClinicRevenueEmbeddedFrameScope(child: left),
           ClinicRevenueEmbeddedFrameScope(child: right),
         ],
       );

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderEqualHeightRow(gap: gap, decoration: decoration);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    if (renderObject is _RenderEqualHeightRow) {
      renderObject
        ..gap = gap
        ..decoration = decoration;
    }
  }
}

class _PairParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderEqualHeightRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _PairParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _PairParentData> {
  double _gap;
  BoxDecoration _decoration;
  BoxPainter? _painter;

  _RenderEqualHeightRow({required double gap, required BoxDecoration decoration})
    : _gap = gap,
      _decoration = decoration;

  set gap(double value) {
    if (_gap == value) return;
    _gap = value;
    markNeedsLayout();
  }

  set decoration(BoxDecoration value) {
    if (_decoration == value) return;
    _decoration = value;
    _painter?.dispose();
    _painter = null;
    markNeedsPaint();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _PairParentData) {
      child.parentData = _PairParentData();
    }
  }

  @override
  void performLayout() {
    final c1 = firstChild;
    final c2 = c1 != null ? childAfter(c1) : null;
    if (c1 == null || c2 == null) {
      size = constraints.smallest;
      return;
    }
    final colW = ((constraints.maxWidth - _gap) / 2).clamp(0.0, double.infinity);
    final childBox = BoxConstraints(minWidth: colW, maxWidth: colW);
    c1.layout(childBox, parentUsesSize: true);
    c2.layout(childBox, parentUsesSize: true);
    final maxH = math.max(c1.size.height, c2.size.height);
    (c1.parentData! as _PairParentData).offset = Offset.zero;
    (c2.parentData! as _PairParentData).offset = Offset(colW + _gap, 0);
    size = constraints.constrain(Size(constraints.maxWidth, maxH));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final c1 = firstChild;
    final c2 = c1 != null ? childAfter(c1) : null;
    if (c1 != null && c2 != null) {
      _painter ??= _decoration.createBoxPainter(markNeedsPaint);
      final colW = ((size.width - _gap) / 2).clamp(0.0, double.infinity);
      final frameSize = Size(colW, size.height);
      _painter!.paint(context.canvas, offset, ImageConfiguration(size: frameSize));
      _painter!.paint(
        context.canvas,
        offset + Offset(colW + _gap, 0),
        ImageConfiguration(size: frameSize),
      );
    }
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void dispose() {
    _painter?.dispose();
    super.dispose();
  }
}
