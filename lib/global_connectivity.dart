import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/services/sync_service.dart';

class ConnectivityWatcher {
  final SyncService syncService;

  ConnectivityWatcher(this.syncService);

  void start() {
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        print('🌐 Conectado — sincronizando...');
        syncService.syncAll();
      }
    });
  }
}
