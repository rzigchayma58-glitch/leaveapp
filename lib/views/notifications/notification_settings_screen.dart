import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../core/theme_colors.dart';
import '../../services/local_notification_service.dart';
import '../../viewmodels/auth_viewmodel.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _requestApprovedEnabled = true;
  bool _requestRejectedEnabled = true;
  bool _newDecisionEnabled = true;
  bool _reminderEnabled = true;
  bool _generalEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _requestApprovedEnabled = prefs.getBool('notif_request_approved') ?? true;
      _requestRejectedEnabled = prefs.getBool('notif_request_rejected') ?? true;
      _newDecisionEnabled = prefs.getBool('notif_new_decision') ?? true;
      _reminderEnabled = prefs.getBool('notif_reminder') ?? true;
      _generalEnabled = prefs.getBool('notif_general') ?? true;
      _soundEnabled = prefs.getBool('notif_sound') ?? true;
      _vibrationEnabled = prefs.getBool('notif_vibration') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_request_approved', _requestApprovedEnabled);
    await prefs.setBool('notif_request_rejected', _requestRejectedEnabled);
    await prefs.setBool('notif_new_decision', _newDecisionEnabled);
    await prefs.setBool('notif_reminder', _reminderEnabled);
    await prefs.setBool('notif_general', _generalEnabled);
    await prefs.setBool('notif_sound', _soundEnabled);
    await prefs.setBool('notif_vibration', _vibrationEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Paramètres de notifications',
          style: TextStyle(
            color: ThemeColors.textColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: ThemeColors.appBarColor(context),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Types de notifications
          _buildSectionHeader('Types de notifications'),
          _buildNotificationToggle(
            'Demandes approuvées',
            'Recevoir une notification quand une demande est approuvée',
            Icons.check_circle_outline,
            AppConstants.approvedColor,
            _requestApprovedEnabled,
            (value) {
              setState(() => _requestApprovedEnabled = value);
              _saveSettings();
            },
          ),
          
          _buildNotificationToggle(
            'Demandes refusées',
            'Recevoir une notification quand une demande est refusée',
            Icons.cancel_outlined,
            AppConstants.rejectedColor,
            _requestRejectedEnabled,
            (value) {
              setState(() => _requestRejectedEnabled = value);
              _saveSettings();
            },
          ),
          
          _buildNotificationToggle(
            'Nouvelles décisions',
            'Recevoir des notifications sur les nouvelles politiques',
            Icons.announcement_outlined,
            AppConstants.primaryOrange,
            _newDecisionEnabled,
            (value) {
              setState(() => _newDecisionEnabled = value);
              _saveSettings();
            },
          ),
          
          _buildNotificationToggle(
            'Rappels',
            'Recevoir des rappels importants',
            Icons.schedule_outlined,
            AppConstants.pendingColor,
            _reminderEnabled,
            (value) {
              setState(() => _reminderEnabled = value);
              _saveSettings();
            },
          ),
          
          _buildNotificationToggle(
            'Notifications générales',
            'Recevoir toutes les autres notifications',
            Icons.info_outline,
            ThemeColors.iconColor(context),
            _generalEnabled,
            (value) {
              setState(() => _generalEnabled = value);
              _saveSettings();
            },
          ),

          const SizedBox(height: 24),

          // Paramètres audio/vibration
          _buildSectionHeader('Paramètres audio'),
          _buildNotificationToggle(
            'Son',
            'Jouer un son pour les nouvelles notifications',
            Icons.volume_up_outlined,
            ThemeColors.iconColor(context),
            _soundEnabled,
            (value) {
              setState(() => _soundEnabled = value);
              _saveSettings();
            },
          ),
          
          _buildNotificationToggle(
            'Vibration',
            'Vibrer pour les nouvelles notifications',
            Icons.vibration_outlined,
            ThemeColors.iconColor(context),
            _vibrationEnabled,
            (value) {
              setState(() => _vibrationEnabled = value);
              _saveSettings();
            },
          ),

          const SizedBox(height: 32),

          // Actions
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ThemeColors.textColor(context),
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeColors.borderColor(context),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.textColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemeColors.secondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppConstants.primaryOrange,
            activeTrackColor: AppConstants.primaryOrange.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Bouton effacer toutes les notifications
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showClearAllDialog(),
            icon: Icon(
              Icons.delete_sweep,
              color: AppConstants.rejectedColor,
            ),
            label: Text(
              'Effacer toutes les notifications',
              style: TextStyle(
                color: AppConstants.rejectedColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppConstants.rejectedColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeColors.surfaceColor(context),
        title: Text(
          'Effacer toutes les notifications',
          style: TextStyle(color: ThemeColors.textColor(context)),
        ),
        content: Text(
          'Cette action supprimera définitivement toutes vos notifications. Voulez-vous continuer ?',
          style: TextStyle(color: ThemeColors.textColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: ThemeColors.textColor(context)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
              final notificationService = Provider.of<LocalNotificationService>(context, listen: false);
              
              if (user != null) {
                await notificationService.deleteAllNotifications(user.id ?? 'user1');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Toutes les notifications ont été supprimées'),
                    backgroundColor: AppConstants.rejectedColor,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppConstants.rejectedColor),
            ),
          ),
        ],
      ),
    );
  }

}