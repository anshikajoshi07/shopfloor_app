import 'package:flutter/material.dart';
import '../services/reports_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _svc = ReportsService();

  Map<String, Duration> _downtimes = {};
  Map<String, double> _checklistRates = {};
  Map<String, int> _alerts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await _svc.totalDowntimePerMachine();
    final c = await _svc.checklistCompletionRates();
    final a = await _svc.alertsCountBySeverity();
    setState(() {
      _downtimes = d;
      _checklistRates = c;
      _alerts = a;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summary Reports')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Downtime per machine', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_downtimes.isEmpty)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('No downtimes recorded', style: TextStyle(color: Colors.grey)))
                  else
                    ..._downtimes.entries.map((e) => ListTile(
                          title: Text(e.key),
                          trailing: Text('${e.value.inHours}h ${e.value.inMinutes.remainder(60)}m'),
                        )),
                  const Divider(),
                  const Text('Checklist completion (%)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_checklistRates.isEmpty)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('No checklist data', style: TextStyle(color: Colors.grey)))
                  else
                    ..._checklistRates.entries.map((e) => ListTile(
                          title: Text(e.key),
                          trailing: Text('${e.value.toStringAsFixed(1)}%'),
                        )),
                  const Divider(),
                  const Text('Alerts by severity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_alerts.isEmpty)
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('No alerts', style: TextStyle(color: Colors.grey)))
                  else
                    ..._alerts.entries.map((e) => ListTile(
                          title: Text(e.key),
                          trailing: Text(e.value.toString()),
                        )),

                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final csv = await _svc.exportDowntimeCsv();
                      // Simple demo: show CSV in dialog
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(title: const Text('Downtime CSV'), content: SingleChildScrollView(child: Text(csv)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
                    },
                    child: const Text('Export Downtime CSV'),
                  )
                ],
              ),
            ),
    );
  }
}
