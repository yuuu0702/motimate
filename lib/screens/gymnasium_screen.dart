import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../themes/app_theme.dart';
import '../core/theme/theme_controller.dart';
import '../data/gymnasium_data.dart';
import '../models/gymnasium_model.dart';
import '../widgets/cards/gymnasium_card.dart';
import '../services/location_service.dart';
import '../utils/distance_calculator.dart';
// import '../widgets/gymnasium_map.dart';  // マップ機能は無効化（Google Maps不使用）

/// 体育館一覧画面
/// 
/// 金沢市の利用可能な体育館を表示し、
/// 地図表示、お気に入り機能、おすすめ機能を提供
class GymnasiumScreen extends ConsumerStatefulWidget {
  const GymnasiumScreen({super.key});

  @override
  ConsumerState<GymnasiumScreen> createState() => _GymnasiumScreenState();
}

class _GymnasiumScreenState extends ConsumerState<GymnasiumScreen> {
  String _selectedFacility = GymnasiumFacilities.basketball; // デフォルトでバスケに絞り込み
  String _searchQuery = '';
  LatLng? _userLocation;
  bool _sortByDistance = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await LocationService.instance.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = position;
        });
      }
    } catch (e) {
      // 位置情報取得失敗時はデフォルト位置を使用
      if (mounted) {
        setState(() {
          _userLocation = LocationService.kanazawaCenterLocation;
        });
      }
    }
  }

  @override
  void dispose() {
    // TabControllerを削除したため、disposeも不要
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(isDarkMode),
      appBar: _buildAppBar(isDarkMode),
      body: Column(
        children: [
          _buildSearchAndFilter(isDarkMode),
          Expanded(
            child: _buildListView(isDarkMode),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: AppTheme.cardColor(isDarkMode),
      elevation: 0,
      title: Text(
        'バスケ体育館検索',
        style: TextStyle(
          color: AppTheme.primaryText(isDarkMode),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // お気に入り一覧表示
            _showFavorites();
          },
          icon: Icon(
            Icons.favorite_border,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
        IconButton(
          onPressed: () {
            // フィルター設定
            _showFilterDialog();
          },
          icon: Icon(
            Icons.tune,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _sortByDistance = !_sortByDistance;
            });
          },
          icon: Icon(
            _sortByDistance ? Icons.near_me : Icons.near_me_outlined,
            color: _sortByDistance 
                ? const Color(0xFF667eea) 
                : AppTheme.primaryText(isDarkMode),
          ),
          tooltip: _sortByDistance ? '距離順ソートOFF' : '距離順ソートON',
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.cardColor(isDarkMode),
      child: Column(
        children: [
          // 検索バー
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: _userLocation != null 
              ? 'バスケ体育館名で検索... (現在位置取得済み)'
              : 'バスケ体育館名で検索...',
              hintStyle: TextStyle(color: AppTheme.tertiaryText(isDarkMode)),
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.tertiaryText(isDarkMode),
              ),
              filled: true,
              fillColor: AppTheme.containerBackground(isDarkMode),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: TextStyle(color: AppTheme.primaryText(isDarkMode)),
          ),
          const SizedBox(height: 12),
          
          // バスケ関連設備フィルター
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFacilityChip('すべて', '', isDarkMode),
                _buildFacilityChip(GymnasiumFacilities.basketball, GymnasiumFacilities.basketball, isDarkMode),
                _buildFacilityChip(GymnasiumFacilities.gymnasium, GymnasiumFacilities.gymnasium, isDarkMode),
                _buildFacilityChip(GymnasiumFacilities.changingroom, GymnasiumFacilities.changingroom, isDarkMode),
                _buildFacilityChip(GymnasiumFacilities.parking, GymnasiumFacilities.parking, isDarkMode),
                _buildFacilityChip(GymnasiumFacilities.airconditioning, GymnasiumFacilities.airconditioning, isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityChip(String label, String facility, bool isDarkMode) {
    final isSelected = _selectedFacility == facility;
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppTheme.primaryText(isDarkMode),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFacility = selected ? facility : '';
          });
        },
        backgroundColor: AppTheme.containerBackground(isDarkMode),
        selectedColor: const Color(0xFF667eea),
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF667eea)
              : AppTheme.borderColor(isDarkMode),
        ),
      ),
    );
  }

  // TabBarは削除 - マップ機能を無効化したため

  Widget _buildListView(bool isDarkMode) {
    final filteredGymnasiums = _getFilteredGymnasiums();
    
    if (filteredGymnasiums.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }
    
    return Column(
      children: [
        // 距離順ソート時の情報表示
        if (_sortByDistance && _userLocation != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF667eea).withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(
                  Icons.near_me,
                  size: 16,
                  color: Color(0xFF667eea),
                ),
                const SizedBox(width: 8),
                Text(
                  '現在位置から近い順に表示中',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryText(isDarkMode),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (filteredGymnasiums.isNotEmpty && _userLocation != null)
                  Text(
                    '最寄り: ${DistanceCalculator.formatDistance(
                      DistanceCalculator.calculateDistanceToGymnasium(
                        _userLocation!.latitude,
                        _userLocation!.longitude,
                        filteredGymnasiums.first,
                      )
                    )}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.secondaryText(isDarkMode),
                    ),
                  ),
              ],
            ),
          ),
        
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredGymnasiums.length,
            itemBuilder: (context, index) {
              final isNearest = _sortByDistance && index == 0 && _userLocation != null;
              return Column(
                children: [
                  if (isNearest)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF667eea).withValues(alpha: 0.1),
                            const Color(0xFF764ba2).withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF667eea).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFF667eea),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '最寄りの体育館',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryText(isDarkMode),
                            ),
                          ),
                        ],
                      ),
                    ),
                  GymnasiumCard(
                    gymnasium: filteredGymnasiums[index],
                    isDarkMode: isDarkMode,
                    userLocation: _userLocation,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // マップビューは削除 - Google Maps機能を無効化したため

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.tertiaryText(isDarkMode),
          ),
          const SizedBox(height: 16),
          Text(
            '該当するバスケ体育館が見つかりません',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryText(isDarkMode),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '検索条件を変更してみてください',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.tertiaryText(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  List<GymnasiumModel> _getFilteredGymnasiums() {
    // バスケ利用可能な体育館のみを取得
    List<GymnasiumModel> gymnasiums = GymnasiumData.gymnasiums
        .where((gym) => gym.facilities.contains(GymnasiumFacilities.basketball))
        .toList();
    
    // 検索クエリでフィルタリング
    if (_searchQuery.isNotEmpty) {
      gymnasiums = gymnasiums
          .where((gym) =>
              gym.name.contains(_searchQuery) ||
              gym.address.contains(_searchQuery))
          .toList();
    }
    
    // 追加設備でフィルタリング（バスケは必須なので、それ以外の設備でフィルタ）
    if (_selectedFacility.isNotEmpty && _selectedFacility != GymnasiumFacilities.basketball) {
      gymnasiums = gymnasiums
          .where((gym) => gym.facilities.contains(_selectedFacility))
          .toList();
    }
    
    // 距離順ソートが有効な場合
    if (_sortByDistance && _userLocation != null) {
      final gymnasiumsWithDistance = DistanceCalculator.sortGymnasiumsByDistance(
        _userLocation!.latitude,
        _userLocation!.longitude,
        gymnasiums,
      );
      gymnasiums = gymnasiumsWithDistance.map((gwd) => gwd.gymnasium).toList();
    }
    
    return gymnasiums;
  }

  void _showFavorites() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('お気に入り'),
        content: const Text('お気に入り機能は今後実装予定です'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('フィルター設定'),
        content: const Text('詳細フィルター機能は今後実装予定です'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  // 重複したメソッドを削除
}