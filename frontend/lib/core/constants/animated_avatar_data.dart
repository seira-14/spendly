import 'package:flutter/material.dart';

enum AvatarAnimationType {
  bounce,     // Gentle vertical floating/bouncing
  pulse,      // Gentle scale breathing pulse
  sparkle,    // Shimmering glow / star sparkle
  wiggle,     // Cute rotation tilt sway
  heartbeat,  // Rhythm heartbeat thump
  float,      // Smooth 2D diagonal floating
}

class AnimatedAvatarItem {
  final String id;
  final String name;
  final String category;
  final String emoji;
  final String tag;
  final List<Color> gradientColors;
  final Color auraColor;
  final AvatarAnimationType animationType;
  final String subtitle;
  final String? networkUrl; // Optional external animated gif / illustration

  const AnimatedAvatarItem({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.tag,
    required this.gradientColors,
    required this.auraColor,
    required this.animationType,
    required this.subtitle,
    this.networkUrl,
  });
}

class AnimatedAvatarData {
  static const List<AnimatedAvatarItem> items = [
    AnimatedAvatarItem(
      id: 'anim:neko_sparkle',
      name: 'Neko Sparkle',
      category: 'Kucing Imut',
      emoji: '🐱',
      tag: 'POPULER 💗',
      gradientColors: [Color(0xFFFF9A8B), Color(0xFFFF6A88), Color(0xFFFF99AC)],
      auraColor: Color(0xFFFF758C),
      animationType: AvatarAnimationType.bounce,
      subtitle: 'Kucing imut pencinta tabungan yang berkilau',
    ),
    AnimatedAvatarItem(
      id: 'anim:honey_bear',
      name: 'Honey Bear',
      category: 'Beruang Madu',
      emoji: '🐻',
      tag: 'LUCU 💖',
      gradientColors: [Color(0xFFF6D365), Color(0xFFFDA085)],
      auraColor: Color(0xFFFFA07A),
      animationType: AvatarAnimationType.wiggle,
      subtitle: 'Beruang manis yang rajin menjaga anggaran',
    ),
    AnimatedAvatarItem(
      id: 'anim:bunny_hop',
      name: 'Bunny Hop',
      category: 'Kelinci Ceria',
      emoji: '🐰',
      tag: 'GEMAS 💕',
      gradientColors: [Color(0xFFFFC3A0), Color(0xFFFFAFBD)],
      auraColor: Color(0xFFFF8DA1),
      animationType: AvatarAnimationType.bounce,
      subtitle: 'Kelinci gesit yang selalu lompat hemat',
    ),
    AnimatedAvatarItem(
      id: 'anim:panda_rich',
      name: 'Panda Rich',
      category: 'Panda Sultan',
      emoji: '🐼',
      tag: 'SULTAN 💖',
      gradientColors: [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
      auraColor: Color(0xFF4FACFE),
      animationType: AvatarAnimationType.heartbeat,
      subtitle: 'Panda hoki pencetak surplus finansial',
    ),
    AnimatedAvatarItem(
      id: 'anim:smart_fox',
      name: 'Smart Fox',
      category: 'Rubah Cerdas',
      emoji: '🦊',
      tag: 'CERDAS',
      gradientColors: [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
      auraColor: Color(0xFFF38181),
      animationType: AvatarAnimationType.wiggle,
      subtitle: 'Rubah bijak ahli strategi keuangan cerdas',
    ),
    AnimatedAvatarItem(
      id: 'anim:spend_bot',
      name: 'SpendBot 3000',
      category: 'Robot AI',
      emoji: '🤖',
      tag: 'FUTURISTIK',
      gradientColors: [Color(0xFF667EEA), Color(0xFF764BA2)],
      auraColor: Color(0xFF8E54E9),
      animationType: AvatarAnimationType.pulse,
      subtitle: 'Asisten robot canggih pemantau budget harian',
    ),
    AnimatedAvatarItem(
      id: 'anim:magic_unicorn',
      name: 'Magic Unicorn',
      category: 'Magical',
      emoji: '🦄',
      tag: 'AJAIB 💗',
      gradientColors: [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
      auraColor: Color(0xFFE2B0FF),
      animationType: AvatarAnimationType.sparkle,
      subtitle: 'Kuda ajaib pembawa rezeki dan keberuntungan',
    ),
    AnimatedAvatarItem(
      id: 'anim:chirpy_chick',
      name: 'Chirpy Chick',
      category: 'Anak Ayam',
      emoji: '🐥',
      tag: 'SEMANGAT 💖',
      gradientColors: [Color(0xFFFEE140), Color(0xFFFA709A)],
      auraColor: Color(0xFFFDC830),
      animationType: AvatarAnimationType.bounce,
      subtitle: 'Anak ayam ceria yang selalu optimis menabung',
    ),
    AnimatedAvatarItem(
      id: 'anim:astro_kid',
      name: 'Astro Star',
      category: 'Astronot',
      emoji: '🚀',
      tag: 'EKSPLORASI',
      gradientColors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
      auraColor: Color(0xFF00C6FF),
      animationType: AvatarAnimationType.float,
      subtitle: 'Membidik tujuan finansial setinggi bintang',
    ),
    AnimatedAvatarItem(
      id: 'anim:sakura_princess',
      name: 'Sakura Princess',
      category: 'Princess',
      emoji: '👑',
      tag: 'ANGGUN 💖',
      gradientColors: [Color(0xFFFF758C), Color(0xFFFF7EB3)],
      auraColor: Color(0xFFFF5277),
      animationType: AvatarAnimationType.sparkle,
      subtitle: 'Mahkota kemakmuran dan gaya hidup teratur',
    ),
    AnimatedAvatarItem(
      id: 'anim:golden_piggy',
      name: 'Golden Piggy',
      category: 'Celengan Emas',
      emoji: '🐷',
      tag: 'TABUNGAN 💗',
      gradientColors: [Color(0xFFFFECD2), Color(0xFFFCB69F)],
      auraColor: Color(0xFFFF9E7A),
      animationType: AvatarAnimationType.heartbeat,
      subtitle: 'Celengan setia pengumpul koin impianmu',
    ),
    AnimatedAvatarItem(
      id: 'anim:gamer_cat',
      name: 'Cyber Gamer',
      category: 'Gaming',
      emoji: '🎮',
      tag: 'COOL',
      gradientColors: [Color(0xFFB06AB3), Color(0xFF4568DC)],
      auraColor: Color(0xFF7B1FA2),
      animationType: AvatarAnimationType.pulse,
      subtitle: 'Level up finansialmu layaknya pro player',
    ),
  ];

  static AnimatedAvatarItem? findById(String? id) {
    if (id == null || !id.startsWith('anim:')) return null;
    try {
      return items.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }
}
