import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class CloudinaryUpload {
  static const String cloudName = 'dfrzizwb1';
  static const String apiKey = '577481941532583';
  static const String apiSecret = 'HqNaPXYEd7QKJ_RfRmA_mskx5p4';

  /// ইমেজ বা PDF আপলোড করার কমন ফাংশন
  static Future<String?> uploadFile({
    required String base64Data,
    required String folder,
    bool isPdf = false,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // সিগনেচার জেনারেশন for
      final params = 'folder=$folder&timestamp=$timestamp$apiSecret';
      final signature = sha1.convert(utf8.encode(params)).toString();

      // ফাইলের ধরন অনুযায়ী ডাটা প্রিফিক্স সেট করা
      final String filePrefix =
          isPdf ? 'data:application/pdf;base64,' : 'data:image/png;base64,';

      // এপিআই ইউআরএল
      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');

      final response = await http.post(
        url,
        body: {
          'file': '$filePrefix$base64Data',
          'folder': folder,
          'timestamp': timestamp.toString(),
          'api_key': apiKey,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final secureUrl = data['secure_url'];
        return secureUrl;
      } else {
        // print('Cloudinary upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
