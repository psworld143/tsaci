import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserService _userService = UserService();
  List<UserModel> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _userService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddUserDialog() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'manager';
    bool isLoading = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusXl),
          ),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modern Header with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppStyles.space6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppStyles.radiusXl),
                      topRight: Radius.circular(AppStyles.radiusXl),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppStyles.space4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space3),
                      Text(
                        'Add New User',
                        style: AppStyles.headingMd.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space1),
                      Text(
                        'Create a new user account',
                        style: AppStyles.bodySm.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content - Scrollable
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppStyles.space6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name Field
                        Text(
                          'Personal Information',
                          style: AppStyles.labelLg.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppStyles.space3),
                        AppTextField(
                          controller: nameController,
                          label: 'Full Name',
                          prefixIcon: Icons.person_outline,
                          hint: 'Enter full name',
                        ),
                        const SizedBox(height: AppStyles.space4),
                        AppTextField(
                          controller: emailController,
                          label: 'Email Address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          hint: 'user@example.com',
                        ),
                        const SizedBox(height: AppStyles.space4),
                        AppTextField(
                          controller: passwordController,
                          label: 'Password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          hint: 'Minimum 6 characters',
                        ),

                        const SizedBox(height: AppStyles.space6),

                        // Role Selection
                        Text(
                          'User Role & Permissions',
                          style: AppStyles.labelLg.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: AppStyles.space3),

                        // Role Cards
                        ..._buildRoleCards(selectedRole, (role) {
                          setState(() => selectedRole = role);
                        }),
                      ],
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.all(AppStyles.space6),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppStyles.radiusXl),
                      bottomRight: Radius.circular(AppStyles.radiusXl),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Cancel',
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context, false),
                          variant: ButtonVariant.outline,
                          fullWidth: true,
                        ),
                      ),
                      const SizedBox(width: AppStyles.space3),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          text: 'Add User',
                          icon: Icons.person_add,
                          loading: isLoading,
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (nameController.text.isEmpty ||
                                      emailController.text.isEmpty ||
                                      passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please fill all fields'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }

                                  if (passwordController.text.length < 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Password must be at least 6 characters',
                                        ),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => isLoading = true);
                                  try {
                                    await _userService.createUser(
                                      name: nameController.text,
                                      email: emailController.text,
                                      password: passwordController.text,
                                      role: selectedRole,
                                    );
                                    Navigator.pop(context, true);
                                  } catch (e) {
                                    setState(() => isLoading = false);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                          fullWidth: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == true) {
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: AppStyles.space2),
                Text('User added successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusMd),
            ),
          ),
        );
      }
    }
  }

  List<Widget> _buildRoleCards(
    String selectedRole,
    Function(String) onRoleSelected,
  ) {
    final roles = [
      {
        'value': 'admin',
        'title': 'Administrator',
        'description': 'Full system access and control',
        'icon': Icons.admin_panel_settings,
        'color': AppColors.error,
      },
      {
        'value': 'production_manager',
        'title': 'Production Manager',
        'description': 'Manage production operations & reports',
        'icon': Icons.factory,
        'color': AppColors.primary,
      },
      {
        'value': 'inventory_officer',
        'title': 'Inventory Officer',
        'description': 'Manage stock and inventory control',
        'icon': Icons.warehouse,
        'color': AppColors.warning,
      },
      {
        'value': 'qa_officer',
        'title': 'Quality Assurance Officer',
        'description': 'Quality control and testing',
        'icon': Icons.verified,
        'color': AppColors.success,
      },
      {
        'value': 'worker',
        'title': 'Worker/Operator',
        'description': 'Basic operational tasks',
        'icon': Icons.engineering,
        'color': AppColors.info,
      },
    ];

    return roles.map((role) {
      final isSelected = selectedRole == role['value'];
      return Padding(
        padding: const EdgeInsets.only(bottom: AppStyles.space3),
        child: InkWell(
          onTap: () => onRoleSelected(role['value'] as String),
          borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppStyles.space4),
            decoration: BoxDecoration(
              color: isSelected
                  ? (role['color'] as Color).withOpacity(0.1)
                  : AppColors.gray50,
              borderRadius: BorderRadius.circular(AppStyles.radiusMd),
              border: Border.all(
                color: isSelected
                    ? (role['color'] as Color)
                    : AppColors.gray300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppStyles.space2),
                  decoration: BoxDecoration(
                    color: (role['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppStyles.radiusSm),
                  ),
                  child: Icon(
                    role['icon'] as IconData,
                    color: role['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppStyles.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role['title'] as String,
                        style: AppStyles.labelLg.copyWith(
                          color: isSelected
                              ? (role['color'] as Color)
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space1),
                      Text(
                        role['description'] as String,
                        style: AppStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: role['color'] as Color,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _showEditUserDialog(UserModel user) async {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    String selectedRole = user.role;
    bool isLoading = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusXl),
          ),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modern Header with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppStyles.space6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppStyles.radiusXl),
                      topRight: Radius.circular(AppStyles.radiusXl),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppStyles.space4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space3),
                      Text(
                        'Edit User',
                        style: AppStyles.headingMd.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space1),
                      Text(
                        'Update user information and role',
                        style: AppStyles.bodySm.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content - Scrollable
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppStyles.space6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info
                        Text(
                          'Personal Information',
                          style: AppStyles.labelLg.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(height: AppStyles.space3),
                        AppTextField(
                          controller: nameController,
                          label: 'Full Name',
                          prefixIcon: Icons.person_outline,
                          hint: 'Enter full name',
                        ),
                        const SizedBox(height: AppStyles.space4),
                        AppTextField(
                          controller: emailController,
                          label: 'Email Address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          hint: 'user@example.com',
                        ),

                        const SizedBox(height: AppStyles.space6),

                        // Role Selection
                        Text(
                          'User Role & Permissions',
                          style: AppStyles.labelLg.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                        const SizedBox(height: AppStyles.space3),

                        // Role Cards
                        ..._buildRoleCards(selectedRole, (role) {
                          setState(() => selectedRole = role);
                        }),
                      ],
                    ),
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.all(AppStyles.space6),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppStyles.radiusXl),
                      bottomRight: Radius.circular(AppStyles.radiusXl),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Cancel',
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context, false),
                          variant: ButtonVariant.outline,
                          fullWidth: true,
                        ),
                      ),
                      const SizedBox(width: AppStyles.space3),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          text: 'Update User',
                          icon: Icons.check,
                          loading: isLoading,
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (nameController.text.isEmpty ||
                                      emailController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please fill all fields'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => isLoading = true);
                                  try {
                                    await _userService.updateUser(
                                      userId: user.userId,
                                      name: nameController.text,
                                      email: emailController.text,
                                      role: selectedRole,
                                    );
                                    Navigator.pop(context, true);
                                  } catch (e) {
                                    setState(() => isLoading = false);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                          fullWidth: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == true) {
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: AppStyles.space2),
                Text('User updated successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusMd),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showResetPasswordDialog(UserModel user) async {
    final passwordController = TextEditingController();
    bool isLoading = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusXl),
          ),
          child: Container(
            width: 450,
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modern Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppStyles.space6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.warning,
                        AppColors.warning.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppStyles.radiusXl),
                      topRight: Radius.circular(AppStyles.radiusXl),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppStyles.space4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space3),
                      Text(
                        'Reset Password',
                        style: AppStyles.headingMd.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppStyles.space1),
                      Text(
                        'For ${user.name}',
                        style: AppStyles.bodySm.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(AppStyles.space6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: passwordController,
                        label: 'New Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        hint: 'Minimum 6 characters',
                      ),
                      const SizedBox(height: AppStyles.space3),
                      Container(
                        padding: const EdgeInsets.all(AppStyles.space3),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppStyles.radiusMd,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.warning,
                              size: 20,
                            ),
                            const SizedBox(width: AppStyles.space2),
                            Expanded(
                              child: Text(
                                'The user will need to use this new password to login',
                                style: AppStyles.bodySm.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Container(
                  padding: const EdgeInsets.all(AppStyles.space6),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppStyles.radiusXl),
                      bottomRight: Radius.circular(AppStyles.radiusXl),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Cancel',
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context, false),
                          variant: ButtonVariant.outline,
                          fullWidth: true,
                        ),
                      ),
                      const SizedBox(width: AppStyles.space3),
                      Expanded(
                        flex: 2,
                        child: AppButton(
                          text: 'Reset Password',
                          icon: Icons.lock_reset,
                          loading: isLoading,
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (passwordController.text.length < 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Password must be at least 6 characters',
                                        ),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() => isLoading = true);
                                  try {
                                    await _userService.resetPassword(
                                      user.userId,
                                      passwordController.text,
                                    );
                                    Navigator.pop(context, true);
                                  } catch (e) {
                                    setState(() => isLoading = false);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                          variant: ButtonVariant.warning,
                          fullWidth: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: AppStyles.space2),
              Text('Password reset successfully'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.radiusMd),
          ),
        ),
      );
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppStyles.radiusXl),
        ),
        child: Container(
          width: 450,
          constraints: const BoxConstraints(maxWidth: 450),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modern Header with red gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppStyles.space6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppStyles.radiusXl),
                    topRight: Radius.circular(AppStyles.radiusXl),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppStyles.space4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: AppStyles.space3),
                    Text(
                      'Delete User',
                      style: AppStyles.headingMd.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppStyles.space1),
                    Text(
                      'This action cannot be undone',
                      style: AppStyles.bodySm.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(AppStyles.space6),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppStyles.space4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.error.withOpacity(
                                  0.2,
                                ),
                                child: Text(
                                  user.name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppStyles.space3),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.name, style: AppStyles.labelLg),
                                    Text(
                                      user.email,
                                      style: AppStyles.bodySm.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppStyles.space3),
                          const Divider(),
                          const SizedBox(height: AppStyles.space3),
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: AppStyles.space2),
                              Expanded(
                                child: Text(
                                  'Are you sure you want to delete this user?',
                                  style: AppStyles.labelMd.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(AppStyles.space6),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppStyles.radiusXl),
                    bottomRight: Radius.circular(AppStyles.radiusXl),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.pop(context, false),
                        variant: ButtonVariant.outline,
                        fullWidth: true,
                      ),
                    ),
                    const SizedBox(width: AppStyles.space3),
                    Expanded(
                      child: AppButton(
                        text: 'Delete',
                        icon: Icons.delete,
                        onPressed: () => Navigator.pop(context, true),
                        variant: ButtonVariant.danger,
                        fullWidth: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await _userService.deleteUser(user.userId);
        _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: AppStyles.space2),
                  Text('User deleted successfully'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusMd),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppStyles.radiusMd),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLoadingState();
    }

    if (_error != null) {
      return AppErrorState(
        title: 'Error Loading Users',
        subtitle: _error!,
        onRetry: _loadUsers,
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.space6),
          child: AppEmptyState(
            icon: Icons.people_outline,
            title: 'No Users Found',
            subtitle: 'Add your first user to get started',
          ),
        ),
      );
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppStyles.space4,
            right: AppStyles.space4,
            top: AppStyles.space4,
            bottom: AppStyles.space20, // Extra bottom padding for FAB
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Users Table
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.all(AppStyles.space4),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppStyles.radiusLg),
                          topRight: Radius.circular(AppStyles.radiusLg),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text('Name', style: AppStyles.labelMd),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text('Email', style: AppStyles.labelMd),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('Role', style: AppStyles.labelMd),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('Created', style: AppStyles.labelMd),
                          ),
                          const SizedBox(width: 120, child: Text('Actions')),
                        ],
                      ),
                    ),

                    // Table Rows
                    ...List.generate(_users.length, (index) {
                      final user = _users[index];
                      return Container(
                        padding: const EdgeInsets.all(AppStyles.space4),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.gray200),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary
                                        .withOpacity(0.1),
                                    child: Text(
                                      user.name[0].toUpperCase(),
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppStyles.space2),
                                  Text(user.name, style: AppStyles.labelMd),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(user.email, style: AppStyles.bodySm),
                            ),
                            Expanded(
                              flex: 2,
                              child: AppBadge(
                                text: user.role.toUpperCase(),
                                variant: _getRoleBadgeVariant(user.role),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                DateFormat('MMM d, y').format(user.createdAt),
                                style: AppStyles.bodySm,
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _showEditUserDialog(user),
                                    tooltip: 'Edit',
                                    color: AppColors.primary,
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.lock_reset,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _showResetPasswordDialog(user),
                                    tooltip: 'Reset Password',
                                    color: AppColors.warning,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => _deleteUser(user),
                                    tooltip: 'Delete',
                                    color: AppColors.error,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Floating Action Button
        Positioned(
          right: AppStyles.space4,
          bottom: AppStyles.space4,
          child: FloatingActionButton.extended(
            onPressed: _showAddUserDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add User'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  BadgeVariant _getRoleBadgeVariant(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return BadgeVariant.danger;
      case 'production_manager':
        return BadgeVariant.primary;
      case 'inventory_officer':
        return BadgeVariant.warning;
      case 'qa_officer':
        return BadgeVariant.success;
      case 'worker':
        return BadgeVariant.info;
      default:
        return BadgeVariant.gray;
    }
  }
}
