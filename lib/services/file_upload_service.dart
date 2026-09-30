import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'api_config.dart';

class FileUploadService {
  
  /// Upload d'un certificat médical pour une demande de congé
  /// POST /api/medical-documents/upload/{leaveRequestId}
  static Future<bool> uploadMedicalDocument(int leaveRequestId, File file, {String? filename}) async {
    final token = await AuthService.getStoredToken();
    if (token == null) {
      throw ApiException(401, 'Non authentifié');
    }

    final endpoints = [
      '${ApiConfig.baseUrl}/medical-documents/upload/$leaveRequestId',
      '${ApiConfig.baseUrl}/leave-requests/$leaveRequestId/attachments',
      '${ApiConfig.baseUrl}/leave-requests/$leaveRequestId/documents',
    ];

    for (final url in endpoints) {
      try {
        print('📎 Upload vers $url');
        final request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'application/json';
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            filename: filename ?? file.path.split(RegExp(r'[\\/]')).last,
          ),
        );

        final streamed = await request.send();
        final body = await streamed.stream.bytesToString();
        print('📎 Upload Status: ${streamed.statusCode}');
        print('📎 Upload Response: $body');

        if (streamed.statusCode == 200 || streamed.statusCode == 201) {
          return true;
        }
      } catch (e) {
        print('📎 Échec $url: $e');
      }
    }

    return false;
  }

  /// Téléchargement d'un certificat médical
  /// GET /api/medical-documents/download/{id}
  static Future<List<int>?> downloadMedicalDocument(int documentId) async {
    final token = await AuthService.getStoredToken();
    if (token == null) {
      throw ApiException(401, 'Non authentifié');
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/medical-documents/download/$documentId'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw ApiException.fromResponse(response.statusCode, response.body);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Erreur de téléchargement du fichier: $e');
    }
  }

  /// Validation de fichier avant upload
  static String? validateFile(File file) {
    // Vérifier la taille (max 5MB)
    final fileSize = file.lengthSync();
    const maxSize = 5 * 1024 * 1024; // 5MB
    
    if (fileSize > maxSize) {
      return 'Le fichier est trop volumineux (max 5MB)';
    }

    // Vérifier l'extension
    final fileName = file.path.toLowerCase();
    final allowedExtensions = ['.pdf', '.jpg', '.jpeg', '.png', '.doc', '.docx'];
    
    final hasValidExtension = allowedExtensions.any((ext) => fileName.endsWith(ext));
    if (!hasValidExtension) {
      return 'Type de fichier non autorisé. Formats acceptés: PDF, JPG, PNG, DOC, DOCX';
    }

    return null; // Fichier valide
  }

  /// Obtient le type MIME du fichier
  static String getMimeType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  /// Formate la taille du fichier pour l'affichage
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}