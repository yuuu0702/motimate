import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/gymnasium_model.dart';
import '../services/location_service.dart';
import '../themes/app_theme.dart';

/// 体育館地図表示ウィジェット
/// 
/// Google Maps上に体育館の位置をマーカーで表示し、
/// ユーザーの現在位置も表示する
class GymnasiumMap extends ConsumerStatefulWidget {
  const GymnasiumMap({
    super.key,
    required this.gymnasiums,
    required this.isDarkMode,
    this.onGymnasiumTapped,
  });

  final List<GymnasiumModel> gymnasiums;
  final bool isDarkMode;
  final Function(GymnasiumModel)? onGymnasiumTapped;

  @override
  ConsumerState<GymnasiumMap> createState() => _GymnasiumMapState();
}

class _GymnasiumMapState extends ConsumerState<GymnasiumMap> {
  final Completer<gmaps.GoogleMapController> _mapController = Completer();
  final Set<gmaps.Marker> _markers = {};
  LatLng? _userLocation;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didUpdateWidget(GymnasiumMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gymnasiums != widget.gymnasiums) {
      _updateGymnasiumMarkers();
    }
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    _updateGymnasiumMarkers();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = await LocationService.instance.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = location ?? LocationService.kanazawaCenterLocation;
          _isLoadingLocation = false;
        });
        _updateUserLocationMarker();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userLocation = LocationService.kanazawaCenterLocation;
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _updateUserLocationMarker() {
    if (_userLocation == null) return;

    final userMarker = gmaps.Marker(
      markerId: const gmaps.MarkerId('user_location'),
      position: gmaps.LatLng(_userLocation!.latitude, _userLocation!.longitude),
      icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueBlue),
      infoWindow: const gmaps.InfoWindow(
        title: '現在位置',
        snippet: 'あなたの位置',
      ),
    );

    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'user_location');
      _markers.add(userMarker);
    });
  }

  void _updateGymnasiumMarkers() {
    final gymnasiumMarkers = widget.gymnasiums.map((gymnasium) {
      return gmaps.Marker(
        markerId: gmaps.MarkerId(gymnasium.id),
        position: gmaps.LatLng(gymnasium.location.latitude, gymnasium.location.longitude),
        icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueOrange),
        infoWindow: gmaps.InfoWindow(
          title: gymnasium.name,
          snippet: _getDistanceText(gymnasium),
        ),
        onTap: () {
          widget.onGymnasiumTapped?.call(gymnasium);
        },
      );
    }).toSet();

    setState(() {
      // 体育館マーカーのみ更新（ユーザー位置マーカーは保持）
      _markers.removeWhere((marker) => marker.markerId.value != 'user_location');
      _markers.addAll(gymnasiumMarkers);
    });
  }

  String _getDistanceText(GymnasiumModel gymnasium) {
    if (_userLocation == null) return gymnasium.address;
    
    final distance = LocationService.instance.calculateDistanceToGymnasium(
      _userLocation!,
      gymnasium,
    );
    
    if (distance < 1.0) {
      return '${(distance * 1000).round()}m • ${gymnasium.address}';
    } else {
      return '${distance.toStringAsFixed(1)}km • ${gymnasium.address}';
    }
  }

  Future<void> _animateToLocation(LatLng location, {double zoom = 15.0}) async {
    final controller = await _mapController.future;
    await controller.animateCamera(
      gmaps.CameraUpdate.newCameraPosition(
        gmaps.CameraPosition(
          target: gmaps.LatLng(location.latitude, location.longitude),
          zoom: zoom,
        ),
      ),
    );
  }

  Future<void> _fitAllMarkers() async {
    if (_markers.isEmpty) return;

    final controller = await _mapController.future;
    
    // すべてのマーカーを含む境界を計算
    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;

    for (final marker in _markers) {
      minLat = marker.position.latitude < minLat ? marker.position.latitude : minLat;
      maxLat = marker.position.latitude > maxLat ? marker.position.latitude : maxLat;
      minLng = marker.position.longitude < minLng ? marker.position.longitude : minLng;
      maxLng = marker.position.longitude > maxLng ? marker.position.longitude : maxLng;
    }

    await controller.animateCamera(
      gmaps.CameraUpdate.newLatLngBounds(
        gmaps.LatLngBounds(
          southwest: gmaps.LatLng(minLat, minLng),
          northeast: gmaps.LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return Container(
        color: AppTheme.containerBackground(widget.isDarkMode),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('位置情報を取得中...'),
            ],
          ),
        ),
      );
    }

    final initialLocation = _userLocation ?? LocationService.kanazawaCenterLocation;

    return Stack(
      children: [
        gmaps.GoogleMap(
          mapType: gmaps.MapType.normal,
          initialCameraPosition: gmaps.CameraPosition(
            target: gmaps.LatLng(initialLocation.latitude, initialLocation.longitude),
            zoom: 12.0,
          ),
          markers: _markers,
          myLocationEnabled: false, // カスタムマーカーを使用
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (gmaps.GoogleMapController controller) {
            _mapController.complete(controller);
            // 少し遅延させてからすべてのマーカーにフィット
            Future.delayed(const Duration(milliseconds: 500), () {
              _fitAllMarkers();
            });
          },
        ),
        
        // 右下のコントロールボタン
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              // 現在位置ボタン
              FloatingActionButton(
                heroTag: "current_location",
                mini: true,
                backgroundColor: AppTheme.cardColor(widget.isDarkMode),
                foregroundColor: AppTheme.primaryText(widget.isDarkMode),
                onPressed: () {
                  if (_userLocation != null) {
                    _animateToLocation(_userLocation!);
                  }
                },
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 8),
              
              // すべて表示ボタン
              FloatingActionButton(
                heroTag: "fit_all",
                mini: true,
                backgroundColor: AppTheme.cardColor(widget.isDarkMode),
                foregroundColor: AppTheme.primaryText(widget.isDarkMode),
                onPressed: _fitAllMarkers,
                child: const Icon(Icons.fullscreen),
              ),
            ],
          ),
        ),

        // 左上の凡例
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor(widget.isDarkMode),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: widget.isDarkMode ? 0.3 : 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'バスケ体育館',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryText(widget.isDarkMode),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '現在位置',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryText(widget.isDarkMode),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}