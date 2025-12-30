import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/maintenance_checklist.dart';

class MaintenanceChecklistScreen extends StatefulWidget {
  final String machineId;
  const MaintenanceChecklistScreen({super.key, required this.machineId});

  @override
  State<MaintenanceChecklistScreen> createState() => _MaintenanceChecklistScreenState();
}

class _MaintenanceChecklistScreenState extends State<MaintenanceChecklistScreen> {
  late Box<MaintenanceChecklist> box;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    box = await Hive.openBox<MaintenanceChecklist>('checklists');
    if (mounted) setState(() {});
  }

  List<MaintenanceChecklist> _itemsForMachine() {
    if (!Hive.isBoxOpen('checklists')) return [];
    final all = box.values.toList();
    return all.where((c) => c.machineId == widget.machineId).toList();
  }

  Future<void> _addItem() async {
    final titleCtl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Add checklist item'),
        content: TextField(controller: titleCtl, decoration: const InputDecoration(labelText: 'Title')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok != true) return;
    if (titleCtl.text.trim().isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = MaintenanceChecklist(id: id, machineId: widget.machineId, title: titleCtl.text.trim());
    await box.put(item.id, item);
    if (mounted) setState(() {});
  }

  Future<void> _toggleDone(MaintenanceChecklist item) async {
    item.done = !item.done;
    await item.save();
    if (mounted) setState(() {});
  }

  Future<void> _editNote(MaintenanceChecklist item) async {
    final ctl = TextEditingController(text: item.note ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Notes'),
        content: TextField(controller: ctl, maxLines: 4, decoration: const InputDecoration(labelText: 'Note')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    item.note = ctl.text.trim().isEmpty ? null : ctl.text.trim();
    await item.save();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('checklists')) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final items = _itemsForMachine();

    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance Checklist')),
      body: items.isEmpty
          ? const Center(child: Text('No checklist items for this machine'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final i = items[index];
                return Card(
                  child: ListTile(
                    leading: Checkbox(value: i.done, onChanged: (_) => _toggleDone(i)),
                    title: Text(i.title, style: TextStyle(decoration: i.done ? TextDecoration.lineThrough : null)),
                    subtitle: i.note != null ? Text(i.note!) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (i.synced)
                          const Icon(Icons.check_circle, color: Colors.green)
                        else
                          const Icon(Icons.sync, color: Colors.orange),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.note), onPressed: () => _editNote(i)),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        tooltip: 'Add checklist item',
        child: const Icon(Icons.add),
      ),
    );
  }
}