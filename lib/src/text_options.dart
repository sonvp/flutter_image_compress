class TextOptions {
  final String? text;
  final String? color;
  final int ? size;

  const TextOptions({
    this.text,
    this.color,
    this.size,
  });

  Map<String, String> toJson() {
    return {
      "text": text ?? "",
      "color": color ?? "",
      "size": size.toString(),
    };
  }
}
