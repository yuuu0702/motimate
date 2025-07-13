import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../models/user_location_model.dart';
import '../services/user_location_service.dart';
import '../themes/app_theme.dart';
import '../core/theme/theme_controller.dart';

/// 拠点登録・編集画面
/// 
/// プライバシーを重視したエリア単位での拠点登録
class UserLocationScreen extends ConsumerStatefulWidget {
  const UserLocationScreen({
    super.key,
    this.editLocation,
  });

  final UserLocationModel? editLocation;

  @override
  ConsumerState<UserLocationScreen> createState() => _UserLocationScreenState();
}

class _UserLocationScreenState extends ConsumerState<UserLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  LocationType _selectedType = LocationType.home;
  String _selectedArea = '金沢駅周辺';
  bool _isPrimary = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.editLocation != null) {
      final location = widget.editLocation!;
      _nameController.text = location.name;
      _selectedType = location.type;
      _selectedArea = location.address.replaceAll('エリア', '');
      _isPrimary = location.isPrimary;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(isDarkMode),
      appBar: _buildAppBar(isDarkMode),
      body: _buildBody(isDarkMode),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: AppTheme.cardColor(isDarkMode),
      elevation: 0,
      title: Text(
        widget.editLocation != null ? '拠点を編集' : '拠点を追加',
        style: TextStyle(
          color: AppTheme.primaryText(isDarkMode),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back,
          color: AppTheme.primaryText(isDarkMode),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPrivacyNote(isDarkMode),
            const SizedBox(height: 24),
            _buildNameField(isDarkMode),
            const SizedBox(height: 20),
            _buildTypeSelector(isDarkMode),
            const SizedBox(height: 20),
            _buildAreaSelector(isDarkMode),
            const SizedBox(height: 20),
            _buildMapPreview(isDarkMode),
            const SizedBox(height: 20),
            _buildPrimaryToggle(isDarkMode),
            const SizedBox(height: 32),
            _buildActionButtons(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyNote(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: const Color(0xFF10B981),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'プライバシー保護',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '具体的な住所ではなく、エリア単位で拠点を管理します。\nチームメンバーには大まかな位置のみ共有されます。',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryText(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '拠点名',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '例: 自宅エリア、職場エリア',
            hintStyle: TextStyle(color: AppTheme.tertiaryText(isDarkMode)),
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '拠点名を入力してください';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeSelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '拠点タイプ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: LocationType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF667eea) 
                      : AppTheme.containerBackground(isDarkMode),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF667eea) 
                        : AppTheme.borderColor(isDarkMode),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTypeIcon(type),
                      size: 16,
                      color: isSelected 
                          ? Colors.white 
                          : AppTheme.primaryText(isDarkMode),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      type.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected 
                            ? Colors.white 
                            : AppTheme.primaryText(isDarkMode),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAreaSelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'エリア選択',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.containerBackground(isDarkMode),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor(isDarkMode),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedArea,
              items: UserLocationService.kanazawaAreas.map((area) {
                return DropdownMenuItem<String>(
                  value: area['name'] as String,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area['name'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryText(isDarkMode),
                        ),
                      ),
                      Text(
                        area['description'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.tertiaryText(isDarkMode),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedArea = value);
                }
              },
              dropdownColor: AppTheme.cardColor(isDarkMode),
              style: TextStyle(color: AppTheme.primaryText(isDarkMode)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview(bool isDarkMode) {
    final location = UserLocationService.getLocationByAreaName(_selectedArea);
    if (location == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'エリア確認',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText(isDarkMode),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor(isDarkMode),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: gmaps.GoogleMap(
              initialCameraPosition: gmaps.CameraPosition(
                target: gmaps.LatLng(location.latitude, location.longitude),
                zoom: 14.0,
              ),
              markers: {
                gmaps.Marker(
                  markerId: const gmaps.MarkerId('selected_area'),
                  position: gmaps.LatLng(location.latitude, location.longitude),
                  infoWindow: gmaps.InfoWindow(
                    title: _selectedArea,
                    snippet: 'このエリア周辺',
                  ),
                ),
              },
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryToggle(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.containerBackground(isDarkMode),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor(isDarkMode),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star_border,
            color: _isPrimary 
                ? const Color(0xFFF59E0B)
                : AppTheme.tertiaryText(isDarkMode),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'メイン拠点に設定',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryText(isDarkMode),
                  ),
                ),
                Text(
                  'おすすめ体育館の計算で優先的に使用されます',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.tertiaryText(isDarkMode),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPrimary,
            onChanged: (value) => setState(() => _isPrimary = value),
            activeColor: const Color(0xFF667eea),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: AppTheme.borderColor(isDarkMode)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'キャンセル',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.primaryText(isDarkMode),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.editLocation != null ? '更新' : '追加',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon(LocationType type) {
    switch (type) {
      case LocationType.home:
        return Icons.home;
      case LocationType.work:
        return Icons.work;
      case LocationType.school:
        return Icons.school;
      case LocationType.other:
        return Icons.place;
    }
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final location = UserLocationService.getLocationByAreaName(_selectedArea);
      if (location == null) {
        throw Exception('選択されたエリアの位置情報が見つかりません');
      }

      final userLocation = UserLocationModel(
        id: widget.editLocation?.id ?? '',
        userId: UserLocationService.instance.currentUserId ?? '',
        name: _nameController.text.trim(),
        address: '${_selectedArea}エリア',
        location: location,
        type: _selectedType,
        isPrimary: _isPrimary,
        createdAt: widget.editLocation?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (widget.editLocation != null) {
        success = await UserLocationService.instance.updateUserLocation(userLocation);
      } else {
        success = await UserLocationService.instance.addUserLocation(userLocation);
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        _showErrorSnackBar('拠点の保存に失敗しました');
      }
    } catch (e) {
      _showErrorSnackBar('エラーが発生しました: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}