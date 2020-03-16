import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;
import 'package:images_to_pdf/images_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _pdfFile;
  String _status = "Not created";
  FileStat _pdfStat;
  bool _generating = false;

  Future<File> _assetFromBundle(String name) async {
    final tempDir = await getApplicationDocumentsDirectory();
    final output = File(path.join(tempDir.path, name));

    if (!await output.exists()) {
      final data = await rootBundle.load('assets/$name');
      final buffer = data.buffer;
      output.writeAsBytes(
          buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    }

    return output;
  }

  Future<void> _createPdf() async {
    try {
      this.setState(() => _generating = true);
      final tempDir = await getApplicationDocumentsDirectory();
      final output = File(path.join(tempDir.path, 'example.pdf'));

      this.setState(() => _status = 'Preparing images...');
      final images = [
        await _assetFromBundle('01.png'),
        await _assetFromBundle('02.jpg'),
        await _assetFromBundle('03.jpg'),
        await _assetFromBundle('04.jpg'),
        await _assetFromBundle('05.jpg'),
        await _assetFromBundle('06.jpg'),
        await _assetFromBundle('07.jpg'),
        await _assetFromBundle('08.jpg'),
        await _assetFromBundle('09.jpg'),
        await _assetFromBundle('10.jpg'),
        await _assetFromBundle('11.jpg'),
        await _assetFromBundle('12.jpg'),
        await _assetFromBundle('13.jpg'),
      ];

      this.setState(() => _status = 'Generating PDF');
      await ImagesToPdf.createPdf(
        pages: images
            .map(
              (file) => PdfPage(
                imageFile: file,
                size: Size(1920, 1080),
                compressionQuality: 0.5,
              ),
            )
            .toList(),
        output: output,
      );
      _pdfStat = await output.stat();
      this.setState(() {
        _pdfFile = output;
        _status = 'PDF Generated (${_pdfStat.size ~/ 1024}kb)';
      });
    } catch (e) {
      this.setState(() => _status = 'Failed to generate pdf: $e".');
    } finally {
      this.setState(() => _generating = false);
    }
  }

  Future<void> _openPdf() async {
    if (_pdfFile != null) {
      try {
        final bytes = await _pdfFile.readAsBytes();
        await Printing.sharePdf(
            bytes: bytes, filename: path.basename(_pdfFile.path));
      } catch (e) {
        _status = 'Failed to open pdf: $e".';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _generating;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(_status),
        ),
        body: Column(
          children: <Widget>[
            if (isLoading) CircularProgressIndicator(),
            if (!isLoading) ...[
              if (_pdfFile == null)
                RaisedButton(
                  child: Text("Generate PDF"),
                  onPressed: _createPdf,
                ),
              if (_pdfFile != null)
                RaisedButton(
                  child: Text("Open PDF"),
                  onPressed: _openPdf,
                ),
            ]
          ],
        ),
      ),
    );
  }
}
