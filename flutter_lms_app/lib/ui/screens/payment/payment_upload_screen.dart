import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';

class PaymentUploadScreen extends StatefulWidget {
  final int courseId;

  const PaymentUploadScreen({super.key, required this.courseId});

  @override
  State<PaymentUploadScreen> createState() => _PaymentUploadScreenState();
}

class _PaymentUploadScreenState extends State<PaymentUploadScreen> {
  final List<String> _paymentMethods = [
    'Bank Transfer',
    'Sham Cash',
    'Syriatel Cash',
    'MTN Cash',
    'Hand Delivery',
  ];

  String? _selectedPaymentMethod;
  File? _selectedImage;
  String? _selectedImageName;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _selectedImageName = image.name;
      });
    }
  }

  Future<void> _uploadPayment() async {
    if (_selectedPaymentMethod == null || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select payment method and image')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        throw Exception('Not authenticated');
      }

      // Prepare form data
      final formData = FormData.fromMap({
        'course_id': widget.courseId,
        'payment_method': _selectedPaymentMethod,
        'receipt': await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: _selectedImageName,
        ),
      });

      // Send to API
      final response = await _dio.post(
        'https://your-api-url.com/api/enroll', // Replace with actual URL
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment uploaded successfully')),
        );
        Navigator.of(context).pop();
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Payment Receipt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Payment Method Dropdown
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              hint: const Text('Select Payment Method'),
              items: _paymentMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Payment Method',
              ),
            ),
            const SizedBox(height: 20),

            // Image Picker
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Select Receipt Image'),
            ),
            const SizedBox(height: 10),

            // Selected Image Preview
            if (_selectedImage != null)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 20),

            // Upload Button
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadPayment,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text('Upload Payment'),
            ),
          ],
        ),
      ),
    );
  }
}