import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../utils/formatters.dart';

class UsageCard extends StatefulWidget {
  const UsageCard({super.key});

  @override
  State<UsageCard> createState() => _UsageCardState();
}

class _UsageCardState extends State<UsageCard> {
  double _today = 0;
  double _week = 0;
  double _total = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provider = Provider.of<SessionProvider>(context, listen: false);
    final today = await provider.getTodayUsage();
    final week = await provider.getWeekUsage();
    final total = await provider.getTotalUsage();
    if (!mounted) return;
    setState(() {
      _today = today;
      _week = week;
      _total = total;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild stats whenever an active session updates usage
    return Consumer<SessionProvider>(
      builder: (context, provider, _) {
        if (provider.hasActiveSession) {
          // Add live session usage on top of stored totals for "today"
          _load();
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.data_usage, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    const Text('Data Usage Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                _loading
                    ? const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                    : Row(
                        children: [
                          _usageStat('Today', _today, Icons.today),
                          _usageStat('This Week', _week, Icons.calendar_view_week),
                          _usageStat('All Time', _total, Icons.all_inclusive),
                        ],
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _usageStat(String label, double mb, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(height: 6),
          Text(
            Formatters.dataSize(mb),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
