// TogetherLog - Entry Create Screen
// Create new entry with photos, tags, location, and highlight text

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/entry.dart';
import 'providers/entries_providers.dart';
import 'widgets/photo_picker.dart';
import 'widgets/tag_selector.dart';
import 'widgets/location_editor.dart';

/// Entry creation screen
class EntryCreateScreen extends ConsumerStatefulWidget {
  const EntryCreateScreen({
    required this.logId,
    super.key,
  });

  final String logId;

  @override
  ConsumerState<EntryCreateScreen> createState() => _EntryCreateScreenState();
}

class _EntryCreateScreenState extends ConsumerState<EntryCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _highlightTextController = TextEditingController();

  DateTime _eventDate = DateTime.now();
  List<Uint8List> _photoBytes = [];
  List<String> _photoFileNames = [];
  List<String> _selectedTagIds = [];
  Location? _location;
  bool _isCreating = false;

  @override
  void dispose() {
    _highlightTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Entry'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Event Date Picker
            _buildDatePicker(),

            const SizedBox(height: 24),

            // Highlight Text Field
            TextFormField(
              controller: _highlightTextController,
              decoration: const InputDecoration(
                labelText: 'Highlight Text',
                hintText: 'Describe this memory...',
                border: OutlineInputBorder(),
                helperText: 'A short description of this memory',
              ),
              maxLines: 3,
              maxLength: 500,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Photo Picker
            Text(
              'Photos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            PhotoPicker(
              onPhotosSelected: (bytes, fileNames) {
                setState(() {
                  _photoBytes = bytes;
                  _photoFileNames = fileNames;
                });
              },
            ),

            const SizedBox(height: 24),

            // Tags
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            tagsAsync.when(
              data: (tags) => TagSelector(
                availableTags: tags,
                selectedTagIds: _selectedTagIds,
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedTagIds = newSelection;
                  });
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text(
                'Failed to load tags: $error',
                style: const TextStyle(color: AppColors.errorMuted),
              ),
            ),

            const SizedBox(height: 24),

            // Location
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LocationEditor(
              initialLocation: _location,
              onLocationChanged: (newLocation) {
                setState(() {
                  _location = newLocation;
                });
              },
            ),

            const SizedBox(height: 32),

            // Create Button
            FilledButton.icon(
              onPressed: _isCreating ? null : _handleCreate,
              icon: _isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.antiqueWhite,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isCreating ? 'Creating...' : 'Create Entry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build date picker widget
  Widget _buildDatePicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today),
      title: const Text('Event Date'),
      subtitle: Text(
        '${_eventDate.day}/${_eventDate.month}/${_eventDate.year}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: TextButton(
        onPressed: _pickDate,
        child: const Text('Change'),
      ),
    );
  }

  /// Pick event date
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  /// Handle create entry
  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final notifier = ref.read(entryNotifierProvider.notifier);
      await notifier.createEntry(
        logId: widget.logId,
        eventDate: _eventDate,
        highlightText: _highlightTextController.text.trim(),
        tagIds: _selectedTagIds,
        photoBytes: _photoBytes.isNotEmpty ? _photoBytes : null,
        photoFileNames: _photoFileNames.isNotEmpty ? _photoFileNames : null,
        location: _location,
      );

      if (mounted) {
        // Invalidate entries list to refresh
        ref.invalidate(entriesListProvider(widget.logId));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry created successfully'),
          ),
        );

        // Navigate back to entries list
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create entry: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}
