/// Nylab - Network Connectivity Service
///
/// Monitors network connectivity status and provides offline detection.
library;

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Network status enum
enum NetworkStatus { online, offline, unknown }

/// Network connectivity service
class NetworkService {
  static NetworkService? _instance;
  static NetworkService get instance => _instance ??= NetworkService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final _statusController = StreamController<NetworkStatus>.broadcast();
  Stream<NetworkStatus> get statusStream => _statusController.stream;

  NetworkStatus _currentStatus = NetworkStatus.unknown;
  NetworkStatus get currentStatus => _currentStatus;

  bool get isOnline => _currentStatus == NetworkStatus.online;
  bool get isOffline => _currentStatus == NetworkStatus.offline;

  NetworkService._();

  /// Initialize the service and start monitoring
  Future<void> initialize() async {
    // Get initial status
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet,
    );

    final newStatus = hasConnection
        ? NetworkStatus.online
        : NetworkStatus.offline;

    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
      debugPrint('[NetworkService] Status changed: $newStatus');
    }
  }

  /// Check current connectivity
  Future<NetworkStatus> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);
    return _currentStatus;
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}

/// Global network service instance
final networkService = NetworkService.instance;
