import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme_colors.dart';
import '../../../widgets/app_logo.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.employee; // Rôle par défaut

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    _departmentController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre $fieldName';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Veuillez saisir un email valide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir un mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      
      final user = User(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        employeeId: _employeeIdController.text.trim(),
        department: _departmentController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      final success = await authViewModel.register(user);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé avec succès!'),
            backgroundColor: AppConstants.primaryOrange,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Créer un compte',
          style: TextStyle(
            color: ThemeColors.textColor(context),
          ),
        ),
        backgroundColor: ThemeColors.appBarColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: ThemeColors.textColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Logo et titre
                const AppLogo(size: 60),
                
                const SizedBox(height: 16),
                
                Text(
                  AppConstants.joinXConges,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ThemeColors.textColor(context),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Champ nom
                CustomTextField(
                  label: AppConstants.lastName,
                  hintText: AppConstants.lastNamePlaceholder,
                  controller: _lastNameController,
                  validator: (value) => _validateRequired(value, 'nom'),
                ),
                
                const SizedBox(height: 20),
                
                // Champ prénom
                CustomTextField(
                  label: AppConstants.firstName,
                  hintText: AppConstants.firstNamePlaceholder,
                  controller: _firstNameController,
                  validator: (value) => _validateRequired(value, 'prénom'),
                ),
                
                const SizedBox(height: 20),
                
                // Champ email
                CustomTextField(
                  label: AppConstants.email,
                  hintText: AppConstants.emailPlaceholder,
                  controller: _emailController,
                  validator: _validateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                
                const SizedBox(height: 20),
                
                // Champ matricule
                CustomTextField(
                  label: AppConstants.employeeId,
                  hintText: AppConstants.employeeIdPlaceholder,
                  controller: _employeeIdController,
                  validator: (value) => _validateRequired(value, 'matricule'),
                ),
                
                const SizedBox(height: 20),
                
                // Champ département
                CustomTextField(
                  label: AppConstants.department,
                  hintText: AppConstants.departmentPlaceholder,
                  controller: _departmentController,
                  validator: (value) => _validateRequired(value, 'département'),
                ),
                
                const SizedBox(height: 20),
                
                // Sélecteur de rôle
                _buildRoleSelector(),
                
                const SizedBox(height: 20),
                
                // Champ mot de passe
                CustomTextField(
                  label: AppConstants.password,
                  controller: _passwordController,
                  validator: _validatePassword,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: AppConstants.greyColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Champ confirmation mot de passe
                CustomTextField(
                  label: AppConstants.confirmPassword,
                  controller: _confirmPasswordController,
                  validator: _validateConfirmPassword,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppConstants.greyColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Bouton de création de compte
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return Column(
                      children: [
                        if (authViewModel.errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authViewModel.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        CustomButton(
                          text: AppConstants.createMyAccount,
                          onPressed: _handleRegister,
                          isLoading: authViewModel.isLoading,
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Lien vers la connexion
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(AppConstants.alreadyHaveAccount),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RÔLE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ThemeColors.textColor(context),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: ThemeColors.inputFillColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeColors.borderColor(context),
            ),
          ),
          child: Column(
            children: [
              _buildRoleOption(
                UserRole.employee,
                'Employé',
                'Peut faire des demandes de congés et d\'absence',
                Icons.person,
              ),
              Container(
                height: 1,
                color: ThemeColors.borderColor(context),
              ),
              _buildRoleOption(
                UserRole.manager,
                'Responsable',
                'Peut approuver/refuser les demandes et faire ses propres demandes',
                Icons.admin_panel_settings,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleOption(
    UserRole role,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _selectedRole == role;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppConstants.primaryOrange.withOpacity(0.1)
                    : ThemeColors.backgroundColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? AppConstants.primaryOrange 
                    : ThemeColors.secondaryTextColor(context),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? AppConstants.primaryOrange 
                          : ThemeColors.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeColors.secondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? AppConstants.primaryOrange 
                      : ThemeColors.borderColor(context),
                  width: 2,
                ),
                color: isSelected 
                    ? AppConstants.primaryOrange 
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}