import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../utils/constants.dart';
import '../../main.dart' show authService, firebaseService;
import '../auth/signin_screen.dart';
import '../onboarding/edit_profile_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool darkModeEnabled = false;
  bool _isLoading = false;
  final User? _user = FirebaseAuth.instance.currentUser;
  String? _displayName;
  String? _email;
  String? _photoURL;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_user != null) {
      final userData = await firebaseService.getDocument('users', _user!.uid);
      if (mounted) {
        setState(() {
          _displayName = userData.data()?['displayName'] ?? _user!.displayName ?? 'User';
          _email = userData.data()?['email'] ?? _user!.email;
          _photoURL = userData.data()?['photoURL'] ?? _user!.photoURL;
        });
      }
    }
  }

  Future<void> _updateProfilePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final File imageFile = File(image.path);
      final String fileName = 'profile_${_user!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = FirebaseStorage.instance.ref().child('profile_photos/$fileName');
      
      // Upload image
      await storageRef.putFile(imageFile);
      final String downloadURL = await storageRef.getDownloadURL();

      // Update user profile
      await _user!.updatePhotoURL(downloadURL);
      await firebaseService.updateDocument('users', _user!.uid, {
        'photoURL': downloadURL,
      });

      if (mounted) {
        setState(() {
          _photoURL = downloadURL;
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to update profile photo. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    try {
      await authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to logout. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Error',
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.urbanist(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.urbanist(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: isDesktop ? 24.0 : 16.0,
        leading: Padding(
          padding: EdgeInsets.only(left: isDesktop ? 24.0 : 16.0),
          child: Icon(Icons.menu_book, color: AppColors.primary, size: 28),
        ),
        title: Text(
          'Account',
          style: GoogleFonts.urbanist(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {
              // Implement extra menu actions if needed
            },
          ),
          SizedBox(width: isDesktop ? 24 : 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24.0 : 16.0,
                vertical: isDesktop ? 24.0 : 16.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildUserSection(),
                    const SizedBox(height: 16),
                    _buildListTile(
                      icon: Icons.person_outline,
                      iconColor: Colors.blue[200],
                      title: 'Edit Profile',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                        );
                        if (result == true) {
                          _loadUserData();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildListTile(
                      icon: Icons.notifications_none_rounded,
                      iconColor: Colors.red[200],
                      title: 'Notification',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        // Navigate to notification settings screen
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildListTile(
                      icon: Icons.settings_outlined,
                      iconColor: Colors.purple[200],
                      title: 'Preferences',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        // Navigate to preferences screen
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildListTile(
                      icon: Icons.security_outlined,
                      iconColor: Colors.green[100],
                      title: 'Security',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        // Navigate to security screen
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildListTile(
                      icon: Icons.language,
                      iconColor: Colors.orange[200],
                      title: 'Language',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'English (US)',
                            style: GoogleFonts.urbanist(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                      onTap: () {
                        // Navigate to language settings screen
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildListTile(
                      icon: Icons.remove_red_eye_outlined,
                      iconColor: Colors.blue[100],
                      title: 'Dark Mode',
                      trailing: Switch(
                        value: darkModeEnabled,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            darkModeEnabled = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildListTile(
                      icon: Icons.help_outline,
                      iconColor: Colors.teal[100],
                      title: 'Help Center',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        // Navigate to help center
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildListTile(
                      icon: Icons.info_outline,
                      iconColor: Colors.orange[100],
                      title: 'About Erabook',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        // Navigate to about app screen
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildListTile(
                      icon: Icons.logout,
                      iconColor: Colors.red[100],
                      title: 'Logout',
                      titleColor: Colors.red,
                      onTap: _logout,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserSection() {
    return Row(
      children: [
        GestureDetector(
          onTap: _updateProfilePhoto,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[200],
                backgroundImage: _photoURL != null
                    ? NetworkImage(_photoURL!)
                    : null,
                child: _photoURL == null
                    ? const Icon(Icons.person_outline, size: 32, color: Colors.grey)
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _displayName ?? 'User',
                style: GoogleFonts.urbanist(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _email ?? '',
                style: GoogleFonts.urbanist(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.black87),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
            if (result == true) {
              _loadUserData();
            }
          },
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    Color? iconColor,
    required String title,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor ?? Colors.grey, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.urbanist(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Colors.black87,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
