import 'package:flutter/cupertino.dart';

class TextOptions {
  final String text;
  final String color;
  final int size;
  final TextAlignment alignment;
  final String fontPath;
  final TextEdgeInsets margin;

  const TextOptions({
    this.text,
    this.color = '#F26F23',
    this.size = 50,
    this.fontPath,
    this.alignment = TextAlignment.centerRight,
    this.margin = const TextEdgeInsets.all(0.0)
  });

  Map<String, dynamic> toJson() {
    return {
      "text": text ?? "",
      "color": color ?? "",
      "size": size.toString(),
      "alignment" : alignment.toJson(),
      "fontPath" :fontPath ?? "",
      "margin": margin.toJson(),
    };
  }
}
class TextAlignment {

  const TextAlignment(this.x, this.y)
      : assert(x != null),
        assert(y != null);
  final double x;
  final double y;

  Map<String, dynamic> toJson() {
    return {
      "x": x ?? -1,
      "y": y ?? -1,
    };
  }

  /// The top left corner.
  static const TextAlignment topLeft = TextAlignment(-1.0, -1.0);

  /// The center point along the top edge.
  static const TextAlignment topCenter = TextAlignment(0.0, -1.0);

  /// The top right corner.
  static const TextAlignment topRight = TextAlignment(1.0, -1.0);

  /// The center point along the left edge.
  static const TextAlignment centerLeft = TextAlignment(-1.0, 0.0);

  /// The center point, both horizontally and vertically.
  static const TextAlignment center = TextAlignment(0.0, 0.0);

  /// The center point along the right edge.
  static const TextAlignment centerRight = TextAlignment(1.0, 0.0);

  /// The bottom left corner.
  static const TextAlignment bottomLeft = TextAlignment(-1.0, 1.0);

  /// The center point along the bottom edge.
  static const TextAlignment bottomCenter = TextAlignment(0.0, 1.0);

  /// The bottom right corner.
  static const TextAlignment bottomRight = TextAlignment(1.0, 1.0);
}

class TextEdgeInsets {

  final double vertical;
  final double horizontal;

  const TextEdgeInsets.all(double value)
      : vertical = value,
        horizontal = value;

  const TextEdgeInsets.symmetric({
    double vertical = 0.0,
    double horizontal = 0.0,
  })  : vertical = vertical,
        horizontal = horizontal;

  Map<String, dynamic> toJson() {
    return {
      "vertical": vertical ?? 0,
      "horizontal": horizontal ?? 0,
    };
  }
}


