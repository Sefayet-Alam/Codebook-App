import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SharingService {
  /// Share plain text snippet content
  Future<void> shareText(String title, String text) async {
    await Share.share(text, subject: title);
  }

  /// Share snippet as a file (e.g., .txt)
  Future<void> shareFile(String fileName, String content) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);

      await file.writeAsString(content);

      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Sharing snippet file: $fileName');
    } catch (e) {
      print('Error sharing file: $e');
      rethrow;
    }
  }
}
