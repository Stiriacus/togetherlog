// TogetherLog - Edit Log Dialog
// Dialog for editing an existing log

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/log.dart';
import '../providers/logs_providers.dart';

/// Dialog for editing an existing log
class EditLogDialog extends ConsumerStatefulWidget {
  const EditLogDialog({
    required this.log,
    super.key,
  });

  final Log log;

  @override
  ConsumerState<EditLogDialog> createState() => _EditLogDialogState();
}

class _EditLogDialogState extends ConsumerState<EditLogDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedType;

  final List<String> _logTypes = ['Couple', 'Family', 'Solo'];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.log.name);
    _selectedType = widget.log.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Log'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Log Name',
                hintText: 'Our Adventures',
                prefixIcon: Icon(Icons.edit),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                if (value.trim().length > 100) {
                  return 'Name must be less than 100 characters';
                }
                return null;
              },
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Type dropdown
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Log Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: _logTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: _isLoading ? null : (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a type';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),

        // Save button
        FilledButton(
          onPressed: _isLoading ? null : _handleSave,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  /// Handle save changes action
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if anything changed
    final nameChanged = _nameController.text.trim() != widget.log.name;
    final typeChanged = _selectedType != widget.log.type;

    if (!nameChanged && !typeChanged) {
      // No changes, just close dialog
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(logsNotifierProvider.notifier);
      await notifier.updateLog(
        id: widget.log.id,
        name: nameChanged ? _nameController.text.trim() : null,
        type: typeChanged ? _selectedType : null,
      );

      // Invalidate logs list to refresh
      ref.invalidate(logsListProvider);

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update log: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
