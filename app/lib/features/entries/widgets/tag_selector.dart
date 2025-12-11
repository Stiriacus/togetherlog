// TogetherLog - Tag Selector Widget
// Multi-select tag picker with chips UI

import 'package:flutter/material.dart';
import '../../../data/models/tag.dart';

/// Tag Selector Widget
/// Displays all available tags organized by category
/// Allows multi-select using chip-based UI
class TagSelector extends StatefulWidget {
  const TagSelector({
    required this.availableTags,
    required this.selectedTagIds,
    required this.onSelectionChanged,
    super.key,
  });

  final List<Tag> availableTags;
  final List<String> selectedTagIds;
  final Function(List<String>) onSelectionChanged;

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  late List<String> _selectedTagIds;

  @override
  void initState() {
    super.initState();
    _selectedTagIds = List.from(widget.selectedTagIds);
  }

  @override
  Widget build(BuildContext context) {
    // Group tags by category
    final tagsByCategory = <String, List<Tag>>{};
    for (final tag in widget.availableTags) {
      tagsByCategory.putIfAbsent(tag.category, () => []).add(tag);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selection count
        Text(
          '${_selectedTagIds.length} tag${_selectedTagIds.length != 1 ? 's' : ''} selected',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),

        const SizedBox(height: 12),

        // Tags by category
        ...tagsByCategory.entries.map((entry) {
          return _buildCategorySection(entry.key, entry.value);
        }),
      ],
    );
  }

  /// Build a category section with tags
  Widget _buildCategorySection(String category, List<Tag> tags) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Text(
            category,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Tags chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) => _buildTagChip(tag)).toList(),
          ),
        ],
      ),
    );
  }

  /// Build a single tag chip
  Widget _buildTagChip(Tag tag) {
    final isSelected = _selectedTagIds.contains(tag.id);

    return FilterChip(
      label: Text(tag.name),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedTagIds.add(tag.id);
          } else {
            _selectedTagIds.remove(tag.id);
          }
        });

        widget.onSelectionChanged(_selectedTagIds);
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }
}

/// Compact Tag Selector Dialog
/// Shows tags in a dialog for selection
class TagSelectorDialog extends StatelessWidget {
  const TagSelectorDialog({
    required this.availableTags,
    required this.selectedTagIds,
    super.key,
  });

  final List<Tag> availableTags;
  final List<String> selectedTagIds;

  @override
  Widget build(BuildContext context) {
    List<String> tempSelectedIds = List.from(selectedTagIds);

    return AlertDialog(
      title: const Text('Select Tags'),
      content: SizedBox(
        width: double.maxFinite,
        child: TagSelector(
          availableTags: availableTags,
          selectedTagIds: tempSelectedIds,
          onSelectionChanged: (newSelection) {
            tempSelectedIds = newSelection;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, tempSelectedIds),
          child: const Text('Done'),
        ),
      ],
    );
  }

  /// Show tag selector dialog
  static Future<List<String>?> show({
    required BuildContext context,
    required List<Tag> availableTags,
    required List<String> selectedTagIds,
  }) {
    return showDialog<List<String>>(
      context: context,
      builder: (context) => TagSelectorDialog(
        availableTags: availableTags,
        selectedTagIds: selectedTagIds,
      ),
    );
  }
}
