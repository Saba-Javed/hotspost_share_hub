class HotspotSession {
  final int? id;
  final String wifiName;
  final String wifiPassword;
  final DateTime startTime;
  DateTime? endTime;
  final int durationMinutes; // planned duration, 0 = unlimited/custom-running
  double dataUsageMB;
  int connectedDevicesCount;
  bool isActive;

  HotspotSession({
    this.id,
    required this.wifiName,
    required this.wifiPassword,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    this.dataUsageMB = 0.0,
    this.connectedDevicesCount = 0,
    this.isActive = true,
  });

  Duration get elapsed {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wifiName': wifiName,
      'wifiPassword': wifiPassword,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'dataUsageMB': dataUsageMB,
      'connectedDevicesCount': connectedDevicesCount,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory HotspotSession.fromMap(Map<String, dynamic> map) {
    return HotspotSession(
      id: map['id'] as int?,
      wifiName: map['wifiName'] as String,
      wifiPassword: map['wifiPassword'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null
          ? DateTime.parse(map['endTime'] as String)
          : null,
      durationMinutes: map['durationMinutes'] as int,
      dataUsageMB: (map['dataUsageMB'] as num).toDouble(),
      connectedDevicesCount: map['connectedDevicesCount'] as int,
      isActive: (map['isActive'] as int) == 1,
    );
  }

  HotspotSession copyWith({
    int? id,
    String? wifiName,
    String? wifiPassword,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    double? dataUsageMB,
    int? connectedDevicesCount,
    bool? isActive,
  }) {
    return HotspotSession(
      id: id ?? this.id,
      wifiName: wifiName ?? this.wifiName,
      wifiPassword: wifiPassword ?? this.wifiPassword,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      dataUsageMB: dataUsageMB ?? this.dataUsageMB,
      connectedDevicesCount: connectedDevicesCount ?? this.connectedDevicesCount,
      isActive: isActive ?? this.isActive,
    );
  }
}

class ConnectedDevice {
  final int? id;
  final int sessionId;
  final String deviceName;
  final DateTime connectedAt;
  DateTime? disconnectedAt;
  double dataUsedMB;

  ConnectedDevice({
    this.id,
    required this.sessionId,
    required this.deviceName,
    required this.connectedAt,
    this.disconnectedAt,
    this.dataUsedMB = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'deviceName': deviceName,
      'connectedAt': connectedAt.toIso8601String(),
      'disconnectedAt': disconnectedAt?.toIso8601String(),
      'dataUsedMB': dataUsedMB,
    };
  }

  factory ConnectedDevice.fromMap(Map<String, dynamic> map) {
    return ConnectedDevice(
      id: map['id'] as int?,
      sessionId: map['sessionId'] as int,
      deviceName: map['deviceName'] as String,
      connectedAt: DateTime.parse(map['connectedAt'] as String),
      disconnectedAt: map['disconnectedAt'] != null
          ? DateTime.parse(map['disconnectedAt'] as String)
          : null,
      dataUsedMB: (map['dataUsedMB'] as num).toDouble(),
    );
  }
}
