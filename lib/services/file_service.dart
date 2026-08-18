import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/leave_request.dart';

class FileService {
  static final FileService _instance = FileService._internal();
  factory FileService() => _instance;
  FileService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  
  /// Prendre une photo avec l'appareil photo
  Future<AttachedFile?> takePhoto() async {
    try {
      // Vérifier si on est sur une plateforme mobile
      if (kIsWeb) {
        print('Fonctionnalité caméra non disponible sur le web');
        return null;
      }
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        final file = File(image.path);
        final size = await file.length();
        
        return AttachedFile(
          name: image.name,
          path: image.path,
          type: 'image',
          size: size,
          addedAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Erreur lors de la prise de photo: $e');
    }
    return null;
  }

  /// Choisir une image dans la galerie
  Future<AttachedFile?> pickImageFromGallery() async {
    try {
      // Vérifier si on est sur une plateforme mobile
      if (kIsWeb) {
        print('Fonctionnalité galerie non disponible sur le web');
        return null;
      }
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        final file = File(image.path);
        final size = await file.length();
        
        return AttachedFile(
          name: image.name,
          path: image.path,
          type: 'image',
          size: size,
          addedAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Erreur lors de la sélection d\'image: $e');
    }
    return null;
  }

  /// Sélectionner un document (PDF, etc.)
  Future<AttachedFile?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.single;
        final file = File(platformFile.path!);
        final size = await file.length();
        
        String type = 'document';
        if (['jpg', 'jpeg', 'png'].contains(platformFile.extension?.toLowerCase())) {
          type = 'image';
        } else if (platformFile.extension?.toLowerCase() == 'pdf') {
          type = 'pdf';
        }
        
        return AttachedFile(
          name: platformFile.name,
          path: platformFile.path!,
          type: type,
          size: size,
          addedAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Erreur lors de la sélection de document: $e');
    }
    return null;
  }

  /// Valider la taille du fichier
  bool isValidFileSize(int sizeBytes, int maxSizeBytes) {
    return sizeBytes <= maxSizeBytes;
  }

  /// Copier un fichier vers le dossier de l'application
  Future<String?> copyFileToAppDirectory(String sourcePath, String fileName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final attachmentsDir = Directory('${appDir.path}/attachments');
      
      if (!await attachmentsDir.exists()) {
        await attachmentsDir.create(recursive: true);
      }
      
      final sourceFile = File(sourcePath);
      final targetPath = '${attachmentsDir.path}/$fileName';
      final targetFile = await sourceFile.copy(targetPath);
      
      return targetFile.path;
    } catch (e) {
      print('Erreur lors de la copie du fichier: $e');
      return null;
    }
  }

  /// Supprimer un fichier
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      print('Erreur lors de la suppression du fichier: $e');
    }
    return false;
  }
}