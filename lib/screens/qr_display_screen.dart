import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/session_provider.dart';
import '../utils/formatters.dart';

class QrDisplayScreen extends StatefulWidget {
  const QrDisplayScreen({super.key});

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  bool _revealPassword = false;

  // Standard WIFI QR format recognized by Android & iOS camera apps
  String _buildWifiQrData(String ssid, String password) {
    String escape(String s) {
      return s
          .replaceAll('\\', '\\\\')
          .replaceAll(';', '\\;')
          .replaceAll(',', '\\,')
          .replaceAll(':', '\\:')
          .replaceAll('"', '\\"');
    }

    final escapedSsid = escape(ssid);
    final escapedPass = escape(password);
    return 'WIFI:T:WPA;S:$escapedSsid;P:$escapedPass;;';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, _) {
        final session = provider.activeSession;

        if (session == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('QR Code')),
            body: const Center(child: Text('No active session.')),
          );
        }

        final qrData = _buildWifiQrData(session.wifiName, session.wifiPassword);

        return Scaffold(
          appBar: AppBar(title: const Text('Share QR Code')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 220,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Scan to Connect',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Open camera app and point at this code',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(Icons.wifi, 'Network Name', session.wifiName),
                        const Divider(height: 24),
                        _infoRow(
                          Icons.lock_outline,
                          'Password',
                          _revealPassword ? session.wifiPassword : '•' * session.wifiPassword.length,
                          trailing: IconButton(
                            icon: Icon(_revealPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _revealPassword = !_revealPassword),
                          ),
                        ),
                        const Divider(height: 24),
                        _infoRow(
                          Icons.timer_outlined,
                          'Session Duration',
                          provider.isUnlimited ? 'Unlimited' : Formatters.durationLabel(session.durationMinutes),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.tips_and_updates_outlined, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ask the other person to scan this code with their phone camera. Most phones will detect it automatically and prompt to join the WiFi network.',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Dashboard'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
