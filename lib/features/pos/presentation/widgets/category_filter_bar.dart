import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/domain/entities/category_entity.dart';

/// Sub-Header Filter Bar dengan tombol Toggle Layout (Tipe 1 Grid / Tipe 2 List)
/// dan deretan chip kategori horizontal sesuai `HOME - KASIR PAGE TIPE 1.png` & `TIPE 2.png`.
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.isGridCompact,
    required this.onToggleGridLayout,
  });

  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;
  final bool isGridCompact;
  final VoidCallback onToggleGridLayout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEAE5E0),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          // Tombol Kotak Toggle Layout Tipe 1 (Grid) / Tipe 2 (List) di sisi paling kiri
          InkWell(
            onTap: onToggleGridLayout,
            child: Container(
              width: 48.0,
              height: 48.0,
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                border: Border(
                  right: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1.0,
                  ),
                ),
              ),
              child: Icon(
                isGridCompact ? Icons.grid_view : Icons.view_agenda_outlined,
                color: AppColors.noir,
                size: 22.0,
              ),
            ),
          ),
          const SizedBox(width: 4.0),

          // Deretan Kategori Horizontal Sesuai Desain
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 6.0,
              ),
              itemCount: categories.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 8.0),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = selectedCategoryId == null;
                  return _buildCategoryChip(
                    label: 'Semua Menu',
                    isSelected: isSelected,
                    onTap: () => onCategorySelected(null),
                  );
                }

                final category = categories[index - 1];
                final isSelected = selectedCategoryId == category.id;
                return _buildCategoryChip(
                  label: category.name,
                  isSelected: isSelected,
                  onTap: () => onCategorySelected(category.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        decoration: BoxDecoration(
          // Active chip warna Blush Pink (#F5CBD7), inactive putih bergaris tipis abu
          color: isSelected ? AppColors.accent : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? AppColors.accent : const Color(0xFFE2DDD7),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 4.0,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.noir,
          ),
        ),
      ),
    );
  }
}
