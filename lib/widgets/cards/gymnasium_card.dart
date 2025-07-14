import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/gymnasium_model.dart';
import '../../themes/app_theme.dart';
import '../../utils/distance_calculator.dart';

/// 体育館情報カードWidget
/// 
/// 体育館の基本情報、設備、料金を表示し、
/// 詳細表示、お気に入り機能を提供
class GymnasiumCard extends StatelessWidget {
  const GymnasiumCard({
    super.key,
    required this.gymnasium,
    required this.isDarkMode,
    this.onFavoriteChanged,
    this.isFavorite = false,
    this.userLocation,
  });

  final GymnasiumModel gymnasium;
  final bool isDarkMode;
  final VoidCallback? onFavoriteChanged;
  final bool isFavorite;
  final LatLng? userLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildContent(),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gymnasium.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gymnasium.address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (userLocation != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              _getDistanceText(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white60,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onFavoriteChanged,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red[300] : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 設備情報
          if (gymnasium.facilities.isNotEmpty) ...[
            Text(
              '利用可能設備',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _getSortedFacilities(gymnasium.facilities).take(6).map((facility) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF667eea).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    facility,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF667eea),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (gymnasium.facilities.length > 6)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '他${gymnasium.facilities.length - 6}件',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.tertiaryText(isDarkMode),
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
          
          // 料金情報
          if (gymnasium.fees.isNotEmpty) ...[
            Text(
              '利用料金',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
            const SizedBox(height: 8),
            for (final entry in gymnasium.fees.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryText(isDarkMode),
                      ),
                    ),
                    Text(
                      '¥${entry.value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryText(isDarkMode),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
          ],
          
          // 基本情報
          if (gymnasium.openingHours != null || gymnasium.phone != null) ...[
            Row(
              children: [
                if (gymnasium.openingHours != null) ...[
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.tertiaryText(isDarkMode),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      gymnasium.openingHours!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryText(isDarkMode),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (gymnasium.phone != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: AppTheme.tertiaryText(isDarkMode),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    gymnasium.phone!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryText(isDarkMode),
                    ),
                  ),
                ],
              ),
            ],
            if (gymnasium.parkingSpaces != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.local_parking,
                    size: 16,
                    color: AppTheme.tertiaryText(isDarkMode),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '駐車場 ${gymnasium.parkingSpaces}台',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryText(isDarkMode),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.containerBackground(isDarkMode),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showDetailDialog(),
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text(
                '詳細',
                style: TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF667eea),
                side: const BorderSide(color: Color(0xFF667eea)),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: gymnasium.phone != null ? () => _makePhoneCall() : null,
              icon: const Icon(Icons.phone, size: 16),
              label: const Text(
                '電話',
                style: TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: gymnasium.phone != null
                    ? const Color(0xFF10B981)
                    : AppTheme.tertiaryText(isDarkMode),
                side: BorderSide(
                  color: gymnasium.phone != null
                      ? const Color(0xFF10B981)
                      : AppTheme.tertiaryText(isDarkMode),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: gymnasium.website != null ? () => _openWebsite() : null,
              icon: const Icon(Icons.language, size: 16),
              label: const Text(
                'サイト',
                style: TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: gymnasium.website != null
                    ? const Color(0xFFF59E0B)
                    : AppTheme.tertiaryText(isDarkMode),
                side: BorderSide(
                  color: gymnasium.website != null
                      ? const Color(0xFFF59E0B)
                      : AppTheme.tertiaryText(isDarkMode),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog() {
    // 詳細ダイアログ表示（今後実装）
  }

  String _getDistanceText() {
    if (userLocation == null) return '';
    
    final distance = DistanceCalculator.calculateDistanceToGymnasium(
      userLocation!.latitude,
      userLocation!.longitude,
      gymnasium,
    );
    
    return DistanceCalculator.formatDistance(distance);
  }

  /// 設備をバスケ優先でソートする
  List<String> _getSortedFacilities(List<String> facilities) {
    final List<String> sorted = List.from(facilities);
    sorted.sort((a, b) {
      // バスケを最優先
      if (a == GymnasiumFacilities.basketball) return -1;
      if (b == GymnasiumFacilities.basketball) return 1;
      
      // 体育館を2番目
      if (a == GymnasiumFacilities.gymnasium) return -1;
      if (b == GymnasiumFacilities.gymnasium) return 1;
      
      // その他は元の順序
      return 0;
    });
    return sorted;
  }

  void _makePhoneCall() async {
    if (gymnasium.phone != null) {
      final phoneUrl = Uri.parse('tel:${gymnasium.phone}');
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
      }
    }
  }

  void _openWebsite() async {
    if (gymnasium.website != null) {
      final websiteUrl = Uri.parse(gymnasium.website!);
      if (await canLaunchUrl(websiteUrl)) {
        await launchUrl(websiteUrl, mode: LaunchMode.externalApplication);
      }
    }
  }
}