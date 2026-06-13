import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: SwitchListTile(
                      title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Switch between light and dark themes'),
                      secondary: Icon(provider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                      value: provider.isDarkMode,
                      onChanged: (value) => provider.toggleDarkMode(value),
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
                        Row(
                          children: [
                            Icon(Icons.wifi_tethering, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 10),
                            const Text('About Smart Share Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Smart Share Hub helps you organize and track hotspot sharing sessions on your own device. '
                          'It does not connect to any telecom operator API and never modifies network or system settings.',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Version 1.0.0',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
                        Row(
                          children: [
                            Icon(Icons.privacy_tip_outlined, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 10),
                            const Text('Privacy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'All data — including session history, WiFi credentials entered, and usage statistics — is stored locally on your device only. Nothing is uploaded to any server.',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                        ),
                      ],
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
}
