class TextOptions {
  final String text;
  final String color;
  final int size;
  final Alignment alignment;
  final String fontPath;

  const TextOptions({
    this.text,
    this.color,
    this.size,
    this.fontPath,
    this.alignment = Alignment.center
  });

  Map<String, dynamic> toJson() {
    return {
      "text": text ?? "",
      "color": color ?? "",
      "size": size.toString(),
      "alignment" : alignment.toJson(),
      "fontPath" :fontPath ?? "",
    };
  }
}
class Alignment {

  const Alignment(this.x, this.y)
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
  static const Alignment topLeft = Alignment(-1.0, -1.0);

  /// The center point along the top edge.
  static const Alignment topCenter = Alignment(0.0, -1.0);

  /// The top right corner.
  static const Alignment topRight = Alignment(1.0, -1.0);

  /// The center point along the left edge.
  static const Alignment centerLeft = Alignment(-1.0, 0.0);

  /// The center point, both horizontally and vertically.
  static const Alignment center = Alignment(0.0, 0.0);

  /// The center point along the right edge.
  static const Alignment centerRight = Alignment(1.0, 0.0);

  /// The bottom left corner.
  static const Alignment bottomLeft = Alignment(-1.0, 1.0);

  /// The center point along the bottom edge.
  static const Alignment bottomCenter = Alignment(0.0, 1.0);

  /// The bottom right corner.
  static const Alignment bottomRight = Alignment(1.0, 1.0);
}


