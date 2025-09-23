// lib/screens/request_form/components/bbq_form.dart

import 'package:flutter/material.dart';

class BbqFormFields extends StatefulWidget {
  const BbqFormFields({super.key});

  @override
  BbqFormFieldsState createState() => BbqFormFieldsState();
}

class BbqFormFieldsState extends State<BbqFormFields> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _bbqDate;
  final _guestCountController = TextEditingController();
  final _bbqNotesController = TextEditingController();

  /// Public method to be called by the parent widget
  Map<String, dynamic>? getFormData() {
    if (_formKey.currentState!.validate()) {
      // Also validate that a date has been picked
      if (_bbqDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn ngày sử dụng BBQ')),
        );
        return null;
      }
      return {
        'bbqDate': _bbqDate?.toIso8601String(),
        'guestCount': _guestCountController.text,
        'bbqNotes': _bbqNotesController.text,
      };
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              _bbqDate == null
                  ? 'Chọn ngày sử dụng'
                  : 'Ngày: ${_bbqDate!.toLocal()}'.split(' ')[0],
            ),
            trailing: Icon(Icons.calendar_today),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _bbqDate = picked);
              }
            },
          ),
          TextFormField(
            controller: _guestCountController,
            decoration: InputDecoration(labelText: 'Số lượng khách'),
            keyboardType: TextInputType.number,
            validator:
                (value) =>
                    value!.isEmpty ? 'Vui lòng nhập số lượng khách' : null,
          ),
          TextFormField(
            controller: _bbqNotesController,
            decoration: InputDecoration(labelText: 'Ghi chú thêm'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _guestCountController.dispose();
    _bbqNotesController.dispose();
    super.dispose();
  }
}
