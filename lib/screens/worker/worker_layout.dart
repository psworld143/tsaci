import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../services/auth_service.dart';
import '../../screens/auth/login_screen.dart';
import 'worker_home_screen.dart';
import 'worker_performance_screen.dart';
import '../supervisor/add_production_screen.dart';

/// Worker Layout with Bottom Navigation (Mobile-First Design)
class WorkerLayout extends StatefulWidget {
  const WorkerLayout({Key? key}) : super(key: key);

  @override
  State<WorkerLayout> createState() => _WorkerLayoutState();
}

class _WorkerLayoutState extends State<WorkerLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    WorkerHomeScreen(),
    WorkerPerformanceScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _navigateToAddProduction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddProductionScreen()),
    );
    // Refresh current screen after returning
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.construction, size: 24),
            const SizedBox(width: AppStyles.space2),
            Text(
              _currentIndex == 0 ? 'My Tasks' : 'My Performance',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'My Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Performance',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _navigateToAddProduction,
              icon: const Icon(Icons.add),
              label: const Text('Log Production'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
