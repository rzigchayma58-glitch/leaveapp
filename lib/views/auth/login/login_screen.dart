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
import '../register/register_screen.dart';
import '../forgot_password/forgot_password_screen.dart';
import '../../main/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      return 'Veuillez saisir votre mot de passe';
    }
    return null;
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final success = await authViewModel.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        // Navigation vers l'écran principal avec animation SaaS
        Navigator.of(context).pushReplacement(
          SaaSPageRoute(child: const MainScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SaaSDesign.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: SaaSDesign.spacing48),
                
                // Logo et titre avec animation
                SlideAndFadeAnimation(
                  index: 0,
                  child: Column(
                    children: [
                      const AppLogo(),
                      const SizedBox(height: SaaSDesign.spacing32),
                      const Text(
                        'Connexion',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: SaaSDesign.spacing8),
                      Text(
                        'Accédez à votre espace personnel',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: SaaSDesign.spacing48),
                
                // Formulaire de connexion avec animation
                SlideAndFadeAnimation(
                  index: 1,
                  child: SaaSCard(
                    padding: const EdgeInsets.all(SaaSDesign.spacing32),
                    child: Column(
                      children: [
                        // Champ email
                        _buildSaaSTextField(
                          label: 'Adresse email',
                          hintText: 'votre.email@exemple.com',
                          controller: _emailController,
                          validator: _validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                        ),
                        
                        const SizedBox(height: SaaSDesign.spacing20),
                        
                        // Champ mot de passe
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
                        
                        const SizedBox(height: SaaSDesign.spacing16),
                        
                        // Mot de passe oublié
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                SaaSPageRoute(
                                  child: const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(
                                color: SaaSDesign.primaryOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: SaaSDesign.spacing24),
                        
                        // Bouton de connexion
                        Consumer<AuthViewModel>(
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
                                
                                AnimatedSaaSButton(
                                  text: 'Se connecter',
                                  onPressed: _handleLogin,
                                  isLoading: authViewModel.isLoading,
                                  icon: Icons.login,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: SaaSDesign.spacing32),
                
                // Lien création de compte
                SlideAndFadeAnimation(
                  index: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pas encore de compte ? ',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            SaaSPageRoute(
                              child: const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Créer un compte',
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
}