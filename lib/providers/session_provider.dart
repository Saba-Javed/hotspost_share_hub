import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';

class SessionProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final PreferencesService _prefs = PreferencesService();

  HotspotSession? _activeSession;
  List<HotspotSession> _history = [];
  List<ConnectedDevice> _connectedDevices = [];
  Timer? _ticker;
  Timer? _simTimer;
  bool _isDarkMode = false;

  final Random _random = Random();

  HotspotSession? get activeSession => _activeSession;
  List<HotspotSession> get history => _history;
  List<ConnectedDevice> get connectedDevices => _connectedDevices;
  bool get isDarkMode => _isDarkMode;
  bool get hasActiveSession => _activeSession != null && _activeSession!.isActive;

  Duration get elapsedTime {
    if (_activeSession == null) return Duration.zero;
    return DateTime.now().difference(_activeSession!.startTime);
  }

  Duration get remainingTime {
    if (_activeSession == null || _activeSession!.durationMinutes == 0) {
      return Duration.zero;
    }
    final total = Duration(minutes: _activeSession!.durationMinutes);
    final remaining = total - elapsedTime;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isUnlimited => _activeSession?.durationMinutes == 0;

  Future<void> initialize() async {
    _isDarkMode = await _prefs.getDarkMode();
    _activeSession = await _db.getActiveSession();
    _history = await _db.getCompletedSessions();

    if (_activeSession != null) {
      _connectedDevices = await _db.getDevicesForSession(_activeSession!.id!);
      _startTicker();
      _startSimulation();

      // Auto-end if duration already passed
      if (!isUnlimited && remainingTime == Duration.zero) {
        await endSession();
      }
    }
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await _prefs.setDarkMode(value);
    notifyListeners();
  }

  // ---------------- SESSION CONTROL ----------------

  Future<void> startSession({
    required String wifiName,
    required String wifiPassword,
    required int durationMinutes,
  }) async {
    if (hasActiveSession) return;

    final session = HotspotSession(
      wifiName: wifiName,
      wifiPassword: wifiPassword,
      startTime: DateTime.now(),
      durationMinutes: durationMinutes,
      isActive: true,
    );

    final id = await _db.insertSession(session);
    _activeSession = session.copyWith(id: id);
    _connectedDevices = [];

    await _prefs.saveLastCredentials(wifiName, wifiPassword);

    _startTicker();
    _startSimulation();
    notifyListeners();
  }

  Future<void> endSession() async {
    if (_activeSession == null) return;

    _ticker?.cancel();
    _simTimer?.cancel();

    final ended = _activeSession!.copyWith(
      isActive: false,
      endTime: DateTime.now(),
    );

    await _db.updateSession(ended);

    // Close out any still-connected devices
    for (final device in _connectedDevices) {
      if (device.disconnectedAt == null) {
        final updated = ConnectedDevice(
          id: device.id,
          sessionId: device.sessionId,
          deviceName: device.deviceName,
          connectedAt: device.connectedAt,
          disconnectedAt: DateTime.now(),
          dataUsedMB: device.dataUsedMB,
        );
        await _db.updateDevice(updated);
      }
    }

    _activeSession = null;
    _connectedDevices = [];
    _history = await _db.getCompletedSessions();
    notifyListeners();
  }

  // ---------------- TIMERS ----------------

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeSession == null) {
        timer.cancel();
        return;
      }
      // Auto-end when duration reaches zero
      if (!isUnlimited && remainingTime == Duration.zero) {
        endSession();
        return;
      }
      notifyListeners();
    });
  }

  // Simulates connected devices and data usage growth, since real
  // hotspot client lists require system-level access not available
  // to standard Android apps without a VPN service.
  void _startSimulation() {
    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(seconds: 8), (timer) async {
      if (_activeSession == null) {
        timer.cancel();
        return;
      }

      // Randomly simulate a new device connecting (max 5)
      if (_connectedDevices.where((d) => d.disconnectedAt == null).length < 5 &&
          _random.nextDouble() < 0.35) {
        final deviceNames = [
          'Samsung Galaxy A14',
          'Redmi Note 12',
          'iPhone 13',
          'Infinix Hot 30',
          'Vivo Y22',
          'Oppo A78',
          'Realme C55',
          'Tecno Spark 10',
        ];
        final name = deviceNames[_random.nextInt(deviceNames.length)];
        final device = ConnectedDevice(
          sessionId: _activeSession!.id!,
          deviceName: name,
          connectedAt: DateTime.now(),
          dataUsedMB: 0,
        );
        final id = await _db.insertDevice(device);
        _connectedDevices.insert(
          0,
          ConnectedDevice(
            id: id,
            sessionId: device.sessionId,
            deviceName: device.deviceName,
            connectedAt: device.connectedAt,
            dataUsedMB: 0,
          ),
        );
      }

      // Increase data usage for active devices and total session
      double increment = 0;
      for (int i = 0; i < _connectedDevices.length; i++) {
        final d = _connectedDevices[i];
        if (d.disconnectedAt == null) {
          final usageDelta = _random.nextDouble() * 4; // up to 4 MB per tick
          final updated = ConnectedDevice(
            id: d.id,
            sessionId: d.sessionId,
            deviceName: d.deviceName,
            connectedAt: d.connectedAt,
            disconnectedAt: d.disconnectedAt,
            dataUsedMB: d.dataUsedMB + usageDelta,
          );
          _connectedDevices[i] = updated;
          await _db.updateDevice(updated);
          increment += usageDelta;
        }
      }

      if (increment > 0) {
        _activeSession = _activeSession!.copyWith(
          dataUsageMB: _activeSession!.dataUsageMB + increment,
          connectedDevicesCount: _connectedDevices.length,
        );
        await _db.updateSession(_activeSession!);
      }

      notifyListeners();
    });
  }

  // ---------------- HISTORY / ANALYTICS ----------------

  Future<void> refreshHistory() async {
    _history = await _db.getCompletedSessions();
    notifyListeners();
  }

  Future<List<ConnectedDevice>> getDevicesForSession(int sessionId) async {
    return _db.getDevicesForSession(sessionId);
  }

  Future<double> getTotalUsage() => _db.getTotalUsage();

  Future<double> getTodayUsage() {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return _db.getUsageSince(today);
  }

  Future<double> getWeekUsage() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _db.getUsageSince(weekAgo);
  }

  Future<Map<String, double>> getDailyUsage(int days) => _db.getDailyUsage(days);

  Future<void> deleteSession(int id) async {
    await _db.deleteSession(id);
    await refreshHistory();
  }

  Future<void> clearHistory() async {
    await _db.clearAllHistory();
    _history = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _simTimer?.cancel();
    super.dispose();
  }
}
