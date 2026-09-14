import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_style.dart';
import '../providers/expense_provider.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _busy = false;

  Future<void> _exportData() async {
    setState(() => _busy = true);
    try {
      final provider = context.read<ExpenseProvider>();
      final json = await provider.exportBackup();

      final dir = await getApplicationDocumentsDirectory();
      final stamp = DateFormat('yyyyMMdd').format(DateTime.now());
      final file = File('${dir.path}/spendwise-backup-$stamp.json');
      await file.writeAsString(json);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Spendwise Backup',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup berhasil diekspor')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengekspor: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Impor Backup'),
        content: const Text(
          'Semua data saat ini akan diganti dengan isi file backup. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Impor'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final json = file.bytes != null
          ? String.fromCharCodes(file.bytes!)
          : await File(file.path!).readAsString();
      if (!mounted) return;

      await context.read<ExpenseProvider>().importBackup(json);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup berhasil diimpor')),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengimpor: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup Data')),
      body: _busy
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Cadangkan data pengeluaran untuk dipulihkan setelah instal ulang.',
                  style: AppStyle.body.copyWith(color: AppStyle.textSecondary),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _exportData,
                  icon: const Icon(Icons.upload_rounded, size: 18),
                  label: const Text('Ekspor Data'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _importData,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Impor Data'),
                ),
              ],
            ),
    );
  }
}
