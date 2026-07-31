import 'package:flutter/material.dart';
import 'package:hism_management_system/setup/setupControllers/year_controller.dart';
import 'package:hism_management_system/setup/setupModels/year.dart';

class YearList extends StatefulWidget {
  const YearList({super.key});

  @override
  State<YearList> createState() => _YearListState();
}

class _YearListState extends State<YearList> {
  final YearController _controller = YearController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerUpdate);
    _controller.loadYears();
  }

  void _onControllerUpdate() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _showYearFormDialog({Year? year}) {
    final textController = TextEditingController(text: year?.name ?? '');
    final formKey = GlobalKey<FormState>();
    final isEditing = year != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Year Level' : 'Add Year Level'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Year Level',
              hintText: 'e.g., Year 1, Year 2, Grade 1',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a valid year level';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final name = textController.text.trim();
              Navigator.pop(ctx);

              bool success;
              if (isEditing) {
                success = await _controller.editYear(year.id, name);
              } else {
                success = await _controller.addYear(name);
              }

              if (mounted && !success && _controller.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_controller.errorMessage!)),
                );
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Year year) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Year Level'),
        content: Text('Are you sure you want to delete "${year.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await _controller.deleteYear(year.id);
              if (mounted && !success && _controller.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_controller.errorMessage!)),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Years Setup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Year',
            onPressed: () => _showYearFormDialog(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null && _controller.years.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _controller.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _controller.loadYears,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_controller.years.isEmpty) {
            return const Center(
              child: Text('No year levels found. Tap + to add one.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _controller.loadYears,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _controller.years.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final year = _controller.years[index];

                final _ = year.name.isNotEmpty
                    ? year.name.substring(0, 1).toUpperCase()
                    : 'Y';

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        year.name.isNotEmpty ? year.name[0].toUpperCase() : 'Y',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    title: Text(
                      year.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          tooltip: 'Edit',
                          onPressed: () => _showYearFormDialog(year: year),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          tooltip: 'Delete',
                          onPressed: () => _confirmDelete(year),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
