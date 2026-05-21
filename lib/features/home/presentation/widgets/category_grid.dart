import 'package:flutter/material.dart';
import 'package:klinixy/core/theme/app_theme.dart';
import 'package:klinixy/core/widgets/shared_widgets.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  static final List<_CategoryData> _categories = [
    _CategoryData('Medicines', Icons.medication_rounded, Color(0xFF0057FF), Color(0xFFE6EEFF)),
    _CategoryData('Vitamins', Icons.health_and_safety_rounded, Color(0xFF22C55E), Color(0xFFDCFCE7)),
    _CategoryData('Diabetes', Icons.monitor_heart_rounded, Color(0xFFEF4444), Color(0xFFFEE2E2)),
    _CategoryData('Baby Care', Icons.child_care_rounded, Color(0xFFF59E0B), Color(0xFFFEF3C7)),
    _CategoryData('Skin Care', Icons.face_rounded, Color(0xFFEC4899), Color(0xFFFCE7F3)),
    _CategoryData('Devices', Icons.devices_rounded, Color(0xFF8B5CF6), Color(0xFFEDE9FE)),
    _CategoryData('Personal\nCare', Icons.spa_rounded, Color(0xFF00C6AE), Color(0xFFD4F7F4)),
    _CategoryData('Ayurveda', Icons.eco_rounded, Color(0xFF65A30D), Color(0xFFECFCCB)),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md - 4),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return _CategoryItem(data: _categories[index]);
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final _CategoryData data;
  const _CategoryItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: () {},
      child: Container(
        width: 76,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: data.bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(data.icon, color: data.color, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              data.name,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  final Color bgColor;

  _CategoryData(this.name, this.icon, this.color, this.bgColor);
}
