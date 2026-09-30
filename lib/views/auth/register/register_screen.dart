import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme_colors.dart';
import '../../../core/animations.dart';
import '../../../core/saas_design.dart';
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
  final _managerEmailController = TextEditingController();
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
    _managerEmailController.dispose();
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
      
      // Username basé sur l'email
      final username = _emailController.text.trim().split('@')[0];
      
      // Mapper le rôle sélectionné vers le format backend
      String roleString;
      switch (_selectedRole) {
        case UserRole.manager:
          roleString = 'Responsable';
          break;
        case UserRole.employee:
        default:
          roleString = 'Employé';
          break;
      }
      
      print('🚀 Création compte avec tous les champs...');
      print('📧 Email: ${_emailController.text.trim()}');
      print('👤 Nom: ${_lastNameController.text.trim()} ${_firstNameController.text.trim()}');
      print('🏢 Matricule: ${_employeeIdController.text.trim()}');
      print('🏬 Département: ${_departmentController.text.trim()}');
      print('🎭 Rôle: $roleString');
      
      final success = await authViewModel.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        username: username,
        password: _passwordController.text,
        role: roleString,
        matricule: _employeeIdController.text.trim().isNotEmpty 
            ? _employeeIdController.text.trim() 
            : null,
        department: _departmentController.text.trim().isNotEmpty 
            ? _departmentController.text.trim() 
            : null,
        managerEmail: _selectedRole == UserRole.employee
            ? _managerEmailController.text.trim()
            : null,
      );

      if (!mounted) return;

      if (success) {
        final roleLabel = _selectedRole == UserRole.manager
            ? 'Compte responsable créé. L’espace manager est disponible.'
            : 'Compte employé créé. Vous pouvez faire des demandes de congés.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    roleLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: SaaSDesign.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SaaSDesign.radiusMedium),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Le Consumer racine bascule vers MainScreen si déjà connecté.
        if (!authViewModel.isLoggedIn) {
          Navigator.pop(context);
        }
      } else {
        // L'erreur sera affichée par le Consumer<AuthViewModel>
        print('❌ Échec de la création de compte');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header moderne avec dégradé
          SaaSHeader(
            title: 'Créer un compte',
            subtitle: 'Rejoignez XCongés dès maintenant',
            showBackButton: true,
          ),
          
          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SaaSDesign.spacing24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: SaaSDesign.spacing20),
                    
                    // Logo avec animation
                    SlideAndFadeAnimation(
                      index: 0,
                      child: Column(
                        children: [
                          const AppLogo(size: 60),
                          const SizedBox(height: SaaSDesign.spacing16),
                          const Text(
                            'Bienvenue !',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: SaaSDesign.spacing8),
                          Text(
                            'Créez votre compte pour commencer',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: SaaSDesign.spacing32),
                    
                    // Formulaire dans une carte SaaS
                    SlideAndFadeAnimation(
                      index: 1,
                      child: SaaSCard(
                        padding: const EdgeInsets.all(SaaSDesign.spacing24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Informations personnelles
                            const Text(
                              'INFORMATIONS PERSONNELLES',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: SaaSDesign.primaryOrange,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: SaaSDesign.spacing20),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSaaSTextField(
                                    label: 'Nom',
                                    hintText: 'Votre nom',
                                    controller: _lastNameController,
                                    validator: (value) => _validateRequired(value, 'nom'),
                                    prefixIcon: Icons.person_outline,
                                  ),
                                ),
                                const SizedBox(width: SaaSDesign.spacing16),
                                Expanded(
                                  child: _buildSaaSTextField(
                                    label: 'Prénom',
                                    hintText: 'Votre prénom',
                                    controller: _firstNameController,
                                    validator: (value) => _validateRequired(value, 'prénom'),
                                    prefixIcon: Icons.badge_outlined,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: SaaSDesign.spacing20),
                            
                            _buildSaaSTextField(
                              label: 'Email',
                              hintText: 'votre.email@exemple.com',
                              controller: _emailController,
                              validator: _validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                            ),
                            
                            const SizedBox(height: SaaSDesign.spacing32),
                            
                            // Informations professionnelles
                            const Text(
                              'INFORMATIONS PROFESSIONNELLES',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: SaaSDesign.primaryOrange,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: SaaSDesign.spacing20),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSaaSTextField(
                                    label: 'Matricule',
                                    hintText: 'EMP001',
                                    controller: _employeeIdController,
                                    validator: (value) => _validateRequired(value, 'matricule'),
                                    prefixIcon: Icons.badge,
                                  ),
                                ),
                                const SizedBox(width: SaaSDesign.spacing16),
                                Expanded(
                                  child: _buildSaaSTextField(
                                    label: 'Département',
                                    hintText: 'IT, RH, Finance...',
                                    controller: _departmentController,
                                    validator: (value) => _validateRequired(value, 'département'),
                                    prefixIcon: Icons.business_outlined,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: SaaSDesign.spacing24),
                            
                            // Sélecteur de rôle moderne
                            _buildSaaSRoleSelector(),

                            if (_selectedRole == UserRole.employee) ...[
                              const SizedBox(height: SaaSDesign.spacing20),
                              _buildSaaSTextField(
                                label: 'Email du responsable (optionnel)',
                                hintText: 'responsable@xtensus.com',
                                controller: _managerEmailController,
                                validator: (_) => null,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.supervisor_account_outlined,
                              ),
                            ],
                            
                            const SizedBox(height: SaaSDesign.spacing32),
                            
                            // Informations de sécurité
                            const Text(
                              'SÉCURITÉ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: SaaSDesign.primaryOrange,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: SaaSDesign.spacing20),
                            
                            _buildSaaSTextField(
                              label: 'Mot de passe',
                              hintText: '••••••••',
                              controller: _passwordController,
                              validator: _validatePassword,
                              obscureText: _obscurePassword,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: SaaSDesign.primaryOrange,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            
                            const SizedBox(height: SaaSDesign.spacing20),
                            
                            _buildSaaSTextField(
                              label: 'Confirmer le mot de passe',
                              hintText: '••••••••',
                              controller: _confirmPasswordController,
                              validator: _validateConfirmPassword,
                              obscureText: _obscureConfirmPassword,
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: SaaSDesign.primaryOrange,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: SaaSDesign.spacing32),
                    
                    // Bouton de création de compte
                    SlideAndFadeAnimation(
                      index: 2,
                      child: Consumer<AuthViewModel>(
                        builder: (context, authViewModel, child) {
                          return Column(
                            children: [
                              if (authViewModel.errorMessage != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: SaaSDesign.spacing16),
                                  padding: const EdgeInsets.all(SaaSDesign.spacing16),
                                  decoration: BoxDecoration(
                                    color: SaaSDesign.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
                                    border: Border.all(
                                      color: SaaSDesign.error.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: SaaSDesign.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: SaaSDesign.spacing8),
                                      Expanded(
                                        child: Text(
                                          authViewModel.errorMessage!,
                                          style: TextStyle(
                                            color: SaaSDesign.error,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              SizedBox(
                                width: double.infinity,
                                child: AnimatedSaaSButton(
                                  text: 'Créer mon compte',
                                  onPressed: _handleRegister,
                                  isLoading: authViewModel.isLoading,
                                  icon: Icons.person_add,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: SaaSDesign.spacing24),
                    
                    // Lien vers la connexion
                    SlideAndFadeAnimation(
                      index: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Déjà un compte ? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Se connecter',
                              style: TextStyle(
                                color: SaaSDesign.primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: SaaSDesign.spacing48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaaSTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE8E8E8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: SaaSDesign.spacing8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          cursorColor: SaaSDesign.primaryOrange,
          style: SaaSDesign.fieldTextStyle,
          decoration: SaaSDesign.fieldDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildSaaSRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RÔLE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: SaaSDesign.primaryOrange,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: SaaSDesign.spacing16),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSaaSRoleOption(
                UserRole.employee,
                'Employé',
                'Faire des demandes de congés',
                Icons.person,
              ),
            ),
            const SizedBox(width: SaaSDesign.spacing12),
            Expanded(
              child: _buildSaaSRoleOption(
                UserRole.manager,
                'Responsable',
                'Gérer une équipe',
                Icons.admin_panel_settings,
              ),
            ),
          ],
        ),
        const SizedBox(height: SaaSDesign.spacing12),
        Text(
          _selectedRole == UserRole.manager
              ? 'Vous aurez accès à l’espace responsable pour accepter ou refuser les demandes de votre équipe.'
              : 'Vous pourrez créer des demandes de congés. Un administrateur doit vous rattacher à un responsable pour qu’elles lui arrivent.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSaaSRoleOption(
    UserRole role,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _selectedRole == role;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: SaaSDesign.spacing8,
          vertical: SaaSDesign.spacing12,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? SaaSDesign.primaryOrange.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(SaaSDesign.radiusMedium),
          border: Border.all(
            color: isSelected 
                ? SaaSDesign.primaryOrange
                : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected ? SaaSDesign.elevationLow : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(SaaSDesign.spacing8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? SaaSDesign.primaryOrange
                    : Colors.grey[400],
                borderRadius: BorderRadius.circular(SaaSDesign.radiusSmall),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: SaaSDesign.spacing8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected 
                      ? SaaSDesign.primaryOrange 
                      : Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: SaaSDesign.spacing4),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}