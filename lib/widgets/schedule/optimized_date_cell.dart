import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

/// 最適化されたカレンダー日付セルデータ
class DateCellData {
  const DateCellData({
    required this.day,
    required this.isSelected,
    required this.isMyRegistered,
    required this.isPast,
    required this.availableCount,
    required this.visualState,
  });

  final DateTime day;
  final bool isSelected;
  final bool isMyRegistered;
  final bool isPast;
  final int availableCount;
  final DateCellVisualState visualState;

  int get dayNumber => day.day;

  bool get hasAvailableIndicator => 
      !isMyRegistered && availableCount > 0;

  bool get hasStatusIcon => 
      isMyRegistered;
}

/// 日付セルの視覚状態
enum DateCellVisualState {
  past,
  myRegistered,
  selected,
  normal,
}

/// 最適化された日付セルウィジェット
class OptimizedDateCell extends StatelessWidget {
  const OptimizedDateCell({
    super.key,
    required this.data,
    required this.onTap,
    required this.isDarkMode,
  });

  final DateCellData data;
  final VoidCallback? onTap;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: _buildDecoration(),
        child: Stack(
          children: [
            // 日付数字
            Center(
              child: Text(
                '${data.dayNumber}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(),
                ),
              ),
            ),

            // 登録済みチェックマーク
            if (data.hasStatusIcon)
              const Positioned(
                top: 2,
                right: 2,
                child: _StatusIcon(),
              ),

            // 他のユーザーの参加可能数
            if (data.hasAvailableIndicator)
              Positioned(
                top: 2,
                right: 2,
                child: _AvailableCountBadge(count: data.availableCount),
              ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    switch (data.visualState) {
      case DateCellVisualState.past:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.withValues(alpha: 0.2),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        );

      case DateCellVisualState.myRegistered:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF10B981),
        );

      case DateCellVisualState.selected:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        );

      case DateCellVisualState.normal:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        );
    }
  }

  Color _getTextColor() {
    switch (data.visualState) {
      case DateCellVisualState.past:
        return Colors.grey.withValues(alpha: 0.5);
      case DateCellVisualState.myRegistered:
      case DateCellVisualState.selected:
        return Colors.white;
      case DateCellVisualState.normal:
        return AppTheme.primaryText(isDarkMode);
    }
  }
}

/// 最適化されたステータスアイコン（const対応）
class _StatusIcon extends StatelessWidget {
  const _StatusIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.check_circle,
      color: Colors.white,
      size: 16,
    );
  }
}

/// 最適化された参加可能数バッジ（const対応）
class _AvailableCountBadge extends StatelessWidget {
  const _AvailableCountBadge({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 空のカレンダーセル（const対応）
class EmptyCalendarCell extends StatelessWidget {
  const EmptyCalendarCell({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}