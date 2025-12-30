import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/downtime.dart';

class DowntimeListScreen extends StatefulWidget {
  final String machineId;
  const DowntimeListScreen({super.key, required this.machineId});

  @override
  State<DowntimeListScreen> createState() => _DowntimeListScreenState();
}

class _DowntimeListScreenState extends State<DowntimeListScreen> {
  late Box<Downtime> box;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    box = await Hive.openBox<Downtime>('downtimes');
    if (mounted) setState(() {});
  }

  List<Downtime> _downtimesForMachine() {
    if (!Hive.isBoxOpen('downtimes')) return [];
    final all = box.values.toList();
    all.sort((a, b) => b.start.compareTo(a.start));
    return all.where((d) => d.machineId == widget.machineId).toList();
  }

  Future<void> _endDowntime(Downtime dt) async {
    dt.end = DateTime.now();
    await dt.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downtime ended')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('downtimes')) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final entries = _downtimesForMachine();

    return Scaffold(
      appBar: AppBar(title: const Text('Downtimes')),
      body: entries.isEmpty
          ? const Center(child: Text('No downtimes recorded for this machine'))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final d = entries[index];
                final active = d.end == null;
                return Card(
                  child: ListTile(
                    leading: d.photoPath != null
                        ? Image.file(File(d.photoPath!), width: 56, height: 56, fit: BoxFit.cover)
                        : const Icon(Icons.build),
                    title: Text('${d.reasonLevel1} / ${d.reasonLevel2}'),
                    subtitle: Text('Start: ${d.start.toLocal()}${d.end != null ? '\nEnd: ${d.end!.toLocal()}' : ''}'),
                    isThreeLine: d.end != null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (d.synced)
                          const Icon(Icons.check_circle, color: Colors.green)
                        else
                          const Icon(Icons.sync, color: Colors.orange),
                        const SizedBox(width: 8),
                        active
                            ? ElevatedButton(
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('End Downtime'),
                                      content: const Text('Do you want to end this downtime now?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('End')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await _endDowntime(d);
                                  }
                                },
                                child: const Text('End'))
                            : const Text('Closed'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}