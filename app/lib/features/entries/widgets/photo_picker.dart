// TogetherLog - Photo Picker Widget
// Multi-photo picker using image_picker package

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Photo Picker Widget
/// Allows selecting up to 6 photos from gallery or camera
class PhotoPicker extends StatefulWidget {
  const PhotoPicker({
    required this.onPhotosSelected,
    this.maxPhotos = 6,
    super.key,
  });

  final Function(List<Uint8List> photoBytes, List<String> fileNames)
      onPhotosSelected;
  final int maxPhotos;

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  final List<Uint8List> _photoBytes = [];
  final List<String> _fileNames = [];
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected photos grid
        if (_photoBytes.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _photoBytes.length,
              itemBuilder: (context, index) {
                return _buildPhotoThumbnail(index);
              },
            ),
          ),

        const SizedBox(height: 16),

        // Add photo buttons
        Row(
          children: [
            // Pick from gallery
            ElevatedButton.icon(
              onPressed: _photoBytes.length < widget.maxPhotos
                  ? _pickFromGallery
                  : null,
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            ),

            const SizedBox(width: 12),

            // Take photo with camera
            ElevatedButton.icon(
              onPressed: _photoBytes.length < widget.maxPhotos
                  ? _takePhoto
                  : null,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Photo count info
        Text(
          '${_photoBytes.length} of ${widget.maxPhotos} photos selected',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Build photo thumbnail with remove button
  Widget _buildPhotoThumbnail(int index) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          // Photo thumbnail
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              image: DecorationImage(
                image: MemoryImage(_photoBytes[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removePhoto(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pick photos from gallery
  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();

      if (images.isEmpty) return;

      // Limit to max photos
      final remainingSlots = widget.maxPhotos - _photoBytes.length;
      final photosToAdd = images.take(remainingSlots).toList();

      for (final image in photosToAdd) {
        final bytes = await image.readAsBytes();
        setState(() {
          _photoBytes.add(bytes);
          _fileNames.add(image.name);
        });
      }

      widget.onPhotosSelected(_photoBytes, _fileNames);

      if (images.length > remainingSlots) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Only $remainingSlots photos were added (max ${widget.maxPhotos} total)',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking photos: $e')),
        );
      }
    }
  }

  /// Take photo with camera
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      setState(() {
        _photoBytes.add(bytes);
        _fileNames.add(image.name);
      });

      widget.onPhotosSelected(_photoBytes, _fileNames);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  /// Remove a photo from the list
  void _removePhoto(int index) {
    setState(() {
      _photoBytes.removeAt(index);
      _fileNames.removeAt(index);
    });

    widget.onPhotosSelected(_photoBytes, _fileNames);
  }
}
