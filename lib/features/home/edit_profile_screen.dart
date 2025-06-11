import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const EditProfileScreen({super.key, this.initialData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController educationLevelController;
  late TextEditingController classGradeController;
  late TextEditingController phoneController;
  File? _imageFile;
  String? _uploadedImageUrl;
  bool _isSaving = false;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.initialData?['name'] ?? "");
    educationLevelController = TextEditingController(text: widget.initialData?['educationLevel'] ?? "");
    classGradeController = TextEditingController(text: widget.initialData?['classGrade'] ?? "");
    phoneController = TextEditingController(text: widget.initialData?['phone'] ?? "");
    _uploadedImageUrl = widget.initialData?['profileImageUrl'];
    super.initState();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 65);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<String?> _uploadProfileImage(String uid) async {
    if (_imageFile == null) return _uploadedImageUrl;
    final ref = FirebaseStorage.instance.ref().child('profile_pics/$uid.jpg');
    try {
      if (!await _imageFile!.exists()) {
        throw Exception("Selected image file does not exist.");
      }
      final uploadTask = ref.putFile(_imageFile!);
      final snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        return await ref.getDownloadURL();
      } else {
        throw Exception("Image upload failed: ${snapshot.state}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload image: $e")),
        );
      }
      print("Upload error: $e");
      return _uploadedImageUrl;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not signed in");

      final imageUrl = await _uploadProfileImage(uid);

      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final docSnapshot = await docRef.get();

      final Map<String, dynamic> toUpdate = {
        'name': nameController.text.trim(),
        'educationLevel': educationLevelController.text.trim(),
        'classGrade': classGradeController.text.trim(),
        'phone': phoneController.text.trim(),
        'profileImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (!docSnapshot.exists) {
        toUpdate['createdAt'] = FieldValue.serverTimestamp();
      }

      await docRef.set(toUpdate, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving profile: $e")),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarRadius = 52.0;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty
                          ? NetworkImage(_uploadedImageUrl!)
                          : const AssetImage('assets/images/profile_icon.png'))
                      as ImageProvider,
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.purple),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (val) =>
                val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: educationLevelController,
                decoration:
                const InputDecoration(labelText: "Educational Level"),
                validator: (val) =>
                val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: classGradeController,
                decoration: const InputDecoration(labelText: "Class/Grade"),
                validator: (val) =>
                val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}