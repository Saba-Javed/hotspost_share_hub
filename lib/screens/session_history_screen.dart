import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/session_provider.dart';
import '../models/session_model.dart';
import '../utils/formatters.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  Map<String, double> _dailyUsage = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  Future<void> _loadChart() async {
    final provider = Provider.of<SessionProvider>(context, listen: false);
    final data = await provider.getDailyUsage(7);
    if (!mounted) return;
    setState(() {
      _dailyUsage = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, provider, _) {
        final sessions = provider.history;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Session History'),
            actions: [
              if (sessions.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: () => _confirmClear(context, provider),
                  tooltip: 'Clear history',
                ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await provider.refreshHistory();
                await _loadChart();
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Last 7 Days Usage (MB)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 16),
                          _loading
                              ? const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))
                              : SizedBox(
                                  height: 180,
                                  child: _buildBarChart(),
                                ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Past Sessions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (sessions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.history, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('No past sessions yet', style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...sessions.map((s) => _sessionTile(context, provider, s)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChart() {
    final entries = _dailyUsage.entries.toList();
    final maxY = entries.isEmpty
        ? 10.0
        : (entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2).clamp(10.0, double.infinity);

    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= entries.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(entries[index].key, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        barGroups: entries.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value,
                color: Theme.of(context).colorScheme.primary,
                width: 18,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _sessionTile(BuildContext context, SessionProvider provider, HotspotSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.wifi_tethering, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(session.wifiName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Formatters.dateTime(session.startTime), style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                'Duration: ${Formatters.duration(session.elapsed)} • Data: ${Formatters.dataSize(session.dataUsageMB)} • Devices: ${session.connectedDevicesCount}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () => provider.deleteSession(session.id!),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, SessionProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All History?'),
        content: const Text('This will permanently delete all session history. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              await provider.clearHistory();
              await _loadChart();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
