import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../utils/constants.dart';
import '../../../components/custom_icon_button.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/cloudinary_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  BuildContext? get context => null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final authService = AuthService.to;

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Obx(() => CustomScrollView(
            slivers: [
              // Modern Header with Gradient
              SliverAppBar(
                expandedHeight: 280.h,
                floating: false,
                pinned: true,
                backgroundColor: Color(0xFF2E3192),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF2E3192),
                          Color(0xFF1B1464),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Profile Image with Modern Design
                            GestureDetector(
                              onTap: () => _showImagePickerOptions(context),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 120.w,
                                    height: 120.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 20,
                                          offset: Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: _buildProfileImage(
                                          authService.currentUser),
                                    ),
                                  ),
                                  if (authService.isSignedIn)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 36.w,
                                        height: 36.w,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFF8C00),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFFFF8C00)
                                                  .withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 20.w,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            16.verticalSpace,
                            // User Name and Email
                            if (authService.isSignedIn &&
                                authService.currentUser != null)
                              Column(
                                children: [
                                  Text(
                                    authService.currentUser!.name ?? 'User',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  8.verticalSpace,
                                  Text(
                                    authService.currentUser!.email ?? '',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (authService.isSignedIn)
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditProfileDialog(context),
                    ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () => Get.toNamed(Routes.BOOKING),
                  ),
                ],
              ),
              // Main Content
              if (authService.isSignedIn)
                SliverPadding(
                  padding: EdgeInsets.all(16.w),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Quick Stats Section
                      _buildQuickStats(authService, theme),
                      20.verticalSpace,
                      // Admin Dashboard Button (if admin)
                      if (authService.currentUser?.role == 'admin')
                        _buildAdminButton(),
                      if (authService.currentUser?.role == 'admin')
                        20.verticalSpace,
                      // Menu Options
                      _buildMenuOptions(theme),
                    ]),
                  ),
                )
              else
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/vectors/user.svg',
                          width: 200.w,
                          height: 200.w,
                        ),
                        32.verticalSpace,
                        Text(
                          'Sign In Required',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        16.verticalSpace,
                        Text(
                          'Please sign in to access your profile and manage your account',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: theme.hintColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        32.verticalSpace,
                        _buildAuthButtons(),
                      ],
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  // Quick Stats Section
  Widget _buildQuickStats(AuthService authService, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Statistics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          16.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Completed Jobs',
                authService.currentUser!.completedJobs?.toString() ?? '0',
                Icons.done_all,
                theme.primaryColor,
              ),
              _buildStatCard(
                'Rating',
                authService.currentUser!.rating?.toStringAsFixed(1) ?? '0.0',
                Icons.star,
                Colors.amber,
              ),
              _buildStatCard(
                'Member Since',
                _formatDate(authService.currentUser!.createdAt),
                Icons.calendar_today,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Admin Dashboard Button
  Widget _buildAdminButton() {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2E3192),
            Color(0xFF1B1464),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2E3192).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => Get.toNamed(Routes.ADMIN_DASHBOARD),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 24.w),
                12.horizontalSpace,
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Menu Options
  Widget _buildMenuOptions(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.person,
            title: 'Edit Profile',
            onTap: () => _showEditProfileDialog(context!),
            theme: theme,
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.history,
            title: 'Booking History',
            onTap: () => Get.toNamed(Routes.BOOKING_HISTORY),
            theme: theme,
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () => Get.toNamed(Routes.CALENDAR),
            theme: theme,
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.help,
            title: 'Help & Support',
            onTap: () => Get.toNamed(Routes.HOME),
            theme: theme,
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.logout,
            title: 'Sign Out',
            onTap: () => _showSignOutDialog(),
            theme: theme,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  // Menu Tile Helper
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : theme.primaryColor,
        size: 24.w,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : theme.textTheme.bodyLarge?.color,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.w,
        color: theme.hintColor,
      ),
      onTap: onTap,
    );
  }

  // Divider Helper
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 16.w,
      endIndent: 16.w,
    );
  }

  // Stat Card Helper
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.w),
          8.verticalSpace,
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          4.verticalSpace,
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: Get.theme.hintColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Auth Buttons for non-signed users
  Widget _buildAuthButtons() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2E3192),
                Color(0xFF1B1464),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF2E3192).withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () => Get.toNamed(Routes.LOGIN),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_circle, color: Colors.white, size: 24.w),
                    12.horizontalSpace,
                    Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        16.verticalSpace,
        Container(
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            border: Border.all(color: Get.theme.primaryColor),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () => Get.toNamed(Routes.SIGNUP),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add,
                        color: Get.theme.primaryColor, size: 24.w),
                    12.horizontalSpace,
                    Text(
                      'Create Account',
                      style: TextStyle(
                        color: Get.theme.primaryColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(UserModel? currentUser) {
    if (currentUser?.profileImage != null) {
      return CachedNetworkImage(
        imageUrl: currentUser!.profileImage!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(color: Get.theme.primaryColor),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: Icon(Icons.person, size: 40.w, color: Colors.grey[600]),
        ),
      );
    }

    // Fallback to Firebase photoURL or default
    final photoUrl = AuthService.to.user?.photoURL;
    if (photoUrl != null) {
      return CachedNetworkImage(
        imageUrl: photoUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(color: Get.theme.primaryColor),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: Icon(Icons.person, size: 40.w, color: Colors.grey[600]),
        ),
      );
    }

    // Default avatar
    return Container(
      color: Colors.grey[300],
      child: Icon(Icons.person, size: 40.w, color: Colors.grey[600]),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo';
    } else {
      return '${(difference.inDays / 365).floor()}y';
    }
  }

  void _showImagePickerOptions(BuildContext context) async {
    if (!AuthService.to.isSignedIn) {
      Get.snackbar(
        'Sign In Required',
        'Please sign in to upload profile picture',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final cloudinaryService = CloudinaryService.to;
    final pickedFile = await cloudinaryService.showImagePickerOptions(context);

    if (pickedFile != null) {
      final uploadedUrl = await cloudinaryService.uploadImage(
        pickedFile,
        folder: 'profile_images',
      );

      if (uploadedUrl != null) {
        // Update user profile with new image
        await controller.updateProfileImage(uploadedUrl);
      }
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        currentUser: AuthService.to.currentUser,
        onSave: (updatedUser) async {
          await controller.updateUserProfile(updatedUser);
        },
      ),
    );
  }

  void _showSignOutDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              AuthService.to.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  final UserModel? currentUser;
  final Function(UserModel) onSave;

  const EditProfileDialog({
    Key? key,
    this.currentUser,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.currentUser?.name ?? '');
    _phoneController =
        TextEditingController(text: widget.currentUser?.phone ?? '');
    _addressController =
        TextEditingController(text: widget.currentUser?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              20.verticalSpace,
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              16.verticalSpace,
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              16.verticalSpace,
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              24.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                  16.horizontalSpace,
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final updatedUser = widget.currentUser?.copyWith(
                          name: _nameController.text,
                          phone: _phoneController.text.isEmpty
                              ? null
                              : _phoneController.text,
                          address: _addressController.text.isEmpty
                              ? null
                              : _addressController.text,
                          updatedAt: DateTime.now(),
                        );

                        if (updatedUser != null) {
                          widget.onSave(updatedUser);
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
