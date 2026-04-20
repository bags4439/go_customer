import 'package:flutter/material.dart';

Widget buildLocalImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  Widget? errorWidget,
}) {
  return Image.network(
    path,
    fit: fit,
    errorBuilder: (_, __, ___) =>
        errorWidget ?? const Icon(Icons.broken_image),
  );
}
