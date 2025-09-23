// lib/screens/request_form_screen.dart

import 'package:flutter/material.dart';

// Import user data
import '../../components/current_user_info.dart';

// Import the new form components
import 'request_form/components/bbq_form.dart';
import 'request_form/components/chuyen_do_form.dart';
import 'request_form/components/sua_chua_form.dart';

class ServiceRegistrationForm extends StatefulWidget {
  @override
  _ServiceRegistrationFormState createState() =>
      _ServiceRegistrationFormState();
}

class _ServiceRegistrationFormState extends State<ServiceRegistrationForm> {
  // Key for the main form (common fields)
  final _formKey = GlobalKey<FormState>();

  // Keys for the child form components
  final _chuyenDoFormKey = GlobalKey<ChuyenDoFormFieldsState>();
  final _suaChuaFormKey = GlobalKey<SuaChuaFormFieldsState>();
  final _bbqFormKey = GlobalKey<BbqFormFieldsState>();

  // Common fields controllers and state
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String? selectedApartment;
  String? serviceType;

  @override
  void initState() {
    super.initState();
    nameController.text = currentUserInfo.name;
    phoneController.text = currentUserInfo.phone;
    if (currentUserInfo.apartment_id.isNotEmpty) {
      selectedApartment = currentUserInfo.apartment_id.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng ký dịch vụ')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Common Fields ---
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Tên cư dân'),
                validator:
                    (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              DropdownButtonFormField<String>(
                value: selectedApartment,
                decoration: InputDecoration(labelText: 'Số căn hộ'),
                items:
                    currentUserInfo.apartment_id
                        .map(
                          (apartment) => DropdownMenuItem(
                            value: apartment,
                            child: Text(apartment),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => selectedApartment = value),
                validator:
                    (value) => value == null ? 'Vui lòng chọn căn hộ' : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Vui lòng nhập số điện thoại' : null,
              ),
              SizedBox(height: 16),

              // --- Service Type Dropdown ---
              DropdownButtonFormField<String>(
                value: serviceType,
                decoration: InputDecoration(labelText: 'Loại dịch vụ'),
                items: [
                  DropdownMenuItem(value: 'ChuyenDo', child: Text('Chuyển đồ')),
                  DropdownMenuItem(value: 'SuaChua', child: Text('Sửa chữa')),
                  DropdownMenuItem(value: 'BBQ', child: Text('Mượn khu BBQ')),
                ],
                onChanged: (value) => setState(() => serviceType = value),
                validator:
                    (value) =>
                        value == null ? 'Vui lòng chọn loại dịch vụ' : null,
              ),
              SizedBox(height: 16),

              // --- Dynamic Service-Specific Fields ---
              if (serviceType == 'ChuyenDo')
                ChuyenDoFormFields(key: _chuyenDoFormKey),
              if (serviceType == 'SuaChua')
                SuaChuaFormFields(key: _suaChuaFormKey),
              if (serviceType == 'BBQ') BbqFormFields(key: _bbqFormKey),

              SizedBox(height: 16),

              // --- Final Common Field and Button ---
              TextFormField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'Ghi chú chung'),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Đăng ký'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    // 1. Validate the main form
    if (!_formKey.currentState!.validate()) {
      return; // Stop if common fields are invalid
    }

    // 2. Get data from the active child component form
    Map<String, dynamic>? serviceData;
    if (serviceType == 'ChuyenDo') {
      serviceData = _chuyenDoFormKey.currentState?.getFormData();
    } else if (serviceType == 'SuaChua') {
      serviceData = _suaChuaFormKey.currentState?.getFormData();
    } else if (serviceType == 'BBQ') {
      serviceData = _bbqFormKey.currentState?.getFormData();
    }

    // Stop if the child form is invalid
    if (serviceData == null && serviceType != null) {
      return;
    }

    // 3. Collect all data
    Map<String, dynamic> finalData = {
      'name': nameController.text,
      'apartment': selectedApartment,
      'phone': phoneController.text,
      'serviceType': serviceType,
      'notes': notesController.text,
    };

    // 4. Merge service-specific data
    if (serviceData != null) {
      finalData.addAll(serviceData);
    }

    // TODO: Gửi data lên backend
    print('Form data: $finalData');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đăng ký thành công!')));
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.dispose();
  }
}
