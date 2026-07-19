import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/widgets/shared_widgets.dart';
import 'package:klinixy/features/auth/presentation/bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _riderController;
  int _deliveryCount = 0;
  final int _targetCount = 2847;
  Timer? _counterTimer;
  int _activeTab = 0; // 0 = Fast Delivery, 1 = Safety First, 2 = Best Prices

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _riderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Animate delivery counter
    _counterTimer = Timer.periodic(const Duration(milliseconds: 15), (timer) {
      if (_deliveryCount >= _targetCount) {
        timer.cancel();
        return;
      }
      setState(() {
        _deliveryCount = (_deliveryCount + 59).clamp(0, _targetCount);
      });
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _riderController.dispose();
    _counterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ── Hero Section ──
                Container(
                  width: double.infinity,
                  height: size.height * 0.44,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF00D4FF),
                        Color(0xFF0066FF),
                        Color(0xFF0D2B6E),
                        Color(0xFF091D4A),
                      ],
                      stops: [0.0, 0.35, 0.7, 1.0],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                        ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(44),
                      bottomRight: Radius.circular(44),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated floating background items
                      _AnimatedOrb(
                        controller: _floatController,
                        top: -20,
                        right: -20,
                        size: 130,
                        color: Colors.white.withValues(alpha: 0.05),
                        offset: 12,
                      ),
                      _AnimatedOrb(
                        controller: _floatController,
                        bottom: 30,
                        left: -50,
                        size: 160,
                        color: Colors.white.withValues(alpha: 0.04),
                        offset: -15,
                      ),

                      // Animated live rider pathway simulation
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: _LiveRiderSimulator(riderController: _riderController),
                      ),

                      // Hero contents
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Interactive Pulsing Logo
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) => Container(
                                  width: 85,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                      BoxShadow(
                                        color: AppColors.secondary.withValues(
                                            alpha: 0.2 + _pulseController.value * 0.15),
                                        blurRadius: 40 + _pulseController.value * 15,
                                        spreadRadius: 2 + _pulseController.value * 2,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Image.asset(
                                      'assets/images/klinixy_app_logo_transparent.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              // App title image
                              Image.asset(
                                'assets/images/klinixy_logo_transparent.png',
                                height: 42,
                                fit: BoxFit.contain,
                                color: Colors.white,
                                colorBlendMode: BlendMode.srcIn,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Ultra-fast 30 Min Medicine Delivery',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Trust & Action Cards Section ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    children: [
                      // ── Live stats & Active delivery status ──
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) => Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.success.withValues(
                                      alpha: 0.4 + _pulseController.value * 0.6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.success.withValues(
                                          alpha: _pulseController.value * 0.4),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_deliveryCount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")} deliveries done today',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('⚡ Average: 18 mins',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Guaranteed Genuine Seals ──
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppShadows.card,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _CertificationSeal(
                              icon: Icons.gpp_good_rounded,
                              title: '100% Genuine',
                              subtitle: 'Direct from brands',
                              iconColor: AppColors.success,
                            ),
                            Container(width: 1.5, height: 36, color: AppColors.divider),
                            _CertificationSeal(
                              icon: Icons.verified_user_rounded,
                              title: 'Verified Rx',
                              subtitle: 'Doctor approved',
                              iconColor: AppColors.primary,
                            ),
                            Container(width: 1.5, height: 36, color: AppColors.divider),
                            _CertificationSeal(
                              icon: Icons.timer_rounded,
                              title: '30m Guarantee',
                              subtitle: 'Or get it free',
                              iconColor: AppColors.warning,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Interactive "Why Trust Us?" Tabs ──
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: AppShadows.card,
                        ),
                        child: Column(
                          children: [
                            // Tab selector header
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Row(
                                children: [
                                  _InteractiveTabHeader(
                                    label: 'Speed',
                                    isActive: _activeTab == 0,
                                    onTap: () => setState(() => _activeTab = 0),
                                  ),
                                  _InteractiveTabHeader(
                                    label: 'Safety',
                                    isActive: _activeTab == 1,
                                    onTap: () => setState(() => _activeTab = 1),
                                  ),
                                  _InteractiveTabHeader(
                                    label: 'Price',
                                    isActive: _activeTab == 2,
                                    onTap: () => setState(() => _activeTab = 2),
                                  ),
                                ],
                              ),
                            ),
                            const AppDivider(),
                            // Tab content
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                child: _buildTabContent(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Primary Action: Google Sign In ──
                      _GoogleSignInButton(
                        isLoading: isLoading,
                        onTap: () => context
                            .read<AuthBloc>()
                            .add(const AuthGoogleSignInRequested()),
                      ),

                      const SizedBox(height: 8),

                      // ── Guest sign in ──
                      TextButton.icon(
                        key: const Key('guest_sign_in_button'),
                        onPressed: isLoading
                            ? null
                            : () => context
                                .read<AuthBloc>()
                                .add(const AuthGuestSignInRequested()),
                        icon: const Icon(Icons.explore_rounded, color: AppColors.primary, size: 18),
                        label: Text(
                          'Explore Demo Marketplace',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Real Customer Testimonial ──
                      _ReviewTicker(),

                      const SizedBox(height: 16),

                      // ── Accordion FAQ Accordion for extreme transparency ──
                      _InteractiveFAQSection(),

                      const SizedBox(height: 20),

                      // ── Trust & Compliance Footer ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified_rounded, size: 15, color: AppColors.success),
                          const SizedBox(width: 6),
                          Text(
                            'Licensed Pharmacy Partner · HIPAA Compliant Secure Data',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'By continuing you accept our Terms of Service & Privacy Policy',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint,
                          fontSize: 9.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0:
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flash_on_rounded, color: AppColors.warning, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('30-Minute Delivery Guarantee', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Our riders are stationed at local verified pharmacies to dispatch medicines within 3 minutes of upload.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        );
      case 1:
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_rounded, color: AppColors.success, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rigorous Double-Pharmacist Check', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Every prescription is digitally reviewed and cross-checked by certified pharmacists to ensure absolute accuracy.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        );
      case 2:
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_offer_rounded, color: AppColors.accent, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cheapest Prices in Town', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'We offer up to 40% discount directly on all prescriptions with absolutely zero hidden convenience charges.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }
}

// ── Live Rider Simulator ──
class _LiveRiderSimulator extends StatelessWidget {
  final AnimationController riderController;
  const _LiveRiderSimulator({required this.riderController});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Road Line
          Container(
            height: 2,
            width: double.infinity,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          // Animated rider
          AnimatedBuilder(
            animation: riderController,
            builder: (context, child) {
              final progress = riderController.value;
              return Positioned(
                left: progress * MediaQuery.of(context).size.width * 0.7,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delivery_dining_rounded,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Rider delivering...',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Interactive Tab Header ──
class _InteractiveTabHeader extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _InteractiveTabHeader({
    required this.label,
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
            color: isActive ? AppColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Certification Seal ──
class _CertificationSeal extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;

  const _CertificationSeal({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 10.5,
          ),
        ),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 8.5,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }
}

// ── Interactive FAQ Section ──
class _InteractiveFAQSection extends StatefulWidget {
  @override
  State<_InteractiveFAQSection> createState() => _InteractiveFAQSectionState();
}

class _InteractiveFAQSectionState extends State<_InteractiveFAQSection> {
  int _expandedIdx = -1;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How do you guarantee 30-minute delivery?',
      'a': 'We work with hyper-local pharmacies. Once a pharmacist verifies the prescription, a rider is matched instantly to pick up and deliver.'
    },
    {
      'q': 'Are the medicines genuine?',
      'a': 'Absolutely. Every medicine is sourced directly from licensed pharma companies & distributors. All partners are certified.'
    },
    {
      'q': 'What happens if there is a delay?',
      'a': 'If we fail to deliver in 30 minutes, your delivery charge is waived and you get an instant ₹100 cash back coupon.'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: _faqs.asMap().entries.map((entry) {
          final idx = entry.key;
          final faq = entry.value;
          final isExpanded = _expandedIdx == idx;

          return Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedIdx = isExpanded ? -1 : idx;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faq['q']!,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 14),
                  child: Text(
                    faq['a']!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
              if (idx < _faqs.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: AppDivider(),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Animated Orb ──
class _AnimatedOrb extends StatelessWidget {
  final AnimationController controller;
  final double? top, bottom, left, right;
  final double size;
  final Color color;
  final double offset;

  const _AnimatedOrb({
    required this.controller,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Positioned(
        top: top != null ? top! + controller.value * offset : null,
        bottom: bottom != null ? bottom! + controller.value * offset : null,
        left: left,
        right: right,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

// ── Google Sign In Button ──
class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _GoogleSignInButton({
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          gradient: isLoading ? null : AppColors.primaryGradient,
          color: isLoading ? AppColors.surfaceVariant : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: CustomPaint(
                          painter: _GoogleGPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Continue with Google',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 14.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Google G painter ──
class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), -0.5, 2.0, true, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), 3.14 + 0.5, 1.1, true, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), 2.5, 1.0, true, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), 1.5, 1.2, true, paint);

    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.6, paint);
    final barRect = Rect.fromCenter(
      center: Offset(center.dx + radius * 0.2, center.dy),
      width: radius * 0.85,
      height: radius * 0.45,
    );
    canvas.drawRect(barRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Animated review ticker ──
class _ReviewTicker extends StatefulWidget {
  @override
  State<_ReviewTicker> createState() => _ReviewTickerState();
}

class _ReviewTickerState extends State<_ReviewTicker> {
  int _currentReview = 0;
  Timer? _timer;

  static const _reviews = [
    _Review('Priya S.', 'Got medicines in 22 mins! Faster than any app 🔥', 5),
    _Review('Rahul M.', 'Saved ₹340 on my monthly prescription 💰', 5),
    _Review('Dr. Anjali K.', 'I recommend Klinixy to all my patients ⭐', 5),
    _Review('Amit P.', 'Night delivery at 2 AM — lifesaver! 🙏', 5),
    _Review('Sneha R.', '40% off on Dolo. Much cheaper than 1mg!', 5),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() => _currentReview = (_currentReview + 1) % _reviews.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final review = _reviews[_currentReview];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(_currentReview),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                review.name[0],
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        review.name,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 6),
                      ...List.generate(
                        review.stars,
                        (_) => const Icon(
                          Icons.star_rounded,
                          size: 10,
                          color: Color(0xFFFACC15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    review.text,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10.5,
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
    );
  }
}

class _Review {
  final String name;
  final String text;
  final int stars;
  const _Review(this.name, this.text, this.stars);
}
