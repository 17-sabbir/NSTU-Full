import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_io/io.dart' as uio;

/// Converts a Cloudinary URL into an attachment download URL.
///
/// Supports `/raw/upload/` and `/image/upload/` URLs.
String buildCloudinaryAttachmentUrl(String url) {
  if (url.isEmpty) return url;

  if (url.contains('/raw/upload/fl_attachment/') ||
      url.contains('/image/upload/fl_attachment/') ||
      url.contains('/upload/fl_attachment/')) {
    return url;
  }

  if (url.contains('/raw/upload/')) {
    return url.replaceFirst('/raw/upload/', '/raw/upload/fl_attachment/');
  }

  if (url.contains('/image/upload/')) {
    return url.replaceFirst('/image/upload/', '/image/upload/fl_attachment/');
  }

  if (url.contains('/upload/')) {
    return url.replaceFirst('/upload/', '/upload/fl_attachment/');
  }

  return url;
}

String _inferFileNameFromUrl(String url) {
  try {
    final uri = Uri.parse(url);
    if (uri.pathSegments.isNotEmpty) {
      final last = uri.pathSegments.last.trim();
      if (last.isNotEmpty && last.contains('.')) return last;
    }
  } catch (_) {
    // ignore
  }
  return 'download_${DateTime.now().millisecondsSinceEpoch}';
}

String _sanitizeFileName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return _inferFileNameFromUrl(name);
  final replaced = trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  return replaced.isEmpty
      ? 'download_${DateTime.now().millisecondsSinceEpoch}'
      : replaced;
}

/// Downloads a Cloudinary-hosted PDF/image from a link.
///
/// Behavior:
/// - Web: triggers browser download (via `<a download>`), returns the download URL.
/// - Android: saves into device Downloads folder (using MediaStore), returns saved content URI string.
/// - iOS/desktop: saves into app Documents folder, returns local file path.
Future<Object?> downloadPdfImageFromLink({
  required String url,
  String? fileName,
  BuildContext? context,
}) async {
  final dl = buildCloudinaryAttachmentUrl(url);
  final safeName = _sanitizeFileName(
    (fileName == null || fileName.trim().isEmpty)
        ? _inferFileNameFromUrl(dl)
        : fileName,
  );

  // Web: always use browser download, even on Android browsers.
  if (kIsWeb) {
    final a = html.AnchorElement(href: dl)
      ..style.display = 'none'
      ..target = '_blank'
      ..setAttribute('download', safeName);

    html.document.body?.append(a);
    a.click();
    a.remove();
    return dl;
  }

  // Non-web: download to temp file first.
  final tmpDir = await getTemporaryDirectory();
  final tmpPath = p.join(tmpDir.path, safeName);

  final dio = Dio(
    BaseOptions(
      followRedirects: true,
      validateStatus: (code) => code != null && code >= 200 && code < 400,
      receiveTimeout: const Duration(minutes: 2),
      connectTimeout: const Duration(seconds: 30),
    ),
  );

  await dio.download(dl, tmpPath);

  // Android: write to public Downloads using MediaStore.
  if (uio.Platform.isAndroid) {
    await MediaStore.ensureInitialized();
    MediaStore.appFolder = 'Dishari';

    final info = await MediaStore().saveFile(
      tempFilePath: tmpPath,
      dirType: DirType.download,
      dirName: DirName.download,
    );

    return info?.uri;
  }

  // iOS/desktop: best-effort save to app Documents (user can share/export).
  final docs = await getApplicationDocumentsDirectory();
  final outPath = p.join(docs.path, safeName);
  await uio.File(tmpPath).copy(outPath);
  return outPath;
}

/// Writes bytes into a temporary file and returns its file path.
///
/// Web is unsupported.
Future<String> writeTempFileBytes(
  Uint8List bytes, {
  required String fileName,
}) async {
  if (kIsWeb) {
    throw UnsupportedError('Temporary file writing is not supported on Web');
  }

  final dir = await getTemporaryDirectory();
  final safe = fileName.trim().isEmpty ? 'temp.bin' : fileName.trim();
  final path = p.join(dir.path, safe);
  final file = uio.File(path);
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
