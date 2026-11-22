import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/animated_avatar_data.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_avatar.dart';

class AvatarPickerSheet extends StatefulWidget {
  const AvatarPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AvatarPickerSheet(),
    );
  }

  @override
  State<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<AvatarPickerSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  String? _selectedAvatarKey;
  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  bool _isSaving = false;
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final currentAvatar = context.read<AuthProvider>().user?.avatar;
    _selectedAvatarKey = currentAvatar;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 88,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _pickedImage = file;
          _pickedImageBytes = bytes;
          _selectedAvatarKey = null; // Clear preset selection when custom image picked
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e', style: GoogleFonts.outfit()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveAvatar() async {
    final auth = context.read<AuthProvider>();
    setState(() => _isSaving = true);

    bool success = false;

    if (_tabController.index == 1 && _pickedImageBytes != null) {
      // Upload custom photo
      final filename = _pickedImage?.name ?? 'avatar.jpg';
      success = await auth.uploadAvatar(_pickedImageBytes!, filename);
    } else if (_selectedAvatarKey != null) {
      // Save preset animated avatar
      success = await auth.setAvatarPreset(_selectedAvatarKey!);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Foto profil berhasil diperbarui!',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.errorMessage ?? 'Gagal memperbarui avatar',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeAvatar() async {
    final auth = context.read<AuthProvider>();
    setState(() => _isSaving = true);

    final success = await auth.removeAvatar();
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Avatar direset ke inisial nama default',
            style: GoogleFonts.outfit(),
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final userName = user?.name ?? 'Pengguna';
    final hasCurrentAvatar = user?.avatar != null && user!.avatar!.isNotEmpty;

    // Filter animated avatar items
    final categories = ['Semua', 'Populer', 'Hewan Lucu', 'Karakter & AI'];
    List<AnimatedAvatarItem> filteredItems = AnimatedAvatarData.items;

    if (_selectedCategory == 'Populer') {
      filteredItems = AnimatedAvatarData.items.where((i) => i.tag.contains('POPULER') || i.tag.contains('SULTAN')).toList();
    } else if (_selectedCategory == 'Hewan Lucu') {
      filteredItems = AnimatedAvatarData.items.where((i) => ['Kucing Imut', 'Beruang Madu', 'Kelinci Ceria', 'Anak Ayam', 'Celengan Emas'].contains(i.category)).toList();
    } else if (_selectedCategory == 'Karakter & AI') {
      filteredItems = AnimatedAvatarData.items.where((i) => ['Robot AI', 'Magical', 'Astronot', 'Princess', 'Gaming', 'Rubah Cerdas'].contains(i.category)).toList();
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Foto Profil',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Pilih avatar animasi keren atau upload foto sendiri',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Live Preview Area
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.cardPinkLight,
                  AppColors.cardPinkAccent.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.cardPinkBorder),
            ),
            child: Row(
              children: [
                // Live Avatar Preview
                if (_tabController.index == 1 && _pickedImageBytes != null)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.memory(_pickedImageBytes!, fit: BoxFit.cover),
                    ),
                  )
                else
                  AppAvatar(
                    avatarUrl: _selectedAvatarKey ?? user?.avatar,
                    userName: userName,
                    size: 72,
                    isAnimated: true,
                    showGlow: true,
                    showBorder: true,
                    borderColor: Colors.white,
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'LIVE PREVIEW',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (_selectedAvatarKey != null && _selectedAvatarKey!.startsWith('anim:'))
                            Text(
                              'Animasi Aktif',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryDark,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPreviewLabel(),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _getPreviewSubtitle(),
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Tab Navigation Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.cardPinkLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (index) => setState(() {}),
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardShadow.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primaryDark,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Avatar Animasi'),
                    ],
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Upload Foto'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Animated Avatars Grid
                Column(
                  children: [
                    // Category Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                cat,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) => setState(() => _selectedCategory = cat),
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.cardPinkLight,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                              showCheckmark: false,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Grid of Animated Avatars
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.82,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isSelected = _selectedAvatarKey == item.id;

                          return InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setState(() {
                                _selectedAvatarKey = item.id;
                                _pickedImage = null;
                                _pickedImageBytes = null;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.cardPinkLight : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.cardPinkBorder,
                                  width: isSelected ? 2.5 : 1,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  else
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Selected Badge Indicator
                                  if (isSelected)
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: item.auraColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item.tag.split(' ').first,
                                        style: GoogleFonts.outfit(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.bold,
                                          color: item.auraColor,
                                        ),
                                      ),
                                    ),
                                  const Spacer(),
                                  AppAvatar(
                                    avatarUrl: item.id,
                                    userName: item.name,
                                    size: 52,
                                    isAnimated: true,
                                    showBorder: false,
                                  ),
                                  const Spacer(),
                                  Text(
                                    item.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.category,
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // TAB 2: Upload Custom Photo
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      if (_pickedImageBytes != null) ...[
                        // Preview picked image
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.25),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.memory(_pickedImageBytes!, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _pickedImage?.name ?? 'Foto Terpilih',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                              label: Text('Ganti Foto', style: GoogleFonts.outfit(color: AppColors.primary, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.cardPinkBorder),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () => setState(() {
                                _pickedImage = null;
                                _pickedImageBytes = null;
                              }),
                              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                              label: Text('Hapus', style: GoogleFonts.outfit(color: AppColors.error, fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.cardPinkBorder),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Upload placeholder & picker options
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppColors.cardPinkLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.cardPinkBorder, style: BorderStyle.solid),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_a_photo_rounded,
                                  size: 32,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Pilih Foto dari Perangkat',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Format JPG, PNG, GIF, WebP (Maks. 5 MB).\nFoto akan disimpan di server Spendly.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _pickImage(ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                                    label: Text('Buka Galeri / File', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.cardPinkBorder.withOpacity(0.5))),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                if (hasCurrentAvatar)
                  TextButton.icon(
                    onPressed: _isSaving ? null : _removeAvatar,
                    icon: const Icon(Icons.restart_alt_rounded, size: 18, color: AppColors.textSecondary),
                    label: Text(
                      'Reset Inisial',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: (_isSaving || (_tabController.index == 1 && _pickedImageBytes == null && _selectedAvatarKey == null))
                      ? null
                      : _saveAvatar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 3,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Terapkan Avatar',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPreviewLabel() {
    if (_tabController.index == 1 && _pickedImageBytes != null) {
      return 'Foto Kustom Pilihanmu';
    }
    final item = AnimatedAvatarData.findById(_selectedAvatarKey);
    if (item != null) {
      return item.name;
    }
    return 'Inisial Nama Standar';
  }

  String _getPreviewSubtitle() {
    if (_tabController.index == 1 && _pickedImageBytes != null) {
      return 'Siap disimpan dan dipasang ke profilmu';
    }
    final item = AnimatedAvatarData.findById(_selectedAvatarKey);
    if (item != null) {
      return item.subtitle;
    }
    return 'Menampilkan inisial huruf dari namamu';
  }
}
