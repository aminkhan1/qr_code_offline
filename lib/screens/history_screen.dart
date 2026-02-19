import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/qr_item.dart';
import '../services/storage_service.dart';
import 'qr_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storage = StorageService();
  List<QRItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final items = await _storage.loadHistory();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await _storage.deleteItem(id);
    await _load();
  }

  Future<void> _shareItem(QRItem item, GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/qr_${item.id}.png');
      await file.writeAsBytes(pngBytes);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'QR Code: ${item.text}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: const TextStyle(fontFamily: 'Vazirmatn'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openDetail(QRItem item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => QRDetailScreen(item: item),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        title: const Text(
          'History',
          style: TextStyle(
            fontFamily: 'Vazirmatn',
            fontWeight: FontWeight.w900,
            color: Color(0xFF00D4FF),
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.white38,
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF16213E),
                    title: const Text(
                      'Clear All History',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        color: Colors.white,
                      ),
                    ),
                    content: const Text(
                      'Are you sure you want to delete everything?',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        color: Colors.white70,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Delete All',
                          style: TextStyle(
                            fontFamily: 'Vazirmatn',
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _storage.saveHistory([]);
                  await _load();
                }
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFF00D4FF).withOpacity(0.15),
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00D4FF)),
            )
          : _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: 80,
                    color: Colors.white12,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No QR codes yet',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      color: Colors.white38,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Generate one and save it here',
                    style: TextStyle(
                      fontFamily: 'Vazirmatn',
                      color: Colors.white24,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: const Color(0xFF00D4FF),
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                itemBuilder: (ctx, i) {
                  final item = _items[i];
                  final repaintKey = GlobalKey();
                  return _HistoryCard(
                    item: item,
                    repaintKey: repaintKey,
                    onDelete: () => _delete(item.id),
                    onShare: () => _shareItem(item, repaintKey),
                    onTap: () => _openDetail(item),
                  );
                },
              ),
            ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final QRItem item;
  final GlobalKey repaintKey;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.item,
    required this.repaintKey,
    required this.onDelete,
    required this.onShare,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy · HH:mm').format(item.createdAt);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.15)),
        ),
        child: Row(
          children: [
            // QR preview - tappable hint with glow
            Padding(
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  RepaintBoundary(
                    key: repaintKey,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: item.text,
                        version: QrVersions.auto,
                        size: 80,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF1A1A2E),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                  ),
                  // Tap hint overlay
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00D4FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fullscreen_rounded,
                        color: Color(0xFF0F0F1A),
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.text.length > 50
                          ? '${item.text.substring(0, 50)}...'
                          : item.text,
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontFamily: 'Vazirmatn',
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _SmallButton(
                          icon: Icons.share_rounded,
                          color: const Color(0xFF00D4FF),
                          onTap: onShare,
                        ),
                        const SizedBox(width: 8),
                        _SmallButton(
                          icon: Icons.delete_outline_rounded,
                          color: Colors.red,
                          onTap: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Chevron
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Colors.white24,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SmallButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
