import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ImagesToPdf {
  static const MethodChannel _channel = const MethodChannel('images_to_pdf');

  /// Creates a PDF from the given [pages] and saves it to [output]. Each image will become
  /// a dedicated page in the resulting document.
  static Future<void> createPdf({
    @required List<PdfPage> pages,
    @required File output,
  }) async {
    await _channel.invokeMethod('createPdf', <dynamic>[
      pages.map((page) => page.toMap()).toList(),
      output.path,
    ]);
  }
}

class PdfPage {
  final File imageFile;
  final double compressionQuality;
  final Size size;

  PdfPage({
    @required this.imageFile,
    this.compressionQuality,
    this.size,
  }) : assert(imageFile != null);

  Map<String, dynamic> toMap() => {
        'path': imageFile.path,
        'compressionQuality': compressionQuality,
        'size': size == null ? null : [size.width, size.height],
      };
}
