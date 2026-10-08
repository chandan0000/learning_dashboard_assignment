import 'dart:async';
import 'dart:io';

abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

class DnsNetworkInfo implements NetworkInfo {
  const DnsNetworkInfo({
    this.host = 'example.com',
    this.timeout = const Duration(seconds: 3),
  });

  final String host;
  final Duration timeout;

  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup(host).timeout(timeout);
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }
}
