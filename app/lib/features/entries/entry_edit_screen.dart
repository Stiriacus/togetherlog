// TogetherLog - Entry Edit Screen
// Edit existing entry's highlight text, tags, and location

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/entry.dart';
import 'providers/entries_providers.dart';
import 'widgets/tag_selector.dart';
import 'widgets/location_editor.dart';

/// Entry edit screen
/// Allows editing highlight text, tags, and location
/// Photos cannot be edited (limitation for V1)
class EntryEditScreen extends ConsumerStatefulWidget {
  const EntryEditScreen({
    required this.entryId,
    super.key,
  });

  final String entryId;

  @override
  ConsumerState<EntryEditScreen> createState() => _EntryEditScreenState();
}

class _EntryEditScreenState extends ConsumerState<EntryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _highlightTextController;

  DateTime? _eventDate;
  List<String> _selectedTagIds = [];
  Location? _location;
  bool _isUpdating = false;
  bool _isLoading = true;

  @override
  void dispose() {
    _highlightTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entryAsync = ref.watch(entryDetailProvider(widget.entryId));
    final tagsAsync = ref.watch(tagsListProvider);

    // Initialize form with entry data
    entryAsync.whenData((entry) {
      if (_isLoading) {
        _highlightTextController = TextEditingController(
          text: entry.highlightText,
        );
        _eventDate = entry.eventDate;
        _selectedTagIds = List.from(entry.tagIds);
        _location = entry.location;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Entry'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: entryAsync.when(
        data: (entry) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Note about photo editing
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.infoMuted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.rSm),
                    border: Border.all(color: AppColors.infoMuted),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: AppColors.infoMuted),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Photos cannot be edited. Create a new entry to change photos.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.infoMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

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
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
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

                // Update Button
                FilledButton.icon(
                  onPressed: _isUpdating ? null : _handleUpdate,
                  icon: _isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.antiqueWhite,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isUpdating ? 'Updating...' : 'Update Entry'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: AppIconSize.extraLarge,
                color: AppColors.errorMuted,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Failed to load entry: $error',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
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
        '${_eventDate?.day}/${_eventDate?.month}/${_eventDate?.year}',
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
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _eventDate = picked;
      });
    }
  }

  /// Handle update entry
  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final notifier = ref.read(entryNotifierProvider.notifier);
      await notifier.updateEntry(
        entryId: widget.entryId,
        eventDate: _eventDate,
        highlightText: _highlightTextController.text.trim(),
        tagIds: _selectedTagIds,
        location: _location,
      );

      if (mounted) {
        // Invalidate entry detail to refresh
        ref.invalidate(entryDetailProvider(widget.entryId));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry updated successfully'),
          ),
        );

        // Navigate back
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update entry: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }
}
