import 'package:flutter/material.dart';
import 'package:hism_management_system/models/parent.dart';

class NewParentDialog extends StatefulWidget {
  const NewParentDialog({super.key});

  @override
  State<NewParentDialog> createState() => _NewParentDialogState();
}

class _NewParentDialogState extends State<NewParentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final parent = Parent(
      id: '',
      fatherName: _fatherNameController.text.trim(),
      motherName: _motherNameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    Navigator.of(context).pop(parent);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Parent'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _fatherNameController,
                  decoration: const InputDecoration(
                    labelText: 'Father Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Father name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _motherNameController,
                  decoration: const InputDecoration(
                    labelText: 'Mother Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Save Parent')),
      ],
    );
  }
}
