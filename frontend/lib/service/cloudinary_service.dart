import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // TODO: Replace these with your Cloudinary credentials
  static const String cloudName = 'dwwzo0hqu';
  static const String uploadPreset = 'unihack';

  static const String _uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// Upload an image file to Cloudinary and return the secure URL
  static Future<String> uploadImage(File file, {String? folder}) async {
    final uri = Uri.parse(_uploadUrl);

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    if (folder != null) {
      request.fields['folder'] = folder;
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      return jsonResponse['secure_url'] as String;
    } else {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Cloudinary upload failed: $responseBody');
    }
  }
}
