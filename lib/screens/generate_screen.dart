import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../models/qr_item.dart';
import '../services/storage_service.dart';

class GenerateScreen extends StatefulWidget {
  const GenerateScreen({super.key});

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _storage = StorageService();
  final _repaintKey = GlobalKey();
  String _qrData = '';
  bool _saved = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _generate() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _qrData = text;
      _saved = false;
    });
    _animController.reset();
    _animController.forward();
  }

  Future<void> _saveToHistory() async {
    if (_qrData.isEmpty) return;
    final item = QRItem(
      id: const Uuid().v4(),
      text: _qrData,
      createdAt: DateTime.now(),
    );
    await _storage.addItem(item);
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Saved to history!',
            style: TextStyle(fontFamily: 'Vazirmatn'),
          ),
          backgroundColor: const Color(0xFF7C3AED),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _share() async {
    if (_qrData.isEmpty) return;
    try {
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/qr_code.png');
      await file.writeAsBytes(pngBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'QR Code: $_qrData');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Share error: $e',
              style: const TextStyle(fontFamily: 'Vazirmatn'),
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F1A),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'QR Generator',
                style: TextStyle(
                  fontFamily: 'Vazirmatn',
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF00D4FF),
                  fontSize: 22,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A1A3E), Color(0xFF0F0F1A)],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF00D4FF).withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: 4,
                    style: const TextStyle(
                      fontFamily: 'Vazirmatn',
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter text or URL...',
                      hintStyle: TextStyle(
                        fontFamily: 'Vazirmatn',
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _generate,
                    icon: const Icon(Icons.qr_code_2_rounded),
                    label: const Text(
                      'Generate QR Code',
                      style: TextStyle(
                        fontFamily: 'Vazirmatn',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D4FF),
                      foregroundColor: const Color(0xFF0F0F1A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFF00D4FF).withOpacity(0.4),
                    ),
                  ),
                ),
                if (_qrData.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Center(
                      child: Column(
                        children: [
                          RepaintBoundary(
                            key: _repaintKey,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF7C3AED,
                                    ).withOpacity(0.4),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: QrImageView(
                                data: _qrData,
                                version: QrVersions.auto,
                                size: 220,
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
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16213E),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF00D4FF).withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              _qrData.length > 40
                                  ? '${_qrData.substring(0, 40)}...'
                                  : _qrData,
                              style: const TextStyle(
                                fontFamily: 'Vazirmatn',
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ActionButton(
                                icon: _saved
                                    ? Icons.check_circle_rounded
                                    : Icons.save_rounded,
                                label: _saved ? 'Saved' : 'Save',
                                color: _saved
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF7C3AED),
                                onTap: _saved ? null : _saveToHistory,
                              ),
                              const SizedBox(width: 12),
                              _ActionButton(
                                icon: Icons.share_rounded,
                                label: 'Share',
                                color: const Color(0xFF00D4FF),
                                onTap: _share,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(onTap == null ? 0.1 : 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Vazirmatn',
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
