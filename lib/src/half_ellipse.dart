import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'half_ellipse_shape.dart';

/// 半个椭圆容器
class HalfEllipse extends StatelessWidget {
  const HalfEllipse({
    super.key,
    this.height = 20,
    this.width,
    this.color = const Color(0xFFE04B42),
    this.gradient,
    this.top = true,
    this.child,
    this.padding,
    this.alignment,
    this.shape = HalfEllipseShape.sag,
    this.depthFactor = 1.0,
  });

  /// 半椭圆的可见高度；真实椭圆高度 = height * 2。
  final double height;

  /// 宽度（不提供时尽量扩展父可用空间）。
  final double? width;

  /// 纯色背景（当 [gradient] 为空时生效）。
  final Color color;

  /// 渐变背景（优先级高于 [color]）。
  final Gradient? gradient;

  /// true: 顶部组件，上平下弧；false: 底部组件，下平上弧。
  final bool top;

  /// 内部子组件。
  final Widget? child;

  /// 内边距。
  final EdgeInsets? padding;

  /// 子组件对齐方式。
  final AlignmentGeometry? alignment;

  /// 绘制形状：标准椭圆半弧 或 自定义贝塞尔软弧。
  final HalfEllipseShape shape;

  /// 深度系数：>1 更鼓/更深，0.5 更扁。默认 1。
  final double depthFactor;

  @override
  Widget build(BuildContext context) {
    final w = width;

    final content = Container(
      width: w,
      height: height,
      padding: padding,
      alignment: alignment,
      decoration: BoxDecoration(color: gradient == null ? color : null, gradient: gradient),
      child: child,
    );
    return ClipPath(
      clipper: _HalfEllipseClipper(top: top, shape: shape, depthFactor: depthFactor),
      child: content,
    );
  }
}

/// 统一创建半椭圆路径的函数，供 Clipper 和 Painter 共用。
Path _createHalfEllipsePath(Size size, bool top, HalfEllipseShape shape, double depthFactor) {
  final path = Path();
  final h = size.height.clamp(0.0, double.infinity);
  final w = size.width;

  if (shape == HalfEllipseShape.ellipse) {
    // 使用真正椭圆弧，平滑度最佳。
    final ry = h * depthFactor; // 纵向半径
    final rect = Rect.fromCenter(center: Offset(w / 2, top ? 0 : h), width: w, height: ry * 2);
    if (top) {
      // 上平下弧：显示椭圆下半部分
      path.moveTo(0, 0);
      path.lineTo(w, 0);
      path.addArc(rect, math.pi * 2, math.pi); // 从 0° 开始顺时针 180° (下半部)
    } else {
      // 下平上弧：显示椭圆上半部分
      path.moveTo(0, h);
      path.lineTo(w, h);
      path.addArc(rect, math.pi, math.pi); // 上半部
    }
    path.close();
  } else if (shape == HalfEllipseShape.bezier) {
    // Bezier 模式：可调整深度
    final depth = h * 0.4 * depthFactor;
    if (top) {
      path.moveTo(0, 0);
      path.lineTo(w, 0);
      path.cubicTo(w * 0.72, depth * 2, w * 0.28, depth * 2, 0, 0);
    } else {
      path.moveTo(0, h);
      path.lineTo(w, h);
      path.cubicTo(w * 0.72, h - depth * 2, w * 0.28, h - depth * 2, 0, h);
    }
    path.close();
  } else {
    // sag 形状：顶部直线 + 底部向下浅弧（适合截图那种下弯弧度）
    // height 作为弧度最大下沉值
    final sag = h * depthFactor; // 可用 depthFactor 放大/缩小
    if (top) {
      // 上平，下方向下弯
      path.moveTo(0, 0);
      path.lineTo(w, 0);
      // 使用对称三次贝塞尔形成平滑下弯
      path.cubicTo(w * 0.75, sag, w * 0.25, sag, 0, 0);
    } else {
      // 下平，上方向上弯（反转）
      path.moveTo(0, h);
      path.lineTo(w, h);
      path.cubicTo(w * 0.75, h - sag, w * 0.25, h - sag, 0, h);
    }
    path.close();
  }
  return path;
}

class _HalfEllipseClipper extends CustomClipper<Path> {
  _HalfEllipseClipper({required this.top, required this.shape, required this.depthFactor});
  final bool top;
  final HalfEllipseShape shape;
  final double depthFactor;

  @override
  Path getClip(Size size) {
    // 调用统一的路径创建函数
    return _createHalfEllipsePath(size, top, shape, depthFactor);
  }

  @override
  bool shouldReclip(covariant _HalfEllipseClipper oldClipper) =>
      oldClipper.top != top || oldClipper.shape != shape || oldClipper.depthFactor != depthFactor;
}

class HalfEllipsePainter extends CustomPainter {
  HalfEllipsePainter({
    required this.color,
    required this.top,
    required this.shape,
    required this.gradient,
    required this.depthFactor,
  });
  final Color color;
  final bool top;
  final Gradient? gradient;
  final HalfEllipseShape shape;
  final double depthFactor;

  @override
  void paint(Canvas canvas, Size size) {
    // 调用统一的路径创建函数
    final path = _createHalfEllipsePath(size, top, shape, depthFactor);

    final Paint paint;
    if (gradient != null) {
      // gradient 的 shader 应用于整个组件的矩形区域
      paint = Paint()
        ..shader = gradient!.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      paint = Paint()..color = color;
    }
    paint.isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HalfEllipsePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.top != top ||
      oldDelegate.gradient != gradient ||
      oldDelegate.shape != shape ||
      oldDelegate.depthFactor != depthFactor;
}
