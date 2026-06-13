import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../utils/formatters.dart';
import '../widgets/usage_card.dart';
import '../widgets/connected_devices_card.dart';
import 'start_session_screen.dart';
import 'qr_display_screen.dart';
import 'session_history_screen.dart';
import 'how_to_use_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildHomeTab(context),
      const SessionHistoryScreen(),
      const HowToUseScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: screens[_navIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.help_outline), selectedIcon: Icon(Icons.help), label: 'Help'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, _) {
        final session = provider.activeSession;
        final isActive = provider.hasActiveSession;

        return RefreshIndicator(
          onRefresh: () async {
            await provider.refreshHistory();
          },
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Share Hub',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ethical Hotspot Sharing Manager',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.wifi_tethering,
                      color: isActive ? Colors.green : Colors.grey,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Status card
              _buildStatusCard(context, provider, session, isActive),
              const SizedBox(height: 16),

              if (isActive) ...[
                _buildActiveSessionDetails(context, provider, session!),
                const SizedBox(height: 16),
                const ConnectedDevicesCard(),
                const SizedBox(height: 16),
              ],

              // Quick usage overview
              const UsageCard(),
              const SizedBox(height: 16),

              // Big Start/Stop button
              _buildMainActionButton(context, provider, isActive),
              const SizedBox(height: 12),

              if (isActive)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QrDisplayScreen()),
                    );
                  },
                  icon: const Icon(Icons.qr_code_2),
                  label: const Text('View QR Code'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard(BuildContext context, SessionProvider provider, dynamic session, bool isActive) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.15)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isActive ? Icons.wifi : Icons.wifi_off,
                color: isActive ? Colors.green : Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActive ? 'Session Active' : 'No Active Session',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isActive
                        ? 'Sharing "${session.wifiName}"'
                        : 'Tap below to start sharing your hotspot',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSessionDetails(BuildContext context, SessionProvider provider, dynamic session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statColumn(
                  'Elapsed Time',
                  Formatters.duration(provider.elapsedTime),
                  Icons.timer_outlined,
                ),
                _statColumn(
                  provider.isUnlimited ? 'Duration' : 'Time Remaining',
                  provider.isUnlimited
                      ? 'Unlimited'
                      : Formatters.duration(provider.remainingTime),
                  Icons.hourglass_bottom,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!provider.isUnlimited)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progressValue(provider),
                  minHeight: 8,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statColumn(
                  'Data Used',
                  Formatters.dataSize(session.dataUsageMB),
                  Icons.data_usage,
                ),
                _statColumn(
                  'Connected Devices',
                  '${provider.connectedDevices.where((d) => d.disconnectedAt == null).length}',
                  Icons.devices,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _progressValue(SessionProvider provider) {
    final total = provider.activeSession!.durationMinutes * 60;
    final elapsed = provider.elapsedTime.inSeconds;
    if (total == 0) return 0;
    final value = elapsed / total;
    return value.clamp(0.0, 1.0);
  }

  Widget _statColumn(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton(BuildContext context, SessionProvider provider, bool isActive) {
    return SizedBox(
      height: 64,
      child: ElevatedButton.icon(
        onPressed: () async {
          if (isActive) {
            _confirmEndSession(context, provider);
          } else {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StartSessionScreen()),
            );
            if (result == true && mounted) {
              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrDisplayScreen()),
              );
            }
          }
        },
        icon: Icon(isActive ? Icons.stop_circle_outlined : Icons.play_circle_outline, size: 28),
        label: Text(
          isActive ? 'End Session' : 'Start Hotspot Session',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.red : Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  void _confirmEndSession(BuildContext context, SessionProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text('This will end the current hotspot sharing session and save it to history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.endSession();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}
