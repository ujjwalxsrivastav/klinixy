import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/widgets/shared_widgets.dart';
import 'package:klinixy/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:klinixy/features/product/domain/entities/product_entity.dart';

class RoutineQuizSheet extends StatefulWidget {
  const RoutineQuizSheet({super.key});

  @override
  State<RoutineQuizSheet> createState() => _RoutineQuizSheetState();
}

class _RoutineQuizSheetState extends State<RoutineQuizSheet>
    with TickerProviderStateMixin {
  int _step = 0;
  // 0: Intro
  // 1: Category
  // 2: "Do you experience these?" (relatable scenario cards)
  // 3: Severity slider
  // 4: "Did you know?" science fact + ingredient reveal
  // 5: Analyzing animation
  // 6: Results

  String? _selectedCategory;
  String? _selectedScenario;
  double _severity = 2; // 1-5 scale
  String? _selectedIngredient;

  double _loadingProgress = 0.0;
  Timer? _analysisTimer;
  String _analysisText = '';
  int _analysisPhase = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _analysisTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Data Maps ──────────────────────────────────────────────────

  List<Map<String, String>> _getScenariosForCategory() {
    if (_selectedCategory == 'skincare') {
      return [
        {
          'id': 'acne',
          'emoji': '😩',
          'title': 'Woke up with new pimples again',
          'detail': 'Oily T-zone, random breakouts before events, and stubborn chin acne that won\'t go away.',
        },
        {
          'id': 'dullness',
          'emoji': '😔',
          'title': 'Skin looks tired even after sleep',
          'detail': 'Uneven tone, dark spots from old pimples, and that "no glow" look in photos and selfies.',
        },
        {
          'id': 'dry_tight',
          'emoji': '🥴',
          'title': 'Face feels tight after washing',
          'detail': 'Flaky patches near nose, redness after products, and skin that drinks up moisturizer instantly.',
        },
      ];
    } else if (_selectedCategory == 'haircare') {
      return [
        {
          'id': 'dandruff',
          'emoji': '😖',
          'title': 'White flakes on shoulders daily',
          'detail': 'Itchy scalp that gets worse in AC rooms. Embarrassing flakes on dark clothes.',
        },
        {
          'id': 'hairfall',
          'emoji': '😟',
          'title': 'Hair fall in every comb stroke',
          'detail': 'Shower drain full of hair. Thinning at temples. Ponytail feels thinner than last year.',
        },
      ];
    } else {
      return [
        {
          'id': 'dry_body',
          'emoji': '😣',
          'title': 'Legs look ashy and dry year-round',
          'detail': 'Scratching leaves white lines. Elbows and knees always rough. Skin cracks in winter.',
        },
      ];
    }
  }

  Map<String, String> _getSeverityInfo() {
    if (_severity <= 1.5) {
      return {'level': 'Mild', 'color': 'green', 'emoji': '🟢', 'note': 'Minor irritation. A basic routine can help prevent escalation.'};
    } else if (_severity <= 3) {
      return {'level': 'Moderate', 'color': 'orange', 'emoji': '🟡', 'note': 'Noticeable daily impact. Active ingredients needed to reverse damage.'};
    } else {
      return {'level': 'Severe', 'color': 'red', 'emoji': '🔴', 'note': 'Significant concern. Clinical-grade actives recommended for fast recovery.'};
    }
  }

  Map<String, dynamic> _getScienceFact() {
    if (_selectedCategory == 'skincare') {
      if (_selectedScenario == 'acne') {
        return {
          'fact': 'Your pores produce sebum 24/7. When dead skin cells mix with excess sebum, they form a plug — bacteria multiply inside this plug causing inflammation (pimples).',
          'solution': 'Salicylic Acid (BHA) dissolves inside the pore to break the plug. Neem extract kills acne-causing bacteria naturally.',
          'ingredients': [
            {'id': 'salicylic', 'name': 'Salicylic Acid 2% (Neutrogena)', 'action': 'Penetrates oil to unclog pores from inside'},
            {'id': 'neem', 'name': 'Neem + Turmeric (Himalaya)', 'action': 'Natural antibacterial that prevents new breakouts'},
            {'id': 'niacinamide', 'name': 'Niacinamide 10% (Minimalist)', 'action': 'Controls oil + fades acne marks'},
          ],
        };
      } else if (_selectedScenario == 'dullness') {
        return {
          'fact': 'Your skin sheds ~30,000 dead cells every hour. When this process slows down, dead cells pile up — making skin look dull and trapping dark pigment beneath.',
          'solution': 'Vitamin C accelerates cell turnover and blocks melanin production. Niacinamide evens skin tone from within.',
          'ingredients': [
            {'id': 'vitc', 'name': 'Vitamin C 20% (Mamaearth)', 'action': 'Boosts collagen + removes dark spots'},
            {'id': 'niacinamide', 'name': 'Niacinamide 10% (Minimalist)', 'action': 'Evens skin tone + shrinks pores'},
          ],
        };
      } else {
        return {
          'fact': 'Your skin barrier is made of ceramide lipids — like bricks and mortar. When this barrier cracks, water escapes (TEWL) causing tightness, flaking, and redness.',
          'solution': 'Gentle cleansers preserve ceramides instead of stripping them. Barrier-repair formulas lock moisture for 24+ hours.',
          'ingredients': [
            {'id': 'gentle', 'name': 'Gentle Cleanser (Cetaphil)', 'action': 'Soap-free formula that cleans without stripping'},
            {'id': 'niacinamide', 'name': 'Niacinamide 10% (Minimalist)', 'action': 'Strengthens barrier + reduces redness'},
          ],
        };
      }
    } else if (_selectedCategory == 'haircare') {
      if (_selectedScenario == 'dandruff') {
        return {
          'fact': 'Dandruff is caused by Malassezia fungus that feeds on your scalp oils. It triggers rapid skin cell turnover — those visible white flakes are clumps of dead scalp skin.',
          'solution': 'Ketoconazole directly kills the Malassezia fungus at its root. Zinc Pyrithione prevents regrowth.',
          'ingredients': [
            {'id': 'keto', 'name': 'Ketoconazole 2% + ZPTO (Scalpe Plus)', 'action': 'Pharma-grade antifungal used by dermatologists'},
            {'id': 'herbal', 'name': 'Bio Kelp Protein (Biotique)', 'action': 'Strengthens hair weakened by dandruff'},
          ],
        };
      } else {
        return {
          'fact': 'Each hair follicle has a growth cycle. Stress, poor nutrition, and weak blood flow cause follicles to enter "rest phase" early — leading to excessive shedding and thinning.',
          'solution': 'Bringharaj stimulates blood circulation to dormant follicles. Protein-rich formulas strengthen the hair shaft from root.',
          'ingredients': [
            {'id': 'bringha', 'name': 'Bringharaj + 9 Herbs (Indulekha)', 'action': 'Clinically proven 50% less hair fall in 4 months'},
            {'id': 'protein', 'name': 'Bio Kelp Protein (Biotique)', 'action': 'Rebuilds weak hair strands from root'},
          ],
        };
      }
    } else {
      return {
        'fact': 'Your body skin has fewer oil glands than your face — especially on shins, elbows, and knees. Without a lipid barrier, moisture evaporates rapidly causing chronic dryness.',
        'solution': 'Micro-droplet technology creates an invisible moisture shield. Deep moisture serums penetrate 10 layers deep.',
        'ingredients': [
          {'id': 'vaseline', 'name': 'Intensive Care (Vaseline)', 'action': 'Micro-droplet jelly heals dry skin in 5 days'},
          {'id': 'nivea', 'name': 'Nourishing Body Milk (Nivea)', 'action': '48-hr deep hydration with Almond Oil'},
        ],
      };
    }
  }

  List<ProductEntity> _getRecommendedProducts() {
    final all = MockProducts.all;
    final science = _getScienceFact();
    final ingredients = science['ingredients'] as List<Map<String, String>>;
    final ids = <String>[];

    for (final ing in ingredients) {
      final ingId = ing['id']!;
      // Map ingredient IDs to product IDs
      if (ingId == 'salicylic') ids.add('sk3');
      if (ingId == 'neem') ids.add('sk4');
      if (ingId == 'niacinamide') ids.add('sk2');
      if (ingId == 'vitc') ids.add('sk5');
      if (ingId == 'gentle') ids.add('sk1');
      if (ingId == 'keto') ids.add('hc1');
      if (ingId == 'herbal' || ingId == 'protein') ids.add('hc3');
      if (ingId == 'bringha') ids.add('hc2');
      if (ingId == 'vaseline') ids.add('bc1');
      if (ingId == 'nivea') ids.add('bc2');
    }

    return all.where((p) => ids.contains(p.id)).toList();
  }

  void _startAnalysis() {
    setState(() {
      _step = 5;
      _loadingProgress = 0.0;
      _analysisPhase = 0;
    });

    final steps = [
      'Cross-referencing your symptoms with clinical database...',
      'Matching active ingredients to severity level...',
      'Filtering ${_selectedCategory == "skincare" ? "dermatologist" : _selectedCategory == "haircare" ? "trichologist" : "clinical"}-approved formulas...',
      'Building your personalized routine...',
    ];

    _analysisTimer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (_loadingProgress >= 1.0) {
        timer.cancel();
        setState(() => _step = 6);
        return;
      }
      setState(() {
        _loadingProgress += 0.08;
        _analysisPhase = min(3, (_loadingProgress * 4).floor());
        _analysisText = steps[_analysisPhase];
      });
    });
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              if (_step > 0 && _step < 5) _buildProgressHeader(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final totalSteps = 4;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $_step of $totalSteps',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (_step > 1)
                GestureDetector(
                  onTap: () => setState(() => _step--),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back_ios, size: 12, color: AppColors.textSecondary),
                      Text('Back', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _step / totalSteps,
            backgroundColor: AppColors.divider,
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            minHeight: 5,
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_step) {
      case 0: return _buildIntro();
      case 1: return _buildCategory();
      case 2: return _buildScenarios();
      case 3: return _buildSeverity();
      case 4: return _buildScienceReveal();
      case 5: return _buildAnalyzing();
      case 6: return _buildResults();
      default: return const SizedBox();
    }
  }

  // ── Step 0: Intro ─────────────────────────────────────────────

  Widget _buildIntro() {
    return Container(
      key: const ValueKey('intro'),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.biotech_rounded, size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'What\'s Your Skin\nActually Telling You?',
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Take a 60-second quiz to understand WHY your skin or hair behaves the way it does — and discover exactly what to fix it.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Social proof
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '12,847 people took this quiz this week',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TapScale(
            onTap: () => setState(() => _step = 1),
            child: Container(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Start Free Analysis',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Category ──────────────────────────────────────────

  Widget _buildCategory() {
    final cats = [
      {'id': 'skincare', 'emoji': '🧴', 'title': 'Face & Skin', 'sub': 'Acne, dullness, dryness, dark spots', 'color': Colors.pinkAccent},
      {'id': 'haircare', 'emoji': '💇', 'title': 'Hair & Scalp', 'sub': 'Hair fall, dandruff, thinning, itchy scalp', 'color': Colors.deepPurpleAccent},
      {'id': 'bodycare', 'emoji': '🤲', 'title': 'Body & Skin', 'sub': 'Dry legs, rough elbows, winter cracks', 'color': Colors.blueAccent},
    ];

    return Container(
      key: const ValueKey('cat'),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What area bothers you most?', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          ...cats.map((c) => _optionCard(
            emoji: c['emoji'] as String,
            title: c['title'] as String,
            subtitle: c['sub'] as String,
            color: c['color'] as Color,
            onTap: () {
              setState(() {
                _selectedCategory = c['id'] as String;
                _step = 2;
              });
            },
          )),
        ],
      ),
    );
  }

  // ── Step 2: Relatable Scenarios ───────────────────────────────

  Widget _buildScenarios() {
    final scenarios = _getScenariosForCategory();
    return Container(
      key: const ValueKey('scenario'),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Does this sound like you?', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('Pick the one you relate to most:', style: AppTextStyles.bodySmall),
          const SizedBox(height: 16),
          ...scenarios.map((s) => _scenarioCard(s)),
        ],
      ),
    );
  }

  Widget _scenarioCard(Map<String, String> s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 1.5),
        boxShadow: AppShadows.card,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedScenario = s['id'];
            _step = 3;
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s['emoji']!, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${s['title']!}"',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s['detail']!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 3: Severity Slider ───────────────────────────────────

  Widget _buildSeverity() {
    final info = _getSeverityInfo();
    final Color severityColor = _severity <= 1.5 ? AppColors.success : (_severity <= 3 ? Colors.orange : Colors.redAccent);

    return Container(
      key: const ValueKey('severity'),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How bad is it for you?', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('Drag the slider to rate your concern:', style: AppTextStyles.bodySmall),
          const SizedBox(height: 28),

          // Severity circle
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: severityColor.withOpacity(0.1),
                border: Border.all(color: severityColor, width: 3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    info['emoji']!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  Text(
                    info['level']!,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: severityColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: severityColor,
              inactiveTrackColor: AppColors.divider,
              thumbColor: severityColor,
              overlayColor: severityColor.withOpacity(0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: _severity,
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => setState(() => _severity = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Barely notice', style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
              Text('Affects daily life', style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 16),

          // Info note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: severityColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: severityColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    info['note']!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Next button
          TapScale(
            onTap: () => setState(() => _step = 4),
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'See What\'s Causing This →',
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 4: Science Fact + Ingredient Reveal ──────────────────

  Widget _buildScienceReveal() {
    final science = _getScienceFact();
    final ingredients = science['ingredients'] as List<Map<String, String>>;

    return Container(
      key: const ValueKey('science'),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Did you know" header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'Did you know?',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  science['fact'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Solution
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      'The Fix:',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  science['solution'] as String,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Matched Active Ingredients:',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...ingredients.map((ing) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.science_rounded, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ing['name']!,
                        style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ing['action']!,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),

          TapScale(
            onTap: _startAnalysis,
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Find Products With These Ingredients →',
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 5: Analyzing ─────────────────────────────────────────

  Widget _buildAnalyzing() {
    return Container(
      key: const ValueKey('analyzing'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: CircularProgressIndicator(
              value: _loadingProgress,
              strokeWidth: 7,
              color: AppColors.primary,
              backgroundColor: AppColors.divider,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${(_loadingProgress * 100).toInt()}%',
            style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.w900, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            _analysisText,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Step 6: Results ───────────────────────────────────────────

  Widget _buildResults() {
    final products = _getRecommendedProducts();
    final severityInfo = _getSeverityInfo();

    return Container(
      key: const ValueKey('results'),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        children: [
          // Report Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.success, size: 22),
              const SizedBox(width: 8),
              Text('Your Personalized Routine', style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Based on ${severityInfo['level']} ${_selectedScenario ?? ''} concern',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),

          // Product Cards
          ...products.asMap().entries.map((entry) {
            final idx = entry.key;
            final prod = entry.value;
            final stepLabels = ['Step ${idx + 1}: ${idx == 0 ? "Treat" : idx == 1 ? "Restore" : "Protect"}'];

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      stepLabels[0],
                      style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(prod.imageUrls.first, width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(prod.brand, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textHint, fontWeight: FontWeight.bold)),
                            Text(prod.name, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade600),
                                const SizedBox(width: 3),
                                Text(
                                  '${prod.rating} (${(prod.reviewCount / 1000).toStringAsFixed(0)}K reviews)',
                                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text('₹${prod.price.toStringAsFixed(0)}', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 6),
                                    Text('₹${prod.mrp.toStringAsFixed(0)}', style: AppTextStyles.bodySmall.copyWith(decoration: TextDecoration.lineThrough, fontSize: 10)),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('${prod.discount}% OFF', style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontSize: 8, fontWeight: FontWeight.w900)),
                                    ),
                                  ],
                                ),
                                TapScale(
                                  onTap: () {
                                    context.read<CartBloc>().add(CartAddItem(prod));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${prod.name} added! 🛍️'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)),
                                    child: Text('Add', style: AppTextStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // Bundle CTA
          TapScale(
            onTap: () {
              for (var p in products) {
                context.read<CartBloc>().add(CartAddItem(p));
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Complete routine added to cart! 🎉'), behavior: SnackBarBehavior.floating),
              );
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFC084FC)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add Complete Routine', style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(
                          '${products.length} products • Save ₹${products.fold<double>(0, (s, p) => s + (p.mrp - p.price)).toStringAsFixed(0)} total',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Text('Get All', style: AppTextStyles.labelMedium.copyWith(color: const Color(0xFF7C3AED), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Retake / Done
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _step = 1;
                    _selectedCategory = null;
                    _selectedScenario = null;
                    _severity = 2;
                  }),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Retake Quiz', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TapScale(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14)),
                    child: Center(child: Text('Done', style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────

  Widget _optionCard({
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 1.5),
        boxShadow: AppShadows.card,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: AppTextStyles.bodySmall.copyWith(fontSize: 11.5)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
