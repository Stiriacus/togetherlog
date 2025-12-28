// TogetherLog - Entry Create Screen
// Create new entry with photos, tags, location, and highlight text

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/layouts/authenticated_shell.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_icons.dart';
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

    return AuthenticatedShell(
      currentRoute: '/logs/${widget.logId}/entries/create',
      child: Scaffold(
        backgroundColor: AppColors.antiqueWhite,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header zone - structural anchor for title
            Container(
              padding: const EdgeInsets.only(
                top: AppSpacing.lg,
                bottom: AppSpacing.md,
                left: AppSpacing.md,
                right: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.divider,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(AppIcons.close),
                    onPressed: () => context.pop(),
                    tooltip: 'Close',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'New Entry',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),

            // Breathing space
            const SizedBox(height: AppSpacing.xl),

            // Primary content
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      children: [
                        // Event Date Picker
                        _buildDatePicker(),

                        const SizedBox(height: AppSpacing.lg),

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

                        const SizedBox(height: AppSpacing.lg),

                        // Photo Picker
                        Text(
                          'Photos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        PhotoPicker(
                          onPhotosSelected: (bytes, fileNames) {
                            setState(() {
                              _photoBytes = bytes;
                              _photoFileNames = fileNames;
                            });
                          },
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Tags
                        Text(
                          'Tags',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
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

                        const SizedBox(height: AppSpacing.lg),

                        // Location
                        Text(
                          'Location',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        LocationEditor(
                          initialLocation: _location,
                          onLocationChanged: (newLocation) {
                            setState(() {
                              _location = newLocation;
                            });
                          },
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Create Entry Buttons
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _isCreating ? null : () => _handleCreate(openEditor: true),
                                icon: _isCreating
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.antiqueWhite,
                                        ),
                                      )
                                    : const Icon(AppIcons.edit),
                                label: Text(_isCreating ? 'Creating...' : 'Open Editor'),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isCreating ? null : () => _handleCreate(openEditor: false),
                                icon: const Icon(AppIcons.book),
                                label: const Text('Scrapbook Page'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Open Editor to customize your page, or create a Scrapbook Page automatically',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
      leading: const Icon(AppIcons.calendar),
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
  Future<void> _handleCreate({required bool openEditor}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final notifier = ref.read(entryNotifierProvider.notifier);
      final newEntry = await notifier.createEntry(
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

        if (openEditor) {
          // Show dialog asking user how to start
          final shouldAutoGenerate = await _showEditorStartDialog();
          if (shouldAutoGenerate != null && mounted) {
            // Navigate to page editor
            context.go('/logs/${widget.logId}/entries/${newEntry.id}/page-editor');
          } else if (mounted) {
            context.pop();
          }
        } else {
          // TODO: Generate Smart Page automatically here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entry created! Smart Page generated automatically.'),
            ),
          );

          // Navigate to scrapbook
          context.go('/logs/${widget.logId}/scrapbook');
        }
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

  /// Show dialog asking how to start editor
  Future<bool?> _showEditorStartDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How would you like to start?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              value: true,
              groupValue: true,
              onChanged: (value) => Navigator.of(context).pop(true),
              title: const Text('Auto-generate Smart Page'),
              subtitle: const Text('Let TogetherLog create a beautiful layout for you'),
            ),
            RadioListTile<bool>(
              value: false,
              groupValue: true,
              onChanged: (value) => Navigator.of(context).pop(false),
              title: const Text('Start with blank canvas'),
              subtitle: const Text('Build your page from scratch'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
