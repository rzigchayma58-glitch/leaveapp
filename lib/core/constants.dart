import 'package:flutter/material.dart';

class AppConstants {
  // Light Theme Colors
  static const Color primaryOrange = Color(0xFFFF6B35);
  static const Color lightOrange = Color(0xFFFF8B5A);
  static const Color darkOrange = Color(0xFFE55A2B);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color whiteColor = Colors.white;
  static const Color greyColor = Color(0xFF9E9E9E);
  static const Color darkGreyColor = Color(0xFF424242);
  static const Color lightGreyColor = Color(0xFFE0E0E0);
  static const Color textFieldBorderColor = Color(0xFFBDBDBD);
  
  // Dark Theme Colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkCardColor = Color(0xFF2D2D2D);
  static const Color darkTextColor = Color(0xFFE0E0E0);
  static const Color darkSecondaryTextColor = Color(0xFFB0B0B0);
  static const Color darkBorderColor = Color(0xFF404040);
  static const Color darkInputFillColor = Color(0xFF2D2D2D);
  
  // App Info
  static const String appName = 'XCongés';
  static const String appSubtitle = 'Gestion des congés Xtensus';
  
  // Additional colors
  static const Color primaryBlue = Color(0xFF2196F3);
  
  // Validation Rules
  static const int minHoursAbsence = 48; // 48 heures pour autorisation d'absence
  static const int minHoursLeave = 72;   // 72 heures pour congé
  static const int maxHoursAbsenceDuration = 2; // 2 heures maximum pour autorisation d'absence
  
  // Error Messages
  static const String absenceAdvanceError = 'Les autorisations d\'absence doivent être demandées au minimum 48 heures à l\'avance';
  static const String leaveAdvanceError = 'Les congés doivent être demandés au minimum 72 heures à l\'avance';
  static const String invalidDateError = 'Veuillez sélectionner une date valide';
  static const String absenceDurationError = 'Les autorisations d\'absence ne peuvent pas dépasser 2 heures';
  static const String invalidTimeRangeError = 'L\'heure de fin doit être après l\'heure de début';
  
  // Colors - Status
  static const Color pendingColor = Color(0xFFFF8B35);
  static const Color approvedColor = Color(0xFF4CAF50);
  static const Color rejectedColor = Color(0xFFF44336);
  
  // Text Strings - Auth
  static const String email = 'EMAIL';
  static const String password = 'MOT DE PASSE';
  static const String forgotPassword = 'Mot de passe oublié ?';
  static const String createAccount = 'Créer un compte';
  static const String login = 'Se connecter';
  static const String firstName = 'PRÉNOM';
  static const String lastName = 'NOM';
  static const String employeeId = 'MATRICULE';
  static const String department = 'DÉPARTEMENT';
  static const String confirmPassword = 'CONFIRMER LE MOT DE PASSE';
  static const String createMyAccount = 'Créer mon compte';
  static const String alreadyHaveAccount = 'Déjà un compte ? Se connecter';
  static const String joinXConges = 'Rejoignez XCongés';
  static const String forgotPasswordTitle = 'Mot de passe oublié';
  static const String passwordRecovery = 'Récupération du mot de passe';
  static const String passwordRecoverySubtitle = 'Saisissez votre adresse email pour recevoir un lien de réinitialisation de mot de passe.';
  static const String sendLink = 'Envoyer le lien';
  
  // Text Strings - Navigation
  static const String homeTab = 'Accueil';
  static const String newRequestTab = 'Nouvelle';
  static const String historyTab = 'Historique';
  static const String profileTab = 'Profil';
  
  // Text Strings - Home
  static const String availableBalance = 'Solde disponible';
  static const String days = 'jours';
  static const String pending = 'En attente';
  static const String approved = 'Approuvés';
  static const String rejected = 'Refusés';
  static const String sickLeaveApproved = 'Congé maladie approuvé';
  static const String daysAgo = 'Il y a 2 jours';
  
  // Text Strings - Profile
  static const String employeeProfile = 'Profil employé';
  static const String editProfile = 'Modifier le profil';
  static const String personalInfo = 'Informations personnelles';
  static const String professionalInfo = 'Informations professionnelles';
  static const String darkMode = 'Mode sombre';
  static const String aboutApp = 'À propos de l\'application';
  static const String logout = 'Déconnexion';
  static const String addPhoto = 'Ajouter une photo';
  static const String save = 'Enregistrer';
  static const String deleteAccount = 'Supprimer le compte';
  
  // Text Strings - Request
  static const String newRequest = 'Nouvelle demande';
  static const String requestType = 'TYPE DE DEMANDE';
  static const String leaveType = 'Congé';
  static const String absenceType = 'Autorisation d\'absence';
  static const String leaveNature = 'NATURE DU CONGÉ';
  static const String annualLeave = 'Congé annuel';
  static const String exceptionalLeave = 'Congé exceptionnel (raisons familiales)';
  static const String sickLeave = 'Congé de maladie';
  static const String otherReason = 'Autre motif';
  static const String startDate = 'DÉBUT';
  static const String endDate = 'FIN';
  static const String startTime = 'DE';
  static const String endTime = 'À';
  static const String comment = 'COMMENTAIRE';
  static const String commentPlaceholder = 'Précision (optionnel)';
  static const String sendRequest = 'Envoyer la demande';
  static const String workingDays = 'jours ouvrés';
  static const String autoCalculation = 'Calcul automatique';
  static const String attachments = 'PIÈCES JOINTES';
  static const String addAttachment = 'Ajouter une pièce jointe';
  static const String attachmentOptions = 'Choisir un fichier';
  static const String takePhoto = 'Prendre une photo';
  static const String chooseFromGallery = 'Choisir dans la galerie';
  static const String selectDocument = 'Sélectionner un document';
  static const String removeAttachment = 'Supprimer';
  static const String maxAttachmentsError = 'Maximum 3 pièces jointes autorisées';
  static const String attachmentTooLargeError = 'Fichier trop volumineux (max 5MB)';
  static const int maxAttachments = 3;
  static const int maxAttachmentSizeBytes = 5 * 1024 * 1024; // 5MB
  
  // Text Strings - History
  static const String myRequests = 'Mes demandes';
  static const String pendingStatus = 'En attente';
  static const String approvedStatus = 'Approuvés';
  static const String rejectedStatus = 'Refusée';
  
  // Placeholders
  static const String emailPlaceholder = 'votre.email@xtensus.com';
  static const String firstNamePlaceholder = 'Votre prénom';
  static const String lastNamePlaceholder = 'Votre nom';
  static const String employeeIdPlaceholder = 'Ex: 4521';
  static const String departmentPlaceholder = 'Ex: IT';
}