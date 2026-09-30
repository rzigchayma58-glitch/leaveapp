import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../services/auth_service.dart';

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
  final _employeeIdController = TextEditingController();
  final _emailController = TextEditingController();

  String? _birthDate;
  String? _selectedPosition;
  String? _selectedDepartment;
  ProfileViewModel? _profileViewModel;

  // 📋 LISTES PRÉDÉFINIES POUR L'ENTREPRISE
  final List<String> _positions = [
    'Développeuse Mobile',
    'Développeur Web',
    'Développeur Full Stack',
    'Designer UI/UX',
    'Chef de Projet',
    'Product Owner',
    'Scrum Master',
    'Analyste Business',
    'Ingénieur DevOps',
    'Architecte Logiciel',
    'Consultant Technique',
    'Responsable Marketing',
    'Responsable Commercial',
    'Responsable RH',
    'Comptable',
    'Assistant(e) Administrative',
    'Stagiaire',
    'Autre',
  ];

  final List<String> _departments = [
    'IT',
    'Développement',
    'Design',
    'Gestion de Projet',
    'Marketing',
    'Commercial',
    'Ressources Humaines',
    'Finance & Comptabilité',
    'Direction',
    'Administration',
    'Support Client',
    'Qualité',
    'R&D',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateForm());
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  String? _ensureOption(List<String> items, String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    if (!items.contains(trimmed)) {
      items.insert(0, trimmed);
    }
    return trimmed;
  }

  Future<void> _hydrateForm() async {
    if (!mounted) return;
    final profileVm = Provider.of<ProfileViewModel>(context, listen: false);
    final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
    _profileViewModel = profileVm;
    profileVm.addListener(_onProfileChanged);
    await profileVm.initialize();
    if (!mounted) return;

    final local = profileVm.localProfile;
    _firstNameController.text = local?.firstName ?? user?.firstName ?? '';
    _lastNameController.text = local?.lastName ?? user?.lastName ?? '';
    _employeeIdController.text = user?.employeeId ?? '';
    _emailController.text = local?.email ?? user?.email ?? '';
    _phoneController.text = local?.phone ?? user?.phone ?? '';
    _addressController.text = local?.address ?? user?.address ?? '';
    _selectedDepartment =
        _ensureOption(_departments, local?.department ?? user?.department);
    _selectedPosition =
        _ensureOption(_positions, local?.position ?? user?.position);
    final birth = local?.birthDate ?? user?.birthDate;
    _birthDate = birth != null ? _formatDate(birth) : null;
    setState(() {});
  }

  void _onProfileChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _profileViewModel?.removeListener(_onProfileChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _employeeIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _getInitials(String firstName, String lastName) {
    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
  }

  // 🎨 WIDGET DROPDOWN MODERNE STYLE SAAS
  Widget _buildModernDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.inputFillColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ThemeColors.borderColor(context)),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon, color: AppConstants.greyColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: ThemeColors.secondaryTextColor(context)),
        ),
        style: TextStyle(
          color: ThemeColors.textColor(context),
          fontSize: 16,
        ),
        dropdownColor: ThemeColors.surfaceColor(context),
        icon: Icon(Icons.arrow_drop_down, color: AppConstants.primaryOrange),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                color: ThemeColors.textColor(context),
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showPhotoOptions() {
    if (_profileViewModel != null) {
      _profileViewModel!.showPhotoOptions(context);
    }
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
    DateTime initial = DateTime(1995, 3, 15);
    if (_birthDate != null) {
      final parts = _birthDate!.split('/');
      if (parts.length == 3) {
        initial = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDate = _formatDate(picked);
      });
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate() && _profileViewModel != null) {
      // Parsing de la date de naissance
      DateTime? birthDate;
      if (_birthDate != null) {
        final parts = _birthDate!.split('/');
        if (parts.length == 3) {
          birthDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      }

      // Sauvegarder avec le ProfileService (incluant poste et département sélectionnés)
      final success = await _profileViewModel!.saveAllChanges(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        birthDate: birthDate,
        email: _emailController.text.trim(),
        position: _selectedPosition,
        department: _selectedDepartment,
      );

      if (success) {
        final stored = await AuthService.getStoredUser();
        if (stored != null && mounted) {
          Provider.of<AuthViewModel>(context, listen: false)
              .updateUserProfile(stored);
        }
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: ThemeColors.surfaceColor(context),
            title: Text(
              'Profil mis à jour',
              style: TextStyle(color: ThemeColors.textColor(context)),
            ),
            content: Text(
              'Vos informations sont enregistrées et visibles sur votre profil.',
              style: TextStyle(color: ThemeColors.textColor(context)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: AppConstants.primaryOrange),
                ),
              ),
            ],
          ),
        );
      } else {
        _showSuccessMessage('Erreur lors de la sauvegarde');
      }
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
                        image: _profileViewModel?.localProfile?.hasProfilePhoto == true
                            ? DecorationImage(
                                image: FileImage(_profileViewModel!.localProfile!.profilePhotoFile!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profileViewModel?.localProfile?.hasProfilePhoto != true
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
                        _profileViewModel?.localProfile?.hasProfilePhoto != true 
                            ? AppConstants.addPhoto 
                            : 'Changer la photo',
                        style: const TextStyle(color: AppConstants.primaryOrange),
                      ),
                    ),
                    // Indicateur de modifications locales
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

              _buildModernDropdown(
                label: 'Poste',
                value: _selectedPosition,
                items: _positions,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPosition = newValue;
                  });
                },
                prefixIcon: Icons.work,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Matricule',
                controller: _employeeIdController,
                prefixIcon: const Icon(Icons.badge, color: AppConstants.greyColor),
                enabled: false,
              ),

              const SizedBox(height: 16),

              _buildModernDropdown(
                label: 'Département',
                value: _selectedDepartment,
                items: _departments,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDepartment = newValue;
                  });
                },
                prefixIcon: Icons.business,
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