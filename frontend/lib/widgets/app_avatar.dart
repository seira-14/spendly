import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/animated_avatar_data.dart';
import '../core/constants/app_colors.dart';

class AppAvatar extends StatefulWidget {
  final String? avatarUrl;
  final String userName;
  final double size;
  final bool isAnimated;
  final bool showBorder;
  final bool showGlow;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final Widget? badgeWidget;

  const AppAvatar({
    super.key,
    required this.avatarUrl,
    required this.userName,
    this.size = 80,
    this.isAnimated = true,
    this.showBorder = true,
    this.showGlow = false,
    this.borderColor,
    this.borderWidth = 3,
    this.onTap,
    this.badgeWidget,
  });

  @override
  State<AppAvatar> createState() => _AppAvatarState();
}

class _AppAvatarState extends State<AppAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    if (widget.isAnimated) {
      _animController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AppAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated && !_animController.isAnimating) {
      _animController.repeat();
    } else if (!widget.isAnimated && _animController.isAnimating) {
      _animController.stop();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rawUrl = widget.avatarUrl;
    final animatedItem = AnimatedAvatarData.findById(rawUrl);
    final isPreset = animatedItem != null;
    final isNetwork = rawUrl != null && (rawUrl.startsWith('http://') || rawUrl.startsWith('https://'));

    Widget avatarCore;

    if (isPreset) {
      avatarCore = _buildAnimatedPresetAvatar(animatedItem);
    } else if (isNetwork) {
      avatarCore = _buildNetworkAvatar(rawUrl);
    } else {
      avatarCore = _buildFallbackInitialsAvatar();
    }

    Widget content = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          avatarCore,
          if (widget.badgeWidget != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: widget.badgeWidget!,
            ),
        ],
      ),
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: content,
      );
    }

    return content;
  }

  Widget _buildAnimatedPresetAvatar(AnimatedAvatarItem item) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final val = _animController.value;
        double translateY = 0;
        double translateX = 0;
        double scale = 1.0;
        double rotation = 0;
        double glowSpread = widget.showGlow ? 4.0 : 0.0;

        if (widget.isAnimated) {
          switch (item.animationType) {
            case AvatarAnimationType.bounce:
              translateY = math.sin(val * 2 * math.pi) * (widget.size * 0.06);
              glowSpread += math.sin(val * 2 * math.pi).abs() * 3.0;
              break;

            case AvatarAnimationType.pulse:
              scale = 1.0 + math.sin(val * 2 * math.pi) * 0.06;
              glowSpread += math.sin(val * 2 * math.pi).abs() * 5.0;
              break;

            case AvatarAnimationType.wiggle:
              rotation = math.sin(val * 2 * math.pi) * 0.12;
              translateY = math.sin(val * 4 * math.pi) * (widget.size * 0.02);
              break;

            case AvatarAnimationType.sparkle:
              scale = 1.0 + math.sin(val * 2 * math.pi) * 0.04;
              glowSpread += (math.sin(val * 4 * math.pi) + 1.0) * 3.0;
              break;

            case AvatarAnimationType.heartbeat:
              final cycle = (val * 2) % 1.0;
              if (cycle < 0.2) {
                scale = 1.0 + math.sin(cycle / 0.2 * math.pi) * 0.12;
              } else if (cycle < 0.4) {
                scale = 1.0 + math.sin((cycle - 0.2) / 0.2 * math.pi) * 0.07;
              } else {
                scale = 1.0;
              }
              break;

            case AvatarAnimationType.float:
              translateX = math.sin(val * 2 * math.pi) * (widget.size * 0.04);
              translateY = math.cos(val * 2 * math.pi) * (widget.size * 0.05);
              rotation = math.sin(val * 2 * math.pi) * 0.05;
              break;
          }
        }

        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              if (widget.showGlow || glowSpread > 0)
                BoxShadow(
                  color: item.auraColor.withOpacity(0.4),
                  blurRadius: 16 + glowSpread,
                  spreadRadius: glowSpread,
                ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: item.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: widget.showBorder
                  ? Border.all(
                      color: widget.borderColor ?? Colors.white,
                      width: widget.borderWidth,
                    )
                  : null,
            ),
            child: ClipOval(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ambient light bubble
                  Positioned(
                    top: -widget.size * 0.2,
                    right: -widget.size * 0.2,
                    child: Container(
                      width: widget.size * 0.8,
                      height: widget.size * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.22),
                      ),
                    ),
                  ),

                  // Sparkle particle effect for sparkle/magic type
                  if (widget.isAnimated && (item.animationType == AvatarAnimationType.sparkle || item.animationType == AvatarAnimationType.pulse))
                    Positioned(
                      top: widget.size * 0.15 + math.sin(val * 2 * math.pi) * 2,
                      right: widget.size * 0.18 + math.cos(val * 2 * math.pi) * 2,
                      child: Opacity(
                        opacity: (math.sin(val * 4 * math.pi).abs() * 0.9).clamp(0.2, 1.0),
                        child: Text('💗', style: TextStyle(fontSize: widget.size * 0.20)),
                      ),
                    ),

                  // Main Animated Character
                  Transform.translate(
                    offset: Offset(translateX, translateY),
                    child: Transform.rotate(
                      angle: rotation,
                      child: Transform.scale(
                        scale: scale,
                        child: Text(
                          item.emoji,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: widget.size * 0.48,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkAvatar(String url) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: widget.showBorder
            ? Border.all(
                color: widget.borderColor ?? Colors.white,
                width: widget.borderWidth,
              )
            : null,
        boxShadow: [
          if (widget.showGlow)
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: widget.size,
          height: widget.size,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: AppColors.cardPinkLight,
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackInitialsAvatar();
          },
        ),
      ),
    );
  }

  Widget _buildFallbackInitialsAvatar() {
    final initial = widget.userName.trim().isNotEmpty
        ? widget.userName.trim().substring(0, 1).toUpperCase()
        : 'S';

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8FA3), Color(0xFFFF5C8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: widget.showBorder
            ? Border.all(
                color: widget.borderColor ?? Colors.white,
                width: widget.borderWidth,
              )
            : null,
        boxShadow: [
          if (widget.showGlow)
            BoxShadow(
              color: const Color(0xFFFF5C8A).withOpacity(0.4),
              blurRadius: 14,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: AppColors.cardShadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.outfit(
          fontSize: widget.size * 0.42,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
