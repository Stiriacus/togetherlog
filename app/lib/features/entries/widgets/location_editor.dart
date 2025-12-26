// TogetherLog - Location Editor Widget
// Allows editing location with geocoding search

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/entry.dart';

/// Location Editor Widget
/// Allows searching and selecting locations using Nominatim geocoding
class LocationEditor extends StatefulWidget {
  const LocationEditor({
    this.initialLocation,
    required this.onLocationChanged,
    super.key,
  });

  final Location? initialLocation;
  final Function(Location?) onLocationChanged;

  @override
  State<LocationEditor> createState() => _LocationEditorState();
}

class _LocationEditorState extends State<LocationEditor> {
  late TextEditingController _locationController;
  bool _hasLocation = false;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _hasLocation = widget.initialLocation != null;
    _locationController = TextEditingController(
      text: widget.initialLocation?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _dio.close();
    super.dispose();
  }

  /// Shorten location name to first 2-3 meaningful parts
  /// Example: "Eiffel Tower, 5, Avenue Anatole France, Quartier du Gros-Caillou, 7th Arrondissement, Paris, Ile-de-France, Metropolitan France, 75007, France"
  /// Becomes: "Eiffel Tower, 5, Avenue Anatole France"
  String _shortenLocationName(String fullName) {
    final parts = fullName.split(',').map((p) => p.trim()).toList();

    // Take first 3 parts (usually: landmark/building, street number, street name)
    if (parts.length > 3) {
      return parts.sublist(0, 3).join(', ');
    }

    return fullName;
  }

  /// Search for locations using Nominatim geocoding API
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          'addressdetails': 1,
        },
        options: Options(
          headers: {
            'User-Agent': 'TogetherLog/1.0',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(response.data as List);
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enable/disable location
        SwitchListTile(
          title: const Text('Add Location'),
          subtitle: Text(
            _hasLocation
                ? 'Location will be displayed with the entry'
                : 'No location for this entry',
          ),
          value: _hasLocation,
          onChanged: (value) {
            setState(() {
              _hasLocation = value;
              if (!value) {
                _locationController.clear();
                _searchResults = [];
                widget.onLocationChanged(null);
              }
            });
          },
        ),

        // Location search field
        if (_hasLocation) ...[
          const SizedBox(height: 8),

          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Search Location',
              hintText: 'e.g., Paris, Eiffel Tower',
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _searchLocation(_locationController.text),
                    ),
            ),
            onSubmitted: _searchLocation,
          ),

          const SizedBox(height: 8),

          // Search results list
          if (_searchResults.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.antiqueWhite,
                borderRadius: BorderRadius.circular(AppRadius.rSm),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a location:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._searchResults.map((result) {
                    final fullDisplayName = result['display_name'] as String;
                    final lat = double.tryParse(result['lat'].toString());
                    final lng = double.tryParse(result['lon'].toString());

                    // Shorten display name to first 2-3 meaningful parts
                    final shortDisplayName = _shortenLocationName(fullDisplayName);

                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.location_on, size: 20),
                      title: Text(
                        shortDisplayName,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        fullDisplayName,
                        style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        setState(() {
                          _locationController.text = shortDisplayName;
                          _searchResults = [];
                        });

                        final location = Location(
                          lat: lat,
                          lng: lng,
                          displayName: shortDisplayName,
                          isUserOverridden: true,
                        );

                        widget.onLocationChanged(location);
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Help text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.infoMuted.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.rSm),
              border: Border.all(color: AppColors.infoMuted),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: AppIconSize.small,
                  color: AppColors.infoMuted,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Type a location name and press Enter or tap the search icon',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.infoMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
