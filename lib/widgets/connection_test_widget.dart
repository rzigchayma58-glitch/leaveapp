import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_config.dart';

class ConnectionTestWidget extends StatefulWidget {
  const ConnectionTestWidget({Key? key}) : super(key: key);

  @override
  State<ConnectionTestWidget> createState() => _ConnectionTestWidgetState();
}

class _ConnectionTestWidgetState extends State<ConnectionTestWidget> {
  bool _isLoading = false;
  String _result = '';
  Color _statusColor = Colors.grey;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Test en cours...';
      _statusColor = Colors.orange;
    });

    try {
      // Test endpoint spécial Flutter
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/flutter/test'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() {
          _result = '✅ Backend connecté PORT 8082\nRéponse: ${response.body}';
          _statusColor = Colors.green;
        });
      } else {
        setState(() {
          _result = '⚠️ Backend répond (${response.statusCode})\nCorps: ${response.body}';
          _statusColor = Colors.orange;
        });
      }
    } catch (e) {
      setState(() {
        _result = '❌ Erreur connexion:\n$e';
        _statusColor = Colors.red;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testAuth() async {
    setState(() {
      _isLoading = true;
      _result = 'Test auth en cours...';
      _statusColor = Colors.orange;
    });

    try {
      // Test endpoint auth/me (doit retourner 401)
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/me'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        setState(() {
          _result = '✅ Auth endpoint fonctionne\n401 Unauthorized (attendu)';
          _statusColor = Colors.green;
        });
      } else {
        setState(() {
          _result = '⚠️ Auth endpoint code: ${response.statusCode}\nRéponse: ${response.body}';
          _statusColor = Colors.orange;
        });
      }
    } catch (e) {
      setState(() {
        _result = '❌ Erreur test auth:\n$e';
        _statusColor = Colors.red;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.network_check,
                color: _statusColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Test Connexion Backend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'URL: ${ApiConfig.baseUrl}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testConnection,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow),
                  label: const Text('Test Flutter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testAuth,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.security),
                  label: const Text('Test Auth'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _statusColor.withOpacity(0.3)),
              ),
              child: Text(
                _result,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: _statusColor == Colors.green ? Colors.green[800] : 
                         _statusColor == Colors.red ? Colors.red[800] : Colors.orange[800],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}