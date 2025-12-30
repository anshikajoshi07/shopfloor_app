import 'package:flutter/material.dart';
import '../models/machine.dart';
import 'machine_detail_screen.dart';

class MachineListScreen extends StatefulWidget {
  const MachineListScreen({super.key});

  @override
  State<MachineListScreen> createState() => _MachineListScreenState();
}

class _MachineListScreenState extends State<MachineListScreen> {
  final List<Machine> machines = [
    Machine(id: 'M-101', name: 'Cutter 1', type: 'cutter', status: 'RUN'),
    Machine(id: 'M-102', name: 'Roller A', type: 'roller', status: 'IDLE'),
    Machine(id: 'M-103', name: 'Packing West', type: 'packer', status: 'OFF'),
  ];

  String _query = '';

  List<Machine> get _filtered => _query.trim().isEmpty
      ? machines
      : machines.where((m) => (m.name + ' ' + m.id + ' ' + m.type).toLowerCase().contains(_query.toLowerCase())).toList();

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
      appBar: AppBar(title: const Text('Machine Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              key: const Key('machine-search-field'),
              decoration: InputDecoration(
                hintText: 'Search machines by name, id or type',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _query = ''),
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text('No machines match your search'))
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final m = _filtered[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _statusColor(m.status).withOpacity(0.12),
                              child: Icon(_iconForType(m.type), color: _statusColor(m.status)),
                            ),
                            title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${m.type} • ${m.id}'),
                            trailing: Chip(
                              label: Text(m.status, style: const TextStyle(color: Colors.white)),
                              backgroundColor: _statusColor(m.status),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MachineDetailScreen(machine: m),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
