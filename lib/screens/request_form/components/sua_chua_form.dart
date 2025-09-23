// lib/screens/request_form/components/sua_chua_form.dart

import 'package:flutter/material.dart';

class SuaChuaFormFields extends StatefulWidget {
  const SuaChuaFormFields({super.key});

  @override
  SuaChuaFormFieldsState createState() => SuaChuaFormFieldsState();
}

class SuaChuaFormFieldsState extends State<SuaChuaFormFields> {
  final _formKey = GlobalKey<FormState>();
  String? _repairType;
  String? _urgency;
  final _issueDescriptionController = TextEditingController();

  /// Public method to be called by the parent widget
  Map<String, dynamic>? getFormData() {
    if (_formKey.currentState!.validate()) {
      return {
        'repairType': _repairType,
        'urgency': _urgency,
        'issueDescription': _issueDescriptionController.text,
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
          DropdownButtonFormField<String>(
            value: _repairType,
            decoration: InputDecoration(labelText: 'Loại sửa chữa'),
            items: [
              DropdownMenuItem(value: 'Dien', child: Text('Điện')),
              DropdownMenuItem(value: 'Nuoc', child: Text('Nước')),
              DropdownMenuItem(value: 'Khac', child: Text('Khác')),
            ],
            onChanged: (value) => setState(() => _repairType = value),
            validator:
                (value) => value == null ? 'Vui lòng chọn loại sửa chữa' : null,
          ),
          DropdownButtonFormField<String>(
            value: _urgency,
            decoration: InputDecoration(labelText: 'Mức độ khẩn cấp'),
            items: [
              DropdownMenuItem(value: 'Thuong', child: Text('Thường')),
              DropdownMenuItem(value: 'Gap', child: Text('Gấp')),
              DropdownMenuItem(value: 'CucGap', child: Text('Cực gấp')),
            ],
            onChanged: (value) => setState(() => _urgency = value),
            validator: (value) => value == null ? 'Vui lòng chọn mức độ' : null,
          ),
          TextFormField(
            controller: _issueDescriptionController,
            decoration: InputDecoration(labelText: 'Mô tả vấn đề'),
            validator:
                (value) => value!.isEmpty ? 'Vui lòng mô tả vấn đề' : null,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _issueDescriptionController.dispose();
    super.dispose();
  }
}
