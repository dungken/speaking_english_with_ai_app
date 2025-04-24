import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Abstract class that defines network connectivity check
abstract class NetworkInfo {
  /// Check if the device is connected to the internet
  Future<bool> get isConnected;
}

/// Implementation of [NetworkInfo] that uses the internet_connection_checker package
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async {
    final hasConnection = await connectionChecker.hasConnection;
    print('DEBUG NETWORK: isConnected check result: $hasConnection');
    return hasConnection;
  }
}
