import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/downtime.dart';
import 'package:hive/hive.dart';

class StartDowntimeScreen extends StatefulWidget {
  final String machineId;
  final String tenantId;

  const StartDowntimeScreen({super.key, required this.machineId, required this.tenantId});

  @override
  State<StartDowntimeScreen> createState() => _StartDowntimeScreenState();
}

class _StartDowntimeScreenState extends State<StartDowntimeScreen> {
  String? level1;
  String? level2;
  final TextEditingController _notes = TextEditingController();
  File? _photo;
  bool _saving = false;

  final _picker = ImagePicker();
  final _uuid = const Uuid();

  final Map<String, List<String>> reasons = {
    'Mechanical': ['Bearing', 'Belt', 'Gear'],
    'Electrical': ['Sensor', 'Motor', 'Wiring'],
    'Process': ['Setup', 'Material', 'Quality'],
  };

  Future<void> _pickPhoto() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked == null) return;

    final compressed = await _compressFile(File(picked.path));
    setState(() {
      _photo = compressed;
    });
  }

  Future<File> _compressFile(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${_uuid.v4()}.jpg';
    int quality = 85;
    File out = file;
    while (true) {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
      );
      if (result == null) return file;
      out = result;
      final sizeKb = out.lengthSync() / 1024;
      if (sizeKb <= 200 || quality <= 20) break;
      quality -= 10;
    }
    return out;
  }

  Future<void> _startDowntime() async {
    if (level1 == null || level2 == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select reasons')));
      return;
    }
    setState(() => _saving = true);
    final id = _uuid.v4();
    String? photoPath;
    if (_photo != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final dest = File('${appDir.path}/downtime_photos/$id.jpg');
      await dest.parent.create(recursive: true);
      await _photo!.copy(dest.path);
      photoPath = dest.path;
    }

    final dt = Downtime(
      id: id,
      machineId: widget.machineId,
      tenantId: widget.tenantId,
      start: DateTime.now(),
      reasonLevel1: level1!,
      reasonLevel2: level2!,
      notes: _notes.text.isEmpty ? null : _notes.text,
      photoPath: photoPath,
      synced: false,
    );

    final box = await Hive.openBox<Downtime>('downtimes');
    await box.put(dt.id, dt);

    setState(() => _saving = false);
    if (!mounted) return;
    Navigator.pop(context, dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start Downtime')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reason - Level 1'),
            Wrap(
              spacing: 8,
              children: reasons.keys.map((k) {
                return ChoiceChip(
                  label: Text(k),
                  selected: level1 == k,
                  onSelected: (s) {
                    setState(() {
                      level1 = s ? k : null;
                      level2 = null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Text('Reason - Level 2'),
            if (level1 != null)
              Wrap(
                spacing: 8,
                children: reasons[level1]!.map((k) {
                  return ChoiceChip(
                    label: Text(k),
                    selected: level2 == k,
                    onSelected: (s) => setState(() => level2 = s ? k : null),
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Attach Photo'),
                ),
                const SizedBox(width: 12),
                if (_photo != null) Text('Photo ready (${(_photo!.lengthSync()/1024).toStringAsFixed(0)} KB)'),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _saving ? null : _startDowntime,
                child: _saving ? const CircularProgressIndicator() : const Text('Start Downtime'),
              ),
            )
          ],
        ),
      ),
    );
  }
}