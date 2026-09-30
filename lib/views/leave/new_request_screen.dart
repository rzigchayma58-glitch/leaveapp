import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../models/leave_request.dart';
import '../../widgets/custom_button.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/leave_viewmodel.dart';
import '../../services/file_service.dart';
import '../../services/leave_service.dart';
import '../../services/api_config.dart';

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({Key? key}) : super(key: key);

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final FileService _fileService = FileService();
  
  LeaveType _selectedType = LeaveType.leave;
  int? _selectedLeaveTypeId;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _calculatedDays;
  List<AttachedFile> _attachments = [];
  
  // 🎯 CACHE POUR LES TYPES DE CONGÉ
  List<LeaveTypeModel>? _leaveTypes;
  bool _isLoadingTypes = false;
  String? _typesError;

  @override
  void initState() {
    super.initState();
    // ⚡ Chargement différé - ne ralentit plus le démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadLeaveTypes();
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaveTypes({bool forceRefresh = false}) async {
    if (_isLoadingTypes) return;
    if (!forceRefresh && _leaveTypes != null && _leaveTypes!.isNotEmpty) return;

    setState(() {
      _isLoadingTypes = true;
      _typesError = null;
    });

    try {
      print('🔄 Chargement des types de congé depuis le backend...');
      final types = await LeaveService().getLeaveTypes(forceRefresh: forceRefresh);

      if (!mounted) return;
      setState(() {
        _leaveTypes = types;
        _isLoadingTypes = false;
        _typesError = null;
        if (_selectedLeaveTypeId != null &&
            types.every((type) => type.id != _selectedLeaveTypeId)) {
          _selectedLeaveTypeId = null;
        }
      });
    } catch (e) {
      print('⚠️ Erreur chargement types: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingTypes = false;
        _leaveTypes = [];
        _typesError = e is ApiException
            ? e.message
            : 'Impossible de charger les types de congé. Vérifiez la connexion au serveur.';
      });
    }
  }

  void _calculateWorkingDays() {
    if (_startDate != null && _endDate != null && _selectedType == LeaveType.leave) {
      final leaveViewModel = Provider.of<LeaveViewModel>(context, listen: false);
      _calculatedDays = leaveViewModel.calculateWorkingDays(_startDate!, _endDate!);
      setState(() {});
    }
  }

  Widget _buildAdvanceNoticeInfo() {
    if (_startDate == null) return const SizedBox.shrink();
    
    final leaveViewModel = Provider.of<LeaveViewModel>(context, listen: false);
    final dateError = leaveViewModel.getAdvanceNoticeError(_selectedType, _startDate);
    
    // Pour les autorisations d'absence, vérifier aussi la durée
    String? durationError;
    if (_selectedType == LeaveType.absence && _startTime != null && _endTime != null) {
      durationError = leaveViewModel.getAbsenceDurationError(_startTime, _endTime);
    }
    
    // S'il y a une erreur (date ou durée)
    if (dateError != null || durationError != null) {
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConstants.rejectedColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppConstants.rejectedColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Erreur de délai de préavis
            if (dateError != null) ...[
              Row(
                children: [
                  const Icon(Icons.warning, color: AppConstants.rejectedColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dateError,
                      style: const TextStyle(
                        color: AppConstants.rejectedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Il reste encore ${leaveViewModel.getHoursUntilMinimum(_selectedType, _startDate!)} heures avant le délai minimum.',
                style: const TextStyle(
                  color: AppConstants.rejectedColor,
                  fontSize: 11,
                ),
              ),
            ],
            
            // Erreur de durée
            if (durationError != null) ...[
              if (dateError != null) const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, color: AppConstants.rejectedColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      durationError,
                      style: const TextStyle(
                        color: AppConstants.rejectedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    } else {
      // Affichage de confirmation (tout est valide)
      final minHours = _selectedType == LeaveType.absence ? 48 : 72;
      
      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppConstants.approvedColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppConstants.approvedColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Délai de préavis respecté (minimum ${minHours}h)',
                    style: const TextStyle(
                      color: AppConstants.approvedColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            // Affichage de la durée pour les autorisations d'absence
            if (_selectedType == LeaveType.absence && _startTime != null && _endTime != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule, color: AppConstants.approvedColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Durée : ${_formatDuration(leaveViewModel.calculateAbsenceDurationMinutes(_startTime!, _endTime!))}',
                    style: const TextStyle(
                      color: AppConstants.approvedColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    }
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}min';
    }
  }

  void _showAttachmentOptions() {
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
                    AppConstants.attachmentOptions,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Certificat médical, justificatif, etc.',
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.secondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            _buildAttachmentOption(Icons.camera_alt, AppConstants.takePhoto, _takePhoto),
            _buildAttachmentOption(Icons.photo_library, AppConstants.chooseFromGallery, _pickImageFromGallery),
            _buildAttachmentOption(Icons.description, AppConstants.selectDocument, _pickDocument),
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

  Widget _buildAttachmentOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryOrange),
      title: Text(
        title,
        style: TextStyle(color: ThemeColors.textColor(context)),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _takePhoto() async {
    if (_attachments.length >= AppConstants.maxAttachments) {
      _showErrorMessage(AppConstants.maxAttachmentsError);
      return;
    }

    final attachment = await _fileService.takePhoto();
    if (attachment != null) {
      if (_fileService.isValidFileSize(attachment.size, AppConstants.maxAttachmentSizeBytes)) {
        setState(() {
          _attachments.add(attachment);
        });
      } else {
        _showErrorMessage(AppConstants.attachmentTooLargeError);
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (_attachments.length >= AppConstants.maxAttachments) {
      _showErrorMessage(AppConstants.maxAttachmentsError);
      return;
    }

    final attachment = await _fileService.pickImageFromGallery();
    if (attachment != null) {
      if (_fileService.isValidFileSize(attachment.size, AppConstants.maxAttachmentSizeBytes)) {
        setState(() {
          _attachments.add(attachment);
        });
      } else {
        _showErrorMessage(AppConstants.attachmentTooLargeError);
      }
    }
  }

  Future<void> _pickDocument() async {
    if (_attachments.length >= AppConstants.maxAttachments) {
      _showErrorMessage(AppConstants.maxAttachmentsError);
      return;
    }

    final attachment = await _fileService.pickDocument();
    if (attachment != null) {
      if (_fileService.isValidFileSize(attachment.size, AppConstants.maxAttachmentSizeBytes)) {
        setState(() {
          _attachments.add(attachment);
        });
      } else {
        _showErrorMessage(AppConstants.attachmentTooLargeError);
      }
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.rejectedColor,
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.attachments,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: ThemeColors.secondaryTextColor(context),
            letterSpacing: 0.5,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Bouton d'ajout
        GestureDetector(
          onTap: _showAttachmentOptions,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: ThemeColors.surfaceColor(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _attachments.length >= AppConstants.maxAttachments 
                    ? ThemeColors.secondaryTextColor(context)
                    : AppConstants.primaryOrange,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.attach_file,
                  color: _attachments.length >= AppConstants.maxAttachments 
                      ? ThemeColors.secondaryTextColor(context)
                      : AppConstants.primaryOrange,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _attachments.length >= AppConstants.maxAttachments
                        ? 'Maximum ${AppConstants.maxAttachments} fichiers'
                        : AppConstants.addAttachment,
                    style: TextStyle(
                      color: _attachments.length >= AppConstants.maxAttachments 
                          ? ThemeColors.secondaryTextColor(context)
                          : AppConstants.primaryOrange,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Liste des fichiers attachés
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...List.generate(_attachments.length, (index) {
            final attachment = _attachments[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeColors.surfaceColor(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ThemeColors.borderColor(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    attachment.icon,
                    color: AppConstants.primaryOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attachment.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ThemeColors.textColor(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          attachment.displaySize,
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeColors.secondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeAttachment(index),
                    icon: const Icon(
                      Icons.close,
                      color: AppConstants.rejectedColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 4)), // 4 jours dans le futur par défaut
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
      _calculateWorkingDays();
      // Déclencher la mise à jour pour afficher les validations
      setState(() {});
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
      // Déclencher la mise à jour pour afficher les validations de durée
      setState(() {});
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == LeaveType.leave && (_startDate == null || _endDate == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner les dates de début et de fin'),
            backgroundColor: AppConstants.rejectedColor,
          ),
        );
        return;
      }

      if (_selectedType == LeaveType.absence && (_startDate == null || _startTime == null || _endTime == null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner la date et les heures'),
            backgroundColor: AppConstants.rejectedColor,
          ),
        );
        return;
      }

      // Validation du délai de préavis
      final leaveViewModel = Provider.of<LeaveViewModel>(context, listen: false);
      final advanceError = leaveViewModel.getAdvanceNoticeError(_selectedType, _startDate);
      if (advanceError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(advanceError),
            backgroundColor: AppConstants.rejectedColor,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // Validation de la durée pour les autorisations d'absence
      if (_selectedType == LeaveType.absence) {
        final durationError = leaveViewModel.getAbsenceDurationError(_startTime, _endTime);
        if (durationError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(durationError),
              backgroundColor: AppConstants.rejectedColor,
              duration: const Duration(seconds: 4),
            ),
          );
          return;
        }
      }

      if (_selectedType == LeaveType.leave && _selectedLeaveTypeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un type de congé'),
            backgroundColor: AppConstants.rejectedColor,
          ),
        );
        return;
      }

      List<LeaveTypeModel> availableTypes = _leaveTypes ?? [];
      if (availableTypes.isEmpty) {
        await _loadLeaveTypes(forceRefresh: true);
        availableTypes = _leaveTypes ?? [];
      }
      if (availableTypes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Types de congé indisponibles. Réessayez dans un instant.'),
            backgroundColor: AppConstants.rejectedColor,
          ),
        );
        return;
      }

      late final int leaveTypeId;
      try {
        leaveTypeId = LeaveService().resolveLeaveTypeId(
          types: availableTypes,
          isAbsence: _selectedType == LeaveType.absence,
          selectedId: _selectedLeaveTypeId,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : 'Type de congé invalide'),
            backgroundColor: AppConstants.rejectedColor,
          ),
        );
        return;
      }

      final success = await leaveViewModel.createLeaveRequest(
        leaveTypeId: leaveTypeId,
        startDate: _startDate!,
        endDate: _endDate ?? _startDate!,
        reason: _commentController.text.trim().isNotEmpty ? _commentController.text.trim() : null,
        requestType: _selectedType,
        startTime: _startTime,
        endTime: _endTime,
        attachments: List<AttachedFile>.from(_attachments),
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(leaveViewModel.errorMessage ?? 'La demande n\'a pas pu être envoyée'),
            backgroundColor: AppConstants.rejectedColor,
          ),
        );
        return;
      }

      if (success) {
        final warning = leaveViewModel.attachmentWarning;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(warning ?? 'Demande envoyée avec succès !'),
            backgroundColor: warning == null
                ? AppConstants.approvedColor
                : AppConstants.primaryOrange,
            duration: Duration(seconds: warning == null ? 3 : 6),
          ),
        );
        
        // Reset form
        setState(() {
          _selectedType = LeaveType.leave;
          _selectedLeaveTypeId = null;
          _startDate = null;
          _endDate = null;
          _startTime = null;
          _endTime = null;
          _calculatedDays = null;
          _attachments.clear();
          _commentController.clear();
        });
      }
    }
  }

  // 🎯 DROPDOWN SIMPLE ET PROPRE POUR LES 4 TYPES MYSQL
  Widget _buildLeaveTypeDropdown() {
    // Chargement en cours
    if (_isLoadingTypes) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeColors.inputFillColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ThemeColors.borderColor(context)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppConstants.primaryOrange),
            ),
            SizedBox(width: 12),
            Text("Chargement des types..."),
          ],
        ),
      );
    }

    if (_typesError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeColors.inputFillColor(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppConstants.rejectedColor.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _typesError!,
              style: const TextStyle(color: AppConstants.rejectedColor, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _loadLeaveTypes(forceRefresh: true),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final availableTypes = (_leaveTypes ?? []).where((type) => !type.isAbsence).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          value: _selectedLeaveTypeId,
          hint: Text(
            "Sélectionnez la nature du congé",
            style: TextStyle(
              color: ThemeColors.secondaryTextColor(context),
              fontSize: 14,
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: ThemeColors.inputFillColor(context),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ThemeColors.borderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ThemeColors.borderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppConstants.primaryOrange, width: 2),
            ),
          ),
          items: availableTypes.map((leaveType) {
            return DropdownMenuItem<int>(
              value: leaveType.id,
              child: Text(
                leaveType.name,
                style: TextStyle(
                  color: ThemeColors.textColor(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: (int? newId) {
            setState(() {
              _selectedLeaveTypeId = newId;
            });
            
            if (newId != null) {
              final selectedType = availableTypes.firstWhere((type) => type.id == newId);
              print('🔄 Type sélectionné: ID $newId - ${selectedType.name}');
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          AppConstants.newRequest,
          style: TextStyle(
            color: ThemeColors.textColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ThemeColors.appBarColor(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type de demande
              Text(
                AppConstants.requestType,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ThemeColors.secondaryTextColor(context),
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = LeaveType.leave;
                        });
                        // ⚡ Charger les types seulement maintenant
                        _loadLeaveTypes();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedType == LeaveType.leave 
                              ? AppConstants.primaryOrange 
                              : ThemeColors.surfaceColor(context),
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(8),
                          ),
                          border: Border.all(
                            color: _selectedType == LeaveType.leave 
                                ? AppConstants.primaryOrange 
                                : ThemeColors.borderColor(context),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            AppConstants.leaveType,
                            style: TextStyle(
                              color: _selectedType == LeaveType.leave 
                                  ? AppConstants.whiteColor 
                                  : ThemeColors.textColor(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = LeaveType.absence;
                          _endDate = null;
                          _calculatedDays = null;
                        });
                        _loadLeaveTypes();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedType == LeaveType.absence 
                              ? AppConstants.primaryOrange 
                              : ThemeColors.surfaceColor(context),
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(8),
                          ),
                          border: Border.all(
                            color: _selectedType == LeaveType.absence 
                                ? AppConstants.primaryOrange 
                                : ThemeColors.borderColor(context),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            AppConstants.absenceType,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedType == LeaveType.absence 
                                  ? AppConstants.whiteColor 
                                  : ThemeColors.textColor(context),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Nature du congé (seulement pour les congés, PAS pour autorisation d'absence)
              if (_selectedType == LeaveType.leave) ...[
                Text(
                  AppConstants.leaveNature,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ThemeColors.secondaryTextColor(context),
                    letterSpacing: 0.5,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 🎯 DROPDOWN AVEC CACHE LOCAL
                _buildLeaveTypeDropdown(),
                
                const SizedBox(height: 24),
              ],

              // Dates
              if (_selectedType == LeaveType.leave) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.startDate,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ThemeColors.secondaryTextColor(context),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectDate(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: ThemeColors.inputFillColor(context),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: ThemeColors.borderColor(context)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDate(_startDate).isNotEmpty 
                                        ? _formatDate(_startDate) 
                                        : '12/08/2026',
                                    style: TextStyle(
                                      color: _startDate != null 
                                          ? ThemeColors.textColor(context)
                                          : ThemeColors.secondaryTextColor(context),
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: ThemeColors.iconColor(context),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.endDate,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ThemeColors.secondaryTextColor(context),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectDate(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: ThemeColors.inputFillColor(context),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: ThemeColors.borderColor(context)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDate(_endDate).isNotEmpty 
                                        ? _formatDate(_endDate) 
                                        : '16/08/2026',
                                    style: TextStyle(
                                      color: _endDate != null 
                                          ? ThemeColors.textColor(context)
                                          : ThemeColors.secondaryTextColor(context),
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: ThemeColors.iconColor(context),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (_calculatedDays != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calculate,
                          color: AppConstants.primaryOrange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_calculatedDays ${AppConstants.workingDays}',
                          style: const TextStyle(
                            color: AppConstants.primaryOrange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            AppConstants.autoCalculation,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: AppConstants.primaryOrange,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Affichage de la validation du délai de préavis
                _buildAdvanceNoticeInfo(),
              ] else ...[
                // Date et heures pour autorisation d'absence
                Text(
                  'DATE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ThemeColors.secondaryTextColor(context),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: ThemeColors.inputFillColor(context),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ThemeColors.borderColor(context)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(_startDate).isNotEmpty 
                              ? _formatDate(_startDate) 
                              : '12/08/2026',
                          style: TextStyle(
                            color: _startDate != null 
                                ? ThemeColors.textColor(context)
                                : ThemeColors.secondaryTextColor(context),
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: ThemeColors.iconColor(context),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.startTime,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ThemeColors.secondaryTextColor(context),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectTime(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: ThemeColors.inputFillColor(context),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: ThemeColors.borderColor(context)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatTime(_startTime).isNotEmpty 
                                        ? _formatTime(_startTime) 
                                        : '09:00',
                                    style: TextStyle(
                                      color: _startTime != null 
                                          ? ThemeColors.textColor(context)
                                          : ThemeColors.secondaryTextColor(context),
                                    ),
                                  ),
                                  Icon(
                                    Icons.access_time,
                                    color: ThemeColors.iconColor(context),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.endTime,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ThemeColors.secondaryTextColor(context),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectTime(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: ThemeColors.inputFillColor(context),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: ThemeColors.borderColor(context)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatTime(_endTime).isNotEmpty 
                                        ? _formatTime(_endTime) 
                                        : '11:00',
                                    style: TextStyle(
                                      color: _endTime != null 
                                          ? ThemeColors.textColor(context)
                                          : ThemeColors.secondaryTextColor(context),
                                    ),
                                  ),
                                  Icon(
                                    Icons.access_time,
                                    color: ThemeColors.iconColor(context),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Affichage de la validation du délai de préavis pour autorisation d'absence
                _buildAdvanceNoticeInfo(),
              ],

              const SizedBox(height: 24),

              // Commentaire
              Text(
                AppConstants.comment,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ThemeColors.secondaryTextColor(context),
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: AppConstants.commentPlaceholder,
                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(top: 8, right: 8),
                    child: Icon(
                      Icons.edit,
                      color: AppConstants.greyColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section Pièces Jointes
              _buildAttachmentsSection(),

              const SizedBox(height: 32),

              // Bouton d'envoi
              Consumer<LeaveViewModel>(
                builder: (context, leaveViewModel, child) {
                  return CustomButton(
                    text: AppConstants.sendRequest,
                    onPressed: _submitRequest,
                    isLoading: leaveViewModel.isLoading,
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}