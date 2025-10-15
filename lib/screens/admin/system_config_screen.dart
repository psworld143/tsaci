import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/widgets/widgets.dart';
import '../../services/config_service.dart';

class SystemConfigScreen extends StatefulWidget {
  const SystemConfigScreen({Key? key}) : super(key: key);

  @override
  State<SystemConfigScreen> createState() => _SystemConfigScreenState();
}

class _SystemConfigScreenState extends State<SystemConfigScreen> {
  final ConfigService _configService = ConfigService();
  final ImagePicker _imagePicker = ImagePicker();
  Map<String, dynamic> _configs = {};
  bool _isLoading = true;
  String? _logoPath;

  // Controllers
  final TextEditingController _systemNameController = TextEditingController();
  final TextEditingController _themeColorController = TextEditingController();
  final TextEditingController _tokenExpiryController = TextEditingController();
  final List<TextEditingController> _stageControllers = [];
  final List<TextEditingController> _categoryControllers = [];
  final List<TextEditingController> _unitControllers = [];

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  @override
  void dispose() {
    _systemNameController.dispose();
    _themeColorController.dispose();
    _tokenExpiryController.dispose();
    for (var controller in _stageControllers) {
      controller.dispose();
    }
    for (var controller in _categoryControllers) {
      controller.dispose();
    }
    for (var controller in _unitControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadConfigs() async {
    try {
      setState(() => _isLoading = true);

      final configs = await _configService.getAllConfigs();

      setState(() {
        _configs = configs;
        _isLoading = false;
      });

      // Populate controllers
      _systemNameController.text = configs['system_name'] ?? 'TSACI';
      _themeColorController.text = configs['theme_color'] ?? '#2D6A4F';
      _tokenExpiryController.text =
          configs['token_expiry_days']?.toString() ?? '7';
      _logoPath = configs['system_logo'];

      // Production stages
      final stages = configs['production_stages'] as List<dynamic>? ?? [];
      _stageControllers.clear();
      for (var stage in stages) {
        _stageControllers.add(TextEditingController(text: stage.toString()));
      }

      // Categories
      final categories = configs['product_categories'] as List<dynamic>? ?? [];
      _categoryControllers.clear();
      for (var category in categories) {
        _categoryControllers.add(
          TextEditingController(text: category.toString()),
        );
      }

      // Units
      final units = configs['units_of_measurement'] as List<dynamic>? ?? [];
      _unitControllers.clear();
      for (var unit in units) {
        _unitControllers.add(TextEditingController(text: unit.toString()));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading configs: $e')));
      }
    }
  }

  Future<void> _pickLogo() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _logoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _saveConfigs() async {
    try {
      final updates = <String, dynamic>{
        'system_name': _systemNameController.text,
        'theme_color': _themeColorController.text,
        'system_logo': _logoPath ?? '',
        'token_expiry_days': int.tryParse(_tokenExpiryController.text) ?? 7,
        'production_stages': _stageControllers.map((c) => c.text).toList(),
        'product_categories': _categoryControllers.map((c) => c.text).toList(),
        'units_of_measurement': _unitControllers.map((c) => c.text).toList(),
      };

      await _configService.updateBulk(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configurations saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving configs: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLoadingState();
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
              // White Labeling Section
              Text('White Labeling', style: AppStyles.headingSm),
              const SizedBox(height: AppStyles.space4),

              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: _systemNameController,
                      label: 'System Name',
                      prefixIcon: Icons.business,
                      hint: 'e.g., TSACI Plant System',
                    ),
                    const SizedBox(height: AppStyles.space3),
                    AppTextField(
                      controller: _themeColorController,
                      label: 'Theme Color (Hex)',
                      prefixIcon: Icons.palette,
                      hint: '#2D6A4F',
                    ),
                    const SizedBox(height: AppStyles.space4),
                    // Logo Upload
                    Text(
                      'System Logo',
                      style: AppStyles.labelMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppStyles.space2),
                    Row(
                      children: [
                        if (_logoPath != null && _logoPath!.isNotEmpty)
                          Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(
                              right: AppStyles.space3,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.gray300),
                              borderRadius: BorderRadius.circular(
                                AppStyles.radiusMd,
                              ),
                              image: DecorationImage(
                                image: FileImage(File(_logoPath!)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Expanded(
                          child: AppButton(
                            text: _logoPath == null
                                ? 'Upload Logo'
                                : 'Change Logo',
                            icon: Icons.upload_file,
                            onPressed: _pickLogo,
                            variant: ButtonVariant.outline,
                            size: ButtonSize.sm,
                          ),
                        ),
                        if (_logoPath != null && _logoPath!.isNotEmpty) ...[
                          const SizedBox(width: AppStyles.space2),
                          AppIconButton(
                            icon: Icons.delete,
                            onPressed: () {
                              setState(() {
                                _logoPath = null;
                              });
                            },
                            tooltip: 'Remove Logo',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppStyles.space6),

              // Security Settings
              Text('Security Settings', style: AppStyles.headingSm),
              const SizedBox(height: AppStyles.space4),

              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: _tokenExpiryController,
                      label: 'JWT Token Expiry (Days)',
                      prefixIcon: Icons.timer_outlined,
                      keyboardType: TextInputType.number,
                      hint: '7',
                    ),
                    const SizedBox(height: AppStyles.space3),
                    Container(
                      padding: const EdgeInsets.all(AppStyles.space3),
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppStyles.radiusMd),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: 20,
                          ),
                          const SizedBox(width: AppStyles.space2),
                          Expanded(
                            child: Text(
                              'Users will need to re-login after this period. Recommended: 7-30 days.',
                              style: AppStyles.bodySm.copyWith(
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppStyles.space6),

              // Production Stages
              Text('Production Stages', style: AppStyles.headingSm),
              const SizedBox(height: AppStyles.space4),

              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._stageControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppStyles.space3,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: controller,
                                label: 'Stage ${index + 1}',
                                prefixIcon: Icons.playlist_add_check,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.error,
                              ),
                              onPressed: () {
                                setState(() {
                                  _stageControllers.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    AppButton(
                      text: 'Add Stage',
                      onPressed: () {
                        setState(() {
                          _stageControllers.add(TextEditingController());
                        });
                      },
                      variant: ButtonVariant.secondary,
                      size: ButtonSize.sm,
                      icon: Icons.add,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppStyles.space6),

              // Product Categories
              Text('Product Categories', style: AppStyles.headingSm),
              const SizedBox(height: AppStyles.space4),

              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._categoryControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppStyles.space3,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: controller,
                                label: 'Category ${index + 1}',
                                prefixIcon: Icons.category,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.error,
                              ),
                              onPressed: () {
                                setState(() {
                                  _categoryControllers.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    AppButton(
                      text: 'Add Category',
                      onPressed: () {
                        setState(() {
                          _categoryControllers.add(TextEditingController());
                        });
                      },
                      variant: ButtonVariant.secondary,
                      size: ButtonSize.sm,
                      icon: Icons.add,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppStyles.space6),

              // Units of Measurement
              Text('Units of Measurement', style: AppStyles.headingSm),
              const SizedBox(height: AppStyles.space4),

              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._unitControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppStyles.space3,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: controller,
                                label: 'Unit ${index + 1}',
                                prefixIcon: Icons.straighten,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.error,
                              ),
                              onPressed: () {
                                setState(() {
                                  _unitControllers.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    AppButton(
                      text: 'Add Unit',
                      onPressed: () {
                        setState(() {
                          _unitControllers.add(TextEditingController());
                        });
                      },
                      variant: ButtonVariant.secondary,
                      size: ButtonSize.sm,
                      icon: Icons.add,
                    ),
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
            onPressed: _saveConfigs,
            icon: const Icon(Icons.save),
            label: const Text('Save Changes'),
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
