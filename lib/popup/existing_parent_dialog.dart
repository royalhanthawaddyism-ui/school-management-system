import 'package:flutter/material.dart';
import 'package:hism_management_system/models/parent.dart';
import 'package:hism_management_system/services/parent_service.dart';

class ExistingParentDialog extends StatefulWidget {
  const ExistingParentDialog({super.key});

  @override
  State<ExistingParentDialog> createState() => _ExistingParentDialogState();
}

class _ExistingParentDialogState extends State<ExistingParentDialog> {
  final _searchController = TextEditingController();
  final ParentService _parentService = ParentService();
  List<Parent> _parents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadParents();
    _searchController.addListener(_loadParents);
  }

  @override
  void dispose() {
    _searchController.removeListener(_loadParents);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadParents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final query = _searchController.text.trim();
      final allParents = await _parentService.fetchAllParents();
      List<Parent> parents;
      if (query.isEmpty) {
        parents = allParents;
      } else {
        final q = query.toLowerCase();
        parents = allParents.where((p) {
          final name = (p.displayName ?? '').toLowerCase();
          final phone = (p.phone ?? '').toLowerCase();
          return name.contains(q) || phone.contains(q);
        }).toList();
      }
      if (!mounted) return;
      setState(() {
        _parents = parents;
      });
    } catch (_) {
      if (!mounted) return;
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Existing Parent'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          height: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search by name or phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _parents.isEmpty
                    ? const Center(child: Text('No matching parents found.'))
                    : ListView.separated(
                        itemCount: _parents.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final parent = _parents[index];
                          return ListTile(
                            title: Text(parent.displayName),
                            subtitle: Text(parent.phone),
                            onTap: () => Navigator.of(context).pop(parent),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
