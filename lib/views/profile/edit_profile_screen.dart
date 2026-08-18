import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/file_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _positionController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _emailController = TextEditingController();
  final FileService _fileService = FileService();

  String? _birthDate;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _employeeIdController.text = user.employeeId;
      _departmentController.text = user.department;
      _emailController.text = user.email;
      // Valeurs par défaut pour la démo
      _phoneController.text = '+216 12 345 678';
      _addressController.text = 'Tunis, Tunisie';
      _positionController.text = 'Développeuse Mobile';
      _birthDate = '15/03/1995';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _positionController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _getInitials(String firstName, String lastName) {
    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ThemeColors.surfaceColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Changer la photo de profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choisissez une option :',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.secondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            _buildPhotoOption(Icons.camera_alt, 'Prendre une photo', AppConstants.primaryOrange),
            _buildPhotoOption(Icons.photo_library, 'Choisir dans la galerie', AppConstants.primaryOrange),
            _buildPhotoOption(Icons.delete, 'Supprimer la photo', AppConstants.rejectedColor),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Annuler',
                  style: TextStyle(color: AppConstants.primaryOrange),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption(IconData icon, String title, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      onTap: () {
        Navigator.pop(context);
        if (title == 'Prendre une photo') {
          _takePhoto();
        } else if (title == 'Choisir dans la galerie') {
          _pickImageFromGallery();
        } else if (title == 'Supprimer la photo') {
          _removePhoto();
        }
      },
    );
  }

  Future<void> _takePhoto() async {
    final attachment = await _fileService.takePhoto();
    if (attachment != null) {
      setState(() {
        _profileImagePath = attachment.path;
      });
      _showSuccessMessage('Photo de profil mise à jour !');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final attachment = await _fileService.pickImageFromGallery();
    if (attachment != null) {
      setState(() {
        _profileImagePath = attachment.path;
      });
      _showSuccessMessage('Photo de profil mise à jour !');
    }
  }

  void _removePhoto() {
    setState(() {
      _profileImagePath = null;
    });
    _showSuccessMessage('Photo de profil supprimée !');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.approvedColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 3, 15),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Simulation de la sauvegarde avec photo
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: ThemeColors.surfaceColor(context),
          title: Text(
            'Modifications enregistrées',
            style: TextStyle(color: ThemeColors.textColor(context)),
          ),
          content: Text(
            _profileImagePath != null 
                ? 'Vos informations de profil et votre photo ont été mises à jour avec succès.'
                : 'Vos informations de profil ont été mises à jour avec succès.',
            style: TextStyle(color: ThemeColors.textColor(context)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: AppConstants.primaryOrange),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColors.surfaceColor(context),
          title: Text(
            'Supprimer le compte',
            style: TextStyle(color: ThemeColors.textColor(context)),
          ),
          content: Text(
            'Cette action est irréversible. Êtes-vous sûr de vouloir supprimer votre compte ?',
            style: TextStyle(color: ThemeColors.textColor(context)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(color: ThemeColors.textColor(context)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessMessage('Fonctionnalité de suppression de compte disponible dans une version ultérieure');
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: AppConstants.rejectedColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Modifier le profil',
          style: TextStyle(
            color: ThemeColors.textColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ThemeColors.appBarColor(context),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              AppConstants.save,
              style: TextStyle(
                color: AppConstants.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryOrange,
                        borderRadius: BorderRadius.circular(12),
                        image: _profileImagePath != null
                            ? DecorationImage(
                                image: FileImage(File(_profileImagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profileImagePath == null
                          ? Center(
                              child: Text(
                                _getInitials(_firstNameController.text, _lastNameController.text),
                                style: const TextStyle(
                                  color: AppConstants.whiteColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _showPhotoOptions,
                      child: Text(
                        _profileImagePath == null ? AppConstants.addPhoto : 'Changer la photo',
                        style: const TextStyle(color: AppConstants.primaryOrange),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Informations personnelles
              Text(
                AppConstants.personalInfo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textColor(context),
                ),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Prénom',
                controller: _firstNameController,
                prefixIcon: const Icon(Icons.person, color: AppConstants.greyColor),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Nom de famille',
                controller: _lastNameController,
                prefixIcon: const Icon(Icons.person, color: AppConstants.greyColor),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: _selectBirthDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: ThemeColors.inputFillColor(context),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ThemeColors.borderColor(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: ThemeColors.iconColor(context)),
                      const SizedBox(width: 16),
                      Text(
                        _birthDate ?? 'Date de naissance',
                        style: TextStyle(
                          color: _birthDate != null ? ThemeColors.textColor(context) : ThemeColors.secondaryTextColor(context),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Téléphone',
                controller: _phoneController,
                prefixIcon: const Icon(Icons.phone, color: AppConstants.greyColor),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Adresse',
                controller: _addressController,
                prefixIcon: const Icon(Icons.location_on, color: AppConstants.greyColor),
              ),

              const SizedBox(height: 32),

              // Informations professionnelles
              Text(
                AppConstants.professionalInfo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.textColor(context),
                ),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Poste',
                controller: _positionController,
                prefixIcon: const Icon(Icons.work, color: AppConstants.greyColor),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Matricule',
                controller: _employeeIdController,
                prefixIcon: const Icon(Icons.badge, color: AppConstants.greyColor),
                enabled: false,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Département',
                controller: _departmentController,
                prefixIcon: const Icon(Icons.business, color: AppConstants.greyColor),
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Email professionnel',
                controller: _emailController,
                prefixIcon: const Icon(Icons.email, color: AppConstants.greyColor),
                keyboardType: TextInputType.emailAddress,
                enabled: false,
              ),

              const SizedBox(height: 32),

              // Bouton de suppression du compte
              CustomButton(
                text: AppConstants.deleteAccount,
                onPressed: _showDeleteAccountDialog,
                backgroundColor: AppConstants.rejectedColor.withOpacity(0.1),
                textColor: AppConstants.rejectedColor,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}