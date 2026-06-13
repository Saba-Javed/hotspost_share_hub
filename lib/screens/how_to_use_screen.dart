import 'package:flutter/material.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('How to Use')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _sectionCard(
              context,
              icon: Icons.play_circle_outline,
              color: Colors.blue,
              title: '1. How to Start a Hotspot Session',
              steps: const [
                'First, turn ON your phone\'s mobile hotspot from system settings (Settings → Network & Internet → Hotspot & Tethering).',
                'Note the WiFi name (SSID) and password you set in your phone\'s hotspot settings.',
                'Open Smart Share Hub and tap "Start Hotspot Session" on the dashboard.',
                'Enter the same WiFi name and password, choose a session duration, then tap "Start Session & Generate QR".',
              ],
            ),
            _sectionCard(
              context,
              icon: Icons.qr_code_2,
              color: Colors.purple,
              title: '2. How to Generate & Share the QR Code',
              steps: const [
                'After starting a session, the app automatically generates a QR code containing your WiFi name and password.',
                'Tap "View QR Code" anytime during an active session to display it again.',
                'Show this QR code to the person you want to share your internet with.',
                'You can tap the eye icon to reveal or hide the password text if they prefer typing it manually.',
              ],
            ),
            _sectionCard(
              context,
              icon: Icons.qr_code_scanner,
              color: Colors.green,
              title: '3. How Others Connect',
              steps: const [
                'The other person opens their phone\'s camera app (most modern phones scan WiFi QR codes natively).',
                'They point the camera at your screen showing the QR code.',
                'Their phone will show a notification to "Join Network" — they tap it to connect automatically.',
                'If their phone doesn\'t support QR scanning, they can manually type the WiFi name and password shown in the app.',
              ],
            ),
            _sectionCard(
              context,
              icon: Icons.stop_circle_outlined,
              color: Colors.red,
              title: '4. How to End a Session',
              steps: const [
                'Tap the large "End Session" button on the dashboard at any time.',
                'Confirm the action in the popup dialog.',
                'The session is automatically saved to your History with duration, data usage, and timestamps.',
                'Sessions also end automatically when the selected duration timer runs out.',
                'Remember to also turn OFF your hotspot in your phone\'s system settings when you\'re done.',
              ],
            ),
            _sectionCard(
              context,
              icon: Icons.shield_outlined,
              color: Colors.orange,
              title: '5. Safety Tips for Sharing Internet',
              steps: const [
                'Only share your hotspot with people you trust — anyone connected can see your network activity in some cases.',
                'Use a strong password (at least 8 characters) and avoid simple/common passwords.',
                'Set a session duration limit instead of leaving it unlimited, especially with new contacts.',
                'Monitor your data usage regularly to avoid exceeding your mobile data plan.',
                'Turn off your hotspot completely when not actively sharing.',
                'Change your hotspot password periodically, especially after sharing with many different people.',
                'Avoid sharing sensitive personal information while connected to a shared hotspot.',
              ],
            ),
            Card(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Smart Share Hub does not connect to, modify, or bypass any telecom operator network or system. It is purely an organizational and tracking tool that works alongside your phone\'s built-in hotspot feature.',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required List<String> steps,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...steps.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(entry.value, style: const TextStyle(fontSize: 13.5, height: 1.4)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
