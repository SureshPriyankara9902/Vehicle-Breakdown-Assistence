import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:user/global/global.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import '../splashScreen/splash_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();

  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _profileImageUrl;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Add these variables to store phone data
  String _selectedCountryCode = 'IN'; // Default country code
  String _completePhoneNumber = ''; // This will store the complete phone number with country code

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      DatabaseEvent event = await userRef.child(firebaseAuth.currentUser!.uid).once();
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          nameTextEditingController.text = data['name'] ?? '';
          // Handle phone number - extract country code and number
          String savedPhone = data['phone'] ?? '';
          String savedCountryCode = data['countryCode'] ?? 'IN';

          phoneTextEditingController.text = savedPhone;
          _selectedCountryCode = savedCountryCode;
          _completePhoneNumber = data['completePhoneNumber'] ?? '';

          addressTextEditingController.text = data['address'] ?? '';
          emailTextEditingController.text = data['email'] ?? '';
          _profileImageUrl = data['profileImage'];
        });
      }
    } catch (e) {
      _showSnackBar("Error loading profile: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Update Profile Picture',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() => _image = File(image.path));
        await _uploadImage();
      }
    } catch (e) {
      _showSnackBar("Error picking image: $e", isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() => _isLoading = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${firebaseAuth.currentUser!.uid}.jpg');

      await ref.putFile(_image!);
      final url = await ref.getDownloadURL();

      await userRef.child(firebaseAuth.currentUser!.uid).update({
        'profileImage': url,
      });

      setState(() => _profileImageUrl = url);
      _showSnackBar("Profile image updated successfully!");
    } catch (e) {
      _showSnackBar("Error uploading image: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await userRef.child(firebaseAuth.currentUser!.uid).update({
        'name': nameTextEditingController.text.trim(),
        'phone': phoneTextEditingController.text.trim(),
        'countryCode': _selectedCountryCode, // Save selected country code
        'completePhoneNumber': _completePhoneNumber, // Save complete phone number
        'address': addressTextEditingController.text.trim(),
      });

      setState(() => _isEditing = false);
      _showSnackBar("Profile updated successfully!");
    } catch (e) {
      _showSnackBar("Error updating profile: $e", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      setState(() => _isLoading = true);

      // Sign out from Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      // Sign out from Firebase
      await firebaseAuth.signOut();

      // Navigate to splash screen
      if (mounted) {  // Check if widget is still mounted
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (c) => SplashScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {  // Check if widget is still mounted before showing error
        _showSnackBar("Error signing out: $e", isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,  // Allow dismissing by tapping outside
      builder: (BuildContext context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);  // Close dialog first
              _signOut();  // Then perform sign out
            },
            child: Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: _isLoading
          ? _buildLoadingWidget(darkTheme)
          : Stack(
        children: [
          Container(
            height: screenHeight * 0.4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: darkTheme
                    ? [Colors.grey[900]!, Colors.grey[800]!]
                    : [Colors.blue[700]!, Colors.blue[500]!],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(darkTheme),
                  _buildProfileCard(darkTheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(bool darkTheme) {
    return Container(
      color: darkTheme ? Colors.grey[900] : Colors.white,
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading profile...',
              style: TextStyle(
                color: darkTheme ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool darkTheme) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _isEditing
                  ? IconButton(
                icon: Icon(Icons.check, color: Colors.white),
                onPressed: _updateProfile,
              )
                  : IconButton(
                icon: Icon(Icons.edit, color: Colors.white),
                onPressed: () => setState(() => _isEditing = true),
              ),
            ],
          ),
          SizedBox(height: 20),
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Hero(
                  tag: 'profileImage',
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: darkTheme ? Colors.grey[800] : Colors.grey[200],
                    child: ClipOval(
                      child: _image != null
                          ? Image.file(_image!, fit: BoxFit.cover, width: 120, height: 120)
                          : _profileImageUrl != null
                          ? CachedNetworkImage(
                        imageUrl: _profileImageUrl!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                      )
                          : Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(
            nameTextEditingController.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            emailTextEditingController.text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(bool darkTheme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: darkTheme ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkTheme ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              _buildInfoField(
                label: 'Full Name',
                controller: nameTextEditingController,
                icon: Icons.person,
                enabled: _isEditing,
                darkTheme: darkTheme,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildInfoField(
                label: 'Email',
                controller: emailTextEditingController,
                icon: Icons.email,
                enabled: false,
                darkTheme: darkTheme,
                onTap: () => _showSnackBar('Email cannot be changed'),
              ),
              SizedBox(height: 16),
              // Updated phone field with proper country code handling
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: darkTheme ? Colors.grey[800] : Colors.grey[100],
                ),
                child: IntlPhoneField(
                  controller: phoneTextEditingController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: darkTheme ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    filled: true,
                    fillColor: darkTheme ? Colors.grey[800] : Colors.grey[100],
                    errorStyle: TextStyle(color: Colors.red),
                  ),
                  initialCountryCode: _selectedCountryCode, // Use saved country code
                  onChanged: (phone) {
                    // Update both country code and complete phone number
                    setState(() {
                      _selectedCountryCode = phone.countryCode;
                      _completePhoneNumber = phone.completeNumber;
                    });
                  },
                  onCountryChanged: (country) {
                    // Handle country change
                    setState(() {
                      _selectedCountryCode = country.code;
                    });
                  },
                  validator: (phone) {
                    if (phone == null || phone.number.isEmpty) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16),
              _buildInfoField(
                label: 'Address',
                controller: addressTextEditingController,
                icon: Icons.location_on,
                maxLines: 1,
                enabled: _isEditing,
                darkTheme: darkTheme,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your address';
                  }
                  if (value.trim().length < 5) {
                    return 'Address must be at least 5 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              if (!_isEditing)
                ElevatedButton(
                  onPressed: _isLoading ? null : _showSignOutDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Signing Out...',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                      : Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => setState(() => _isEditing = false),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Text('Save'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    bool darkTheme = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: darkTheme ? Colors.grey[800] : Colors.grey[100],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        style: TextStyle(
          color: darkTheme ? Colors.white : Colors.black87,
        ),
        validator: validator,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: darkTheme ? Colors.grey[400] : Colors.grey[600],
          ),
          prefixIcon: Icon(
            icon,
            color: enabled ? Colors.blue : Colors.grey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: darkTheme ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: darkTheme ? Colors.grey[800] : Colors.grey[100],
          errorStyle: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}