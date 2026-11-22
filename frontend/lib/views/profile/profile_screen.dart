import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_avatar.dart';
import 'avatar_picker_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditProfileDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final nameController = TextEditingController(text: auth.user?.name ?? '');
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final currentUser = context.watch<AuthProvider>().user;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              'Ubah Profil',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    AvatarPickerSheet.show(context);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AppAvatar(
                        avatarUrl: currentUser?.avatar,
                        userName: currentUser?.name ?? 'Pengguna',
                        size: 68,
                        isAnimated: true,
                        showBorder: true,
                        showGlow: true,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    AvatarPickerSheet.show(context);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Ganti Foto / Animasi Avatar',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Nama Lengkap', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  style: GoogleFonts.outfit(fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.cardPinkLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password Baru (Kosongkan jika tidak diubah)', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: GoogleFonts.outfit(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    filled: true,
                    fillColor: AppColors.cardPinkLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Batal', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newName = nameController.text.trim();
                  final newPass = passwordController.text.trim();
                  if (newName.isEmpty) return;

                  Navigator.pop(ctx);
                  final success = await auth.updateProfile(
                    name: newName,
                    password: newPass.isEmpty ? null : newPass,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success ? 'Profil berhasil diperbarui!' : 'Gagal memperbarui profil',
                          style: GoogleFonts.outfit(),
                        ),
                        backgroundColor: success ? AppColors.primary : AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Simpan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    const shareText =
        'Yuk kelola dan catat pengeluaran harianmu lebih mudah, rapi, dan cerdas dengan Spendly! 💖\nCoba sekarang di: https://spendly.id';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.cardPinkAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.share_rounded,
                color: AppColors.primaryDark,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bagikan ke Teman',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajak teman dan keluargamu untuk mengelola pengeluaran harian dengan lebih cerdas dan teratur bersama Spendly!',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.cardPinkLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardPinkBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'https://spendly.id',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: shareText));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tautan berhasil disalin ke clipboard!',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: AppColors.primaryDark,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Salin',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF8FA3), Color(0xFFE04573)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'About Spendly',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'v1.0.0 • Smart Expense Tracker',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardPinkLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardPinkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tujuan & Fungsi Aplikasi:',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Spendly dirancang untuk membantumu mencatat, memonitor, dan mengendalikan pengeluaran harian secara cerdas, rapi, dan menyenangkan. Mengubah kebiasaan finansial jadi lebih teratur dan bebas stres!',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Fitur Utama:',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Catat pengeluaran cepat & fleksibel\n'
                    '• Visualisasi grafik pengeluaran & kategori\n'
                    '• Ringkasan & analisis laporan keuangan\n'
                    '• Keamanan data terenkripsi & sinkronisasi cloud',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              ),
              child: Text(
                'Mengerti',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Keluar Akun?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah kamu yakin ingin keluar dari aplikasi Spendly?',
          style: GoogleFonts.outfit(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Keluar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profil Saya',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // 1. Profile Avatar Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => AvatarPickerSheet.show(context),
                      child: AppAvatar(
                        avatarUrl: user?.avatar,
                        userName: user?.name ?? 'Pengguna',
                        size: 92,
                        isAnimated: true,
                        showBorder: true,
                        showGlow: true,
                        badgeWidget: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.name ?? 'Pengguna',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => AvatarPickerSheet.show(context),
                          icon: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
                          label: Text('Ganti Avatar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            elevation: 2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () => _showEditProfileDialog(context),
                          icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.primaryDark),
                          label: Text('Edit Profil', style: GoogleFonts.outfit(color: AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.cardPinkBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Settings / Info List
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardPinkBorder.withOpacity(0.6)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cardPinkLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.share_rounded, color: AppColors.primaryDark, size: 20),
                      ),
                      title: Text('Bagikan ke Teman', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('Ajak teman kelola keuangan bersama Spendly', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      onTap: () => _showShareDialog(context),
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.divider),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cardPinkLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.info_outline_rounded, color: AppColors.primaryDark, size: 20),
                      ),
                      title: Text('About this App', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('Tujuan & informasi aplikasi Spendly', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      onTap: () => _showAboutAppDialog(context),
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.divider),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.cardPinkLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.verified_outlined, color: AppColors.primaryDark, size: 20),
                      ),
                      title: Text('Versi Aplikasi', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('Spendly v1.0.0 (Fullstack)', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Logout Button (Dark Pink theme matching the app)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                  label: Text('Keluar dari Akun', style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

