import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../services/preferences_service.dart';

class StartSessionScreen extends StatefulWidget {
  const StartSessionScreen({super.key});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wifiNameController = TextEditingController();
  final _wifiPasswordController = TextEditingController();
  bool _obscurePassword = true;

  // 0 = unlimited, others in minutes
  int _selectedDuration = 60;
  final List<Map<String, dynamic>> _durationOptions = [
    {'label': '15 min', 'value': 15},
    {'label': '1 hour', 'value': 60},
    {'label': '2 hours', 'value': 120},
    {'label': 'Custom', 'value': -1},
    {'label': 'Unlimited', 'value': 0},
  ];

  final _customController = TextEditingController();
  bool _isCustom = false;

  @override
  void initState() {
    super.initState();
    _loadLastCredentials();
  }

  Future<void> _loadLastCredentials() async {
    final prefs = PreferencesService();
    final name = await prefs.getLastWifiName();
    final pass = await prefs.getLastWifiPassword();
    if (name.isNotEmpty) _wifiNameController.text = name;
    if (pass.isNotEmpty) _wifiPasswordController.text = pass;
  }

  @override
  void dispose() {
    _wifiNameController.dispose();
    _wifiPasswordController.dispose();
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start New Session')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Make sure your phone\'s hotspot is turned on in system settings before generating the QR code. Enter the same WiFi name & password here.',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('WiFi Network Name (SSID)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _wifiNameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Sabas_Hotspot',
                  prefixIcon: Icon(Icons.wifi),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the hotspot WiFi name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('WiFi Password', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _wifiPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Minimum 8 characters',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('Session Duration', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _durationOptions.map((opt) {
                  final isSelected = opt['value'] == -1
                      ? _isCustom
                      : (!_isCustom && _selectedDuration == opt['value']);
                  return ChoiceChip(
                    label: Text(opt['label']),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        if (opt['value'] == -1) {
                          _isCustom = true;
                        } else {
                          _isCustom = false;
                          _selectedDuration = opt['value'];
                        }
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_isCustom) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Custom duration (minutes)',
                    hintText: 'e.g. 45',
                    prefixIcon: Icon(Icons.edit_calendar_outlined),
                  ),
                  validator: (value) {
                    if (!_isCustom) return null;
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a duration in minutes';
                    }
                    final n = int.tryParse(value);
                    if (n == null || n <= 0) {
                      return 'Enter a valid positive number';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _onStart,
                  icon: const Icon(Icons.wifi_tethering),
                  label: const Text('Start Session & Generate QR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onStart() {
    if (!_formKey.currentState!.validate()) return;

    int duration;
    if (_isCustom) {
      duration = int.parse(_customController.text.trim());
    } else {
      duration = _selectedDuration;
    }

    final provider = Provider.of<SessionProvider>(context, listen: false);
    provider.startSession(
      wifiName: _wifiNameController.text.trim(),
      wifiPassword: _wifiPasswordController.text.trim(),
      durationMinutes: duration,
    );

    Navigator.pop(context, true);
  }
}
