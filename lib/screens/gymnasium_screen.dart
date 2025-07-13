import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../themes/app_theme.dart';
import '../core/theme/theme_controller.dart';
import '../data/gymnasium_data.dart';
import '../models/gymnasium_model.dart';
import '../widgets/cards/gymnasium_card.dart';
import '../widgets/gymnasium_map.dart';
import '../services/location_service.dart';

/// 体育館一覧画面
/// 
/// 金沢市の利用可能な体育館を表示し、
/// 地図表示、お気に入り機能、おすすめ機能を提供
class GymnasiumScreen extends ConsumerStatefulWidget {
  const GymnasiumScreen({super.key});

  @override
  ConsumerState<GymnasiumScreen> createState() => _GymnasiumScreenState();
}

class _GymnasiumScreenState extends ConsumerState<GymnasiumScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFacility = GymnasiumFacilities.basketball; // デフォルトでバスケに絞り込み
  String _searchQuery = '';
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    final location = await LocationService.instance.getCurrentPosition();
    if (mounted) {
      setState(() {
        _userLocation = location;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          _buildTabBar(isDarkMode),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListView(isDarkMode),
                _buildMapView(isDarkMode),
              ],
            ),
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
              hintText: 'バスケ体育館名で検索...',
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

  Widget _buildTabBar(bool isDarkMode) {
    return Container(
      color: AppTheme.cardColor(isDarkMode),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF667eea),
        labelColor: const Color(0xFF667eea),
        unselectedLabelColor: AppTheme.tertiaryText(isDarkMode),
        tabs: const [
          Tab(
            icon: Icon(Icons.list),
            text: 'リスト',
          ),
          Tab(
            icon: Icon(Icons.map),
            text: '地図',
          ),
        ],
      ),
    );
  }

  Widget _buildListView(bool isDarkMode) {
    final filteredGymnasiums = _getFilteredGymnasiums();
    
    if (filteredGymnasiums.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredGymnasiums.length,
      itemBuilder: (context, index) {
        return GymnasiumCard(
          gymnasium: filteredGymnasiums[index],
          isDarkMode: isDarkMode,
          userLocation: _userLocation,
        );
      },
    );
  }

  Widget _buildMapView(bool isDarkMode) {
    final filteredGymnasiums = _getFilteredGymnasiums();
    
    return GymnasiumMap(
      gymnasiums: filteredGymnasiums,
      isDarkMode: isDarkMode,
      onGymnasiumTapped: (gymnasium) => _showGymnasiumDetail(gymnasium),
    );
  }

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

  void _showGymnasiumDetail(GymnasiumModel gymnasium) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(gymnasium.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('住所: ${gymnasium.address}'),
            if (gymnasium.phone != null) 
              Text('電話: ${gymnasium.phone}'),
            if (gymnasium.openingHours != null)
              Text('営業時間: ${gymnasium.openingHours}'),
            if (gymnasium.description != null) ...[
              const SizedBox(height: 8),
              Text(gymnasium.description!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}