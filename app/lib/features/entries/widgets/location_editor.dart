// TogetherLog - Location Editor Widget
// Allows editing location display name with override flag

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/entry.dart';

/// Location Editor Widget
/// Allows manual editing of location display name
/// Supports marking location as user-overridden
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
  bool _isUserOverridden = false;

  @override
  void initState() {
    super.initState();
    _hasLocation = widget.initialLocation != null;
    _locationController = TextEditingController(
      text: widget.initialLocation?.displayName ?? '',
    );
    _isUserOverridden = widget.initialLocation?.isUserOverridden ?? false;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
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
                _isUserOverridden = false;
                widget.onLocationChanged(null);
              } else {
                // Notify with empty location when enabled
                _notifyLocationChanged();
              }
            });
          },
        ),

        // Location input field
        if (_hasLocation) ...[
          const SizedBox(height: 8),

          TextField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location',
              hintText: 'e.g., Paris, Eiffel Tower',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _locationController.clear();
                  _notifyLocationChanged();
                },
              ),
            ),
            onChanged: (_) => _notifyLocationChanged(),
          ),

          const SizedBox(height: 8),

          // User override info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isUserOverridden
                  ? AppColors.infoMuted.withValues(alpha: 0.1)
                  : AppColors.softApricot.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.rSm),
              border: Border.all(
                color: _isUserOverridden
                    ? AppColors.infoMuted
                    : AppColors.inputBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isUserOverridden
                      ? Icons.edit_location
                      : Icons.location_on,
                  size: AppIconSize.small,
                  color: _isUserOverridden
                      ? AppColors.infoMuted
                      : AppColors.inactiveIcon,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isUserOverridden
                        ? 'Manual location - won\'t be overwritten by GPS data'
                        : 'Location can be auto-detected from photo GPS data',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isUserOverridden
                          ? AppColors.infoMuted
                          : AppColors.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Mark as override checkbox
          CheckboxListTile(
            title: const Text('Manual override'),
            subtitle: const Text(
              'Lock this location and prevent automatic updates',
            ),
            value: _isUserOverridden,
            onChanged: (value) {
              setState(() {
                _isUserOverridden = value ?? false;
                _notifyLocationChanged();
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ],
    );
  }

  /// Notify parent of location changes
  void _notifyLocationChanged() {
    if (!_hasLocation || _locationController.text.isEmpty) {
      widget.onLocationChanged(null);
      return;
    }

    final location = Location(
      lat: null, // GPS coordinates not set manually
      lng: null,
      displayName: _locationController.text,
      isUserOverridden: _isUserOverridden,
    );

    widget.onLocationChanged(location);
  }
}
