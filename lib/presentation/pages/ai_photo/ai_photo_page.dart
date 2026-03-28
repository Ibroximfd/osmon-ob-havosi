import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../data/datasources/ai_photo_service.dart';

class AIPhotoPage extends StatefulWidget {
  const AIPhotoPage({super.key});

  @override
  State<AIPhotoPage> createState() => _AIPhotoPageState();
}

class _AIPhotoPageState extends State<AIPhotoPage>
    with SingleTickerProviderStateMixin {
  final _picker = ImagePicker();
  final _service = AiPhotoService();
  final _promptCtrl = TextEditingController();

  File? _imageFile;
  Uint8List? _resultBytes;
  String? _analysisText;
  bool _isEditing = false;
  bool _isAnalyzing = false;
  String _activeTab = 'analyze'; // 'analyze' | 'edit'

  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked == null) return;
    setState(() {
      _imageFile = File(picked.path);
      _resultBytes = null;
      _analysisText = null;
    });
  }

  void _showPickerSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.camera,
                    color: Color(0xFF1565C0),
                  ),
                ),
                title: const Text(
                  'Kamera',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Yangi rasm olish'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF29B6F6).withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.image,
                    color: Color(0xFF29B6F6),
                  ),
                ),
                title: const Text(
                  'Galereya',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Rasmlar kutubxonasidan tanlash'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    if (_resultBytes == null) return;
    try {
      await Gal.putImageBytes(_resultBytes!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rasm galereyaga saqlandi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rasmni saqlab bo\'lmadi!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;
    setState(() {
      _isAnalyzing = true;
      _analysisText = null;
    });
    final result = await _service.analyzeImage(imageFile: _imageFile!);
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _analysisText =
            result ?? "Rasmni tahlil qilib bo'lmadi. Qayta urinib ko'ring.";
      });
    }
  }

  Future<void> _editImage() async {
    if (_imageFile == null || _promptCtrl.text.trim().isEmpty) return;
    setState(() {
      _isEditing = true;
      _resultBytes = null;
    });
    final bytes = await _service.editImage(
      imageFile: _imageFile!,
      prompt: _promptCtrl.text.trim(),
    );
    if (mounted) {
      setState(() {
        _isEditing = false;
        _resultBytes = bytes;
      });
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Rasm tahrirlash muvaffaqiyatsiz. Promtni o\'zgartiring.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isLoading = _isEditing || _isAnalyzing;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  const Text(
                    'AI Foto',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    LucideIcons.sparkles,
                    color: Color(0xFFFACC15),
                    size: 20,
                  ),
                  const Spacer(),
                  // Reset button
                  if (_imageFile != null)
                    IconButton(
                      icon: const Icon(
                        LucideIcons.trash2,
                        size: 20,
                        color: Colors.red,
                      ),
                      onPressed: () => setState(() {
                        _imageFile = null;
                        _resultBytes = null;
                        _analysisText = null;
                        _promptCtrl.clear();
                      }),
                      tooltip: 'Tozalash',
                    ),
                ],
              ),
            ),

            // ── Tab Selector ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.black12,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _TabBtn(
                      label: 'Tahlil',
                      icon: LucideIcons.eye,
                      isActive: _activeTab == 'analyze',
                      onTap: () => setState(() => _activeTab = 'analyze'),
                    ),
                    _TabBtn(
                      label: 'Tahrirlash',
                      icon: LucideIcons.wand2,
                      isActive: _activeTab == 'edit',
                      onTap: () => setState(() => _activeTab = 'edit'),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content ───────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      _activeTab == 'analyze'
                          ? "Rasmni yuklang — AI ob-havo sharoitlarini, haroratni va muhit tavsifini o'zbek tilida aytadi."
                          : "Rasmni yuklang va amr yozing — AI rasmni qayta tahrirlaydi.",
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Image area ──────────────────────────────────────
                    GestureDetector(
                      onTap: isLoading ? null : _showPickerSheet,
                      child: Container(
                        width: double.infinity,
                        height: 260,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withAlpha(8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _imageFile != null
                                ? const Color(0xFF29B6F6)
                                : (isDark ? Colors.white24 : Colors.black26),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: _imageFile != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(_imageFile!, fit: BoxFit.cover),
                                    // Change photo overlay
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withAlpha(160),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              LucideIcons.refreshCw,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'O\'zgartirish',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF29B6F6,
                                        ).withAlpha(20),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        LucideIcons.imagePlus,
                                        size: 36,
                                        color: Color(0xFF29B6F6),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'Rasm yuklash',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Kamera yoki galereya',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black45,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── ANALYZE TAB ──────────────────────────────────────
                    if (_activeTab == 'analyze') ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_imageFile == null || isLoading)
                              ? null
                              : _analyzeImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            disabledBackgroundColor: const Color(
                              0xFF1565C0,
                            ).withAlpha(100),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isAnalyzing
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Tahlil qilinmoqda...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.eye, color: Colors.white),
                                    SizedBox(width: 10),
                                    Text(
                                      'Rasmni tahlil qilish',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      if (_analysisText != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withAlpha(10)
                                : const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF29B6F6).withAlpha(100),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    LucideIcons.sparkles,
                                    color: Color(0xFF29B6F6),
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'AI Tahlil natijasi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF29B6F6),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _analysisText!,
                                style: TextStyle(
                                  height: 1.6,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

                    // ── EDIT TAB ────────────────────────────────────────
                    if (_activeTab == 'edit') ...[
                      const Text(
                        "Nimani o'zgartirmoqchisiz?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                        ),
                        child: TextField(
                          controller: _promptCtrl,
                          enabled: !isLoading,
                          maxLines: 4,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText:
                                "Masalan: Osmonni quyoshli qil, orqa fonni qishki manzaraga almashtir...",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),

                      // Quick prompts
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            [
                                  "Qish manzarasi qil",
                                  "Quyoshli havo qil",
                                  "Yomg'ir qo'sh",
                                  "Qor qo'sh",
                                  "Tuman qo'sh",
                                  "Kechki ko'rinish qil",
                                ]
                                .map(
                                  (hint) => GestureDetector(
                                    onTap: () {
                                      _promptCtrl.text = hint;
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white10
                                            : Colors.black.withAlpha(8),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white12
                                              : Colors.black12,
                                        ),
                                      ),
                                      child: Text(
                                        hint,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              (_imageFile == null ||
                                  _promptCtrl.text.trim().isEmpty ||
                                  isLoading)
                              ? null
                              : _editImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            disabledBackgroundColor: const Color(
                              0xFF1565C0,
                            ).withAlpha(100),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isEditing
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Tahrirlanmoqda...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.wand2,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Rasmni tahrirlash',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      // Result image
                      if (_resultBytes != null) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Natija:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.memory(
                            _resultBytes!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '✅ Rasm muvaffaqiyatli tahrirlandi',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _saveImage,
                            icon: const Icon(LucideIcons.download, size: 18),
                            label: const Text('Galereyaga saqlash'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabBtn({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1565C0) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
