import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';
import '../models/downtime.dart';

/// Simple sync service that watches connectivity and uploads queued downtimes.
class SyncService {
  SyncService._private();
  static final SyncService _instance = SyncService._private();
  factory SyncService() => _instance;

  StreamSubscription<dynamic>? _sub;
  bool _running = false;

  /// Start listening for connectivity changes.
  void start() {
    if (_running) return;
    _running = true;
    // ignore: unrelated_type_equality_checks, unnecessary_type_check
    _sub = Connectivity().onConnectivityChanged.listen((result) {
      if (result is ConnectivityResult) {
        if (result == ConnectivityResult.none) return; // ignore: unrelated_type_equality_checks
        _syncQueuedDowntimes();
      } else if (result is Iterable) { // ignore: unnecessary_type_check
        // some platforms might emit a list; check if all are none
        if (result.every((r) => r == ConnectivityResult.none)) return;
        _syncQueuedDowntimes();
      }
    });
    // Try an initial sync
    _syncQueuedDowntimes();
  }

  void stop() {
    _sub?.cancel();
    _running = false;
  }

  /// Manually trigger a sync. Returns the completion time when finished.
  Future<DateTime> manualSync() async {
    await _syncQueuedDowntimes();
    return DateTime.now();
  }

  Future<void> _syncQueuedDowntimes() async {
    if (!Hive.isBoxOpen('downtimes')) return;
    final box = Hive.box<Downtime>('downtimes');
    final queued = box.values.where((d) => d.synced == false).toList();
    if (queued.isEmpty) return;

    for (final dt in queued) {
      try {
        // Simulate upload delay
        await Future.delayed(const Duration(milliseconds: 400));
        // In a real app you'd upload photo and payload here and verify server response
        dt.synced = true;
        await dt.save();
      } catch (e) {
        // Keep entry unsynced; in a real app you'd log and retry later
      }
    }

    // Also sync maintenance checklist items
    if (Hive.isBoxOpen('checklists')) {
      final box = Hive.box('checklists');
      final queuedChecks = box.values.where((c) => (c as dynamic).synced == false).toList();
      for (final c in queuedChecks) {
        try {
          await Future.delayed(const Duration(milliseconds: 200));
          // Simulate server acknowledgement
          (c as dynamic).synced = true;
          await (c as dynamic).save();
        } catch (e) {
          // ignore and retry later
        }
      }
    }
  }
}
