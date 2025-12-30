import 'package:flutter/material.dart';
import '../models/machine.dart';
import 'start_downtime_screen.dart';
import 'downtime_list_screen.dart';
import 'maintenance_checklist_screen.dart';

class MachineDetailScreen extends StatelessWidget {
  final Machine machine;
  const MachineDetailScreen({super.key, required this.machine});

  Color _statusColor(String status) {
    if (status == 'RUN') return Colors.green;
    if (status == 'IDLE') return Colors.orange;
    return Colors.red;
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'cutter':
        return Icons.content_cut;
      case 'roller':
        return Icons.settings;
      case 'packer':
        return Icons.inventory_2;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(machine.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _statusColor(machine.status).withOpacity(0.12),
                      child: Icon(_iconForType(machine.type), color: _statusColor(machine.status)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(machine.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('ID: ${machine.id} • Type: ${machine.type}'),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(machine.status, style: const TextStyle(color: Colors.white)),
                      backgroundColor: _statusColor(machine.status),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Navigate to StartDowntimeScreen
                    final dt = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StartDowntimeScreen(machineId: machine.id, tenantId: 'tenant_001'),
                      ),
                    );
                    if (!context.mounted) return;
                    if (dt != null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downtime started')));
                    }
                  },
                  child: const Text('Start Downtime'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    // Open list of downtimes for this machine
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DowntimeListScreen(machineId: machine.id)),
                    );
                  },
                  child: const Text('View Downtimes'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    // Open maintenance checklist for this machine
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MaintenanceChecklistScreen(machineId: machine.id)),
                    );
                  },
                  child: const Text('Maintenance Checklist'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
