// lib/screens/request_form/components/chuyen_do_form.dart

import 'package:flutter/material.dart';

class ChuyenDoFormFields extends StatefulWidget {
  const ChuyenDoFormFields({super.key});

  @override
  ChuyenDoFormFieldsState createState() => ChuyenDoFormFieldsState();
}

class ChuyenDoFormFieldsState extends State<ChuyenDoFormFields> {
  final _formKey = GlobalKey<FormState>();
  final _itemDescriptionController = TextEditingController();
  final _floorController = TextEditingController();

  /// Public method to be called by the parent widget
  Map<String, dynamic>? getFormData() {
    if (_formKey.currentState!.validate()) {
      return {
        'itemDescription': _itemDescriptionController.text,
        'floor': _floorController.text,
      };
    }
    return null; // Return null if validation fails
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _itemDescriptionController,
            decoration: InputDecoration(labelText: 'Mô tả đồ cần chuyển'),
            validator: (value) => value!.isEmpty ? 'Vui lòng mô tả đồ' : null,
          ),
          TextFormField(
            controller: _floorController,
            decoration: InputDecoration(labelText: 'Tầng gửi - Tầng nhận'),
            validator: (value) => value!.isEmpty ? 'Vui lòng nhập tầng' : null,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _itemDescriptionController.dispose();
    _floorController.dispose();
    super.dispose();
  }
}
