 import 'dart:convert';

import 'package:hive/hive.dart';
import '../models/downtime.dart';
import '../models/maintenance_checklist.dart';
import '../models/alert_item.dart';

/// Provides aggregated metrics for Summary Reports.
class ReportsService {
  ReportsService._private();
  static final ReportsService _instance = ReportsService._private();
  factory ReportsService() => _instance;

  Future<Map<String, Duration>> totalDowntimePerMachine() async {
    try {
      final box = await Hive.openBox<Downtime>('downtimes');
      final Map<String, Duration> totals = {};
      for (final d in box.values) {
        if (d.end == null) continue; // skip active
        final dur = d.end!.difference(d.start);
        totals[d.machineId] = (totals[d.machineId] ?? Duration.zero) + dur;
      }
      return totals;
    } catch (e) {
      // Defensive: if Hive isn't ready or some error occurs, return empty results
      // and avoid crashing the UI.
      // ignore: avoid_print
      print('ReportsService.totalDowntimePerMachine error: $e');
      return {};
    }
  }

  Future<Map<String, double>> checklistCompletionRates() async {
    try {
      final box = await Hive.openBox<MaintenanceChecklist>('checklists');
      final Map<String, List<MaintenanceChecklist>> perMachine = {};
      for (final c in box.values) {
        perMachine.putIfAbsent(c.machineId, () => []).add(c);
      }
      final Map<String, double> rates = {};
      perMachine.forEach((machine, items) {
        final total = items.length;
        if (total == 0) {
          rates[machine] = 0.0;
        } else {
          final done = items.where((e) => e.done).length;
          rates[machine] = (done / total) * 100.0;
        }
      });
      return rates;
    } catch (e) {
      // ignore: avoid_print
      print('ReportsService.checklistCompletionRates error: $e');
      return {};
    }
  }

  Future<Map<String, int>> alertsCountBySeverity() async {
    try {
      final box = await Hive.openBox<AlertItem>('alerts');
      final Map<String, int> counts = {};
      for (final a in box.values) {
        final level = a.level ?? 'UNKNOWN';
        counts[level] = (counts[level] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      // ignore: avoid_print
      print('ReportsService.alertsCountBySeverity error: $e');
      return {};
    }
  }

  /// Export a CSV with downtime per machine and totals.
  Future<String> exportDowntimeCsv() async {
    final totals = await totalDowntimePerMachine();
    final sb = StringBuffer();
    String escape(String v) {
      if (v.contains(',') || v.contains('\n') || v.contains('"')) {
        final escaped = v.replaceAll('"', '""');
        return '"$escaped"';
      }
      return v;
    }

    sb.writeln('MachineId,TotalDowntimeSeconds');
    for (final entry in totals.entries) {
      sb.writeln('${escape(entry.key)},${entry.value.inSeconds}');
    }
    return sb.toString();
  }
}
