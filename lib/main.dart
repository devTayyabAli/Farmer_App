import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';

import 'theme.dart';

void main() {
  runApp(const FarmerApp());
}

class FarmerApp extends StatelessWidget {
  const FarmerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}


// Constant for nature background
class AppBackground {
  static Widget natureBackground({Widget? fallback}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/farmland_bg.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A7C2E), Color(0xFF2D4A1C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Container(color: Colors.black.withOpacity(0.5)),
      ],
    );
  }
}

// --- Screens ---

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait a moment for splash effect
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppTheme.buildBackground(context),
          Center(
            child: _buildLogo(),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF8B2E8B), width: 4),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/Logo.png',
          fit: BoxFit.cover,
          width: 90,
          height: 90,
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  Future<void> _login() async {
    // Validate fields
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'User Name is required';
      });
      return;
    }
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Password is required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      // Wait a moment for user data to be saved
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/bgImage.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/farmland_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const SizedBox(height: 80),
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF8B2E8B), width: 4),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/Logo.png',
                      fit: BoxFit.cover,
                      width: 90,
                      height: 90,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                // User Name Field
                AppTheme.buildTextField(
                  label: 'User Name',
                  controller: _emailController,
                  prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textSecondary),
                  hint: 'Enter your email',
                ),
                const SizedBox(height: 24),
                // Password Field
                AppTheme.buildTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  hint: '********',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      !_isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                const SizedBox(height: 16),
                // Terms text
                const Text(
                  'By clicking the Sign In button you agree to the terms and conditions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 32),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  bool _isAdmin = false;
  List<Widget> _screens = [];

  final GlobalKey<_HomeScreenState> _homeKey = GlobalKey<_HomeScreenState>();
  final GlobalKey<_PendingVehiclesScreenState> _pendingKey = GlobalKey<_PendingVehiclesScreenState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final isAdmin = await AuthService.isAdmin();
    print('DEBUG: User is admin: $isAdmin');
    setState(() {
      _isAdmin = isAdmin;
      _screens = [
        HomeScreen(key: _homeKey),
        PendingVehiclesScreen(key: _pendingKey),
        const ReceiptScreen(),
        const ReportsScreen(),
        if (_isAdmin) const SettingsScreen(),
      ];
      print('DEBUG: Screens list length: ${_screens.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 0 && _currentIndex == 0) {
            _homeKey.currentState?.loadData();
          } else if (index == 1 && _currentIndex == 1) {
            _pendingKey.currentState?.loadData();
          }
          setState(() {
            _currentIndex = index;
            if (_currentIndex == 0) {
              _homeKey.currentState?.loadData();
            } else if (_currentIndex == 1) {
              _pendingKey.currentState?.loadData();
            }
          });
        },
        showSettings: _isAdmin,
      ),
    );
  }
}
// Note: Handled custom bottom nav styling within the theme or custom widget if needed.
// For the pill effect in the image, we'll use a custom implementation.

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool showSettings;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showSettings = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(0, Icons.home, 'Home'),
          _buildNavItem(1, Icons.pending_actions, 'Pending'),
          _buildNavItem(2, Icons.assignment_outlined, 'Receipt'),
          _buildNavItem(3, Icons.history, 'History'),
          if (showSettings) _buildNavItem(4, Icons.settings_outlined, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFF8B2E8B),
                borderRadius: BorderRadius.circular(25),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white54,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- Home Screen ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _salesSummary = [];
  List<dynamic> _recentSales = [];
  bool _isLoading = true;
  String? _error;

  // Filter states
  String _selectedHouse = 'All';
  String _selectedFlock = 'All';
  String _selectedDate = 'All';

  List<dynamic> get _filteredSales {
    return _recentSales.where((sale) {
      bool houseMatch = _selectedHouse == 'All' || (sale['houseNo']?.toString() == _selectedHouse);
      bool flockMatch = _selectedFlock == 'All' || (sale['flockNo']?.toString() == _selectedFlock);
      
      String saleDate = _formatDateSimple(sale['date']);
      bool dateMatch = _selectedDate == 'All' || (saleDate == _selectedDate);
      
      return houseMatch && flockMatch && dateMatch;
    }).toList();
  }

  String _formatDateSimple(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final summaryResult = await ApiService.getSalesSummary();
      final salesResult = await ApiService.getSales(); // Use getSales for broader history

      if (mounted) {
        setState(() {
          if (summaryResult['success']) {
            _salesSummary = summaryResult['data'];
          }
          if (salesResult['success']) {
            _recentSales = salesResult['data'];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load data';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await AuthService.clearAuth();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF8B2E8B),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/Logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'logout', child: Text('LogOut')),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/bgImage.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/farmland_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: loadData,
              color: const Color(0xFF8B2E8B),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sale Summary',
                                style: AppTheme.heading3,
                              ),
                              const SizedBox(height: 16),
                              _buildDataSummaryCard(),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Sale History',
                                    style: AppTheme.heading3,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => SaleHistoryDetailsScreen(
                                            date: 'All History',
                                            sales: _recentSales,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('View All', style: TextStyle(color: AppTheme.accent)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Filters Row
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildFilterDropdown(
                                      label: "House",
                                      value: _selectedHouse,
                                      options: ['All', ..._getUniqueValues('houseNo')],
                                      onChanged: (val) => setState(() => _selectedHouse = val!),
                                    ),
                                    const SizedBox(width: 10),
                                    _buildFilterDropdown(
                                      label: "Flock",
                                      value: _selectedFlock,
                                      options: ['All', ..._getUniqueValues('flockNo')],
                                      onChanged: (val) => setState(() => _selectedFlock = val!),
                                    ),
                                    const SizedBox(width: 10),
                                    _buildDateFilter(),
                                    if (_selectedHouse != 'All' || _selectedFlock != 'All' || _selectedDate != 'All') ...[
                                      const SizedBox(width: 12),
                                      TextButton.icon(
                                        onPressed: () => setState(() {
                                          _selectedHouse = 'All';
                                          _selectedFlock = 'All';
                                          _selectedDate = 'All';
                                        }),
                                        icon: const Icon(Icons.refresh, size: 16, color: Colors.white60),
                                        label: const Text("Clear", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.white10,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTransactionList(),
                            ],
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSummaryCard() {
    if (_salesSummary.isEmpty) {
      return AppTheme.buildCard(
        child: const Center(
          child: Text('No data available', style: AppTheme.bodyMedium),
        ),
      );
    }

    final maxY = _salesSummary.isNotEmpty
        ? _salesSummary.map((s) => (s['totalWeight'] ?? 0).toDouble()).reduce((a, b) => a > b ? a : b) * 1.2
        : 100.0;

    return AppTheme.buildCard(
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY > 0 ? maxY : 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _salesSummary.length) {
                          final date = _salesSummary[index]['_id']?.toString() ?? '';
                          final shortDate = date.isNotEmpty ? date.substring(5) : '';
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(shortDate, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return SideTitleWidget(
                          meta: meta,
                          child: Text('${value.toInt()}', style: const TextStyle(color: Colors.white70, fontSize: 9)),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _salesSummary.asMap().entries.map((entry) {
                  final isEven = entry.key % 2 == 0;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: (entry.value['totalWeight'] ?? 0).toDouble(),
                        color: isEven ? const Color(0xFF8B2E8B) : Colors.white70,
                        width: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getUniqueValues(String key) {
    if (_recentSales.isEmpty) return [];
    final values = _recentSales.map((s) => s[key]?.toString()).where((v) => v != null && v != 'null').toSet().toList();
    values.sort();
    return values.cast<String>();
  }

  List<String> _getUniqueDates() {
    if (_recentSales.isEmpty) return [];
    final dates = _recentSales.map((s) => _formatDateSimple(s['date'])).toSet().toList();
    // Sort dates newest first
    dates.sort((a, b) {
      try {
        final partsA = a.split('-');
        final partsB = b.split('-');
        if (partsA.length == 3 && partsB.length == 3) {
          final dateA = DateTime(int.parse(partsA[2]), int.parse(partsA[1]), int.parse(partsA[0]));
          final dateB = DateTime(int.parse(partsB[2]), int.parse(partsB[1]), int.parse(partsB[0]));
          return dateB.compareTo(dateA);
        }
      } catch (e) {}
      return b.compareTo(a);
    });
    return dates;
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$label: ", style: const TextStyle(color: Colors.white60, fontSize: 11)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : 'All',
              dropdownColor: const Color(0xFF1E1E1E),
              icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.primary),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              onChanged: onChanged,
              items: options.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return GestureDetector(
      onTap: _selectDate,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 14, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              _selectedDate == 'All' ? "All Dates" : _selectedDate,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            if (_selectedDate != 'All') ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _selectedDate = 'All'),
                child: const Icon(Icons.close, size: 14, color: Colors.white54),
              ),
            ] else ...[
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.primary),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5), // dynamic range
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  Widget _buildTransactionList() {
    final filteredSales = _filteredSales;
    
    if (_recentSales.isEmpty) return AppTheme.buildCard(child: const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('No sales recorded', style: AppTheme.bodyMedium))));

    if (filteredSales.isEmpty) return AppTheme.buildCard(child: const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('No matching records found', style: AppTheme.bodyMedium))));

    final Map<String, List<dynamic>> salesByDate = {};
    for (var sale in filteredSales) {
      final dateStr = sale['date']?.toString() ?? 'Unknown';
      final formattedDate = _formatDateHeader(dateStr);
      if (!salesByDate.containsKey(formattedDate)) salesByDate[formattedDate] = [];
      salesByDate[formattedDate]!.add(sale);
    }

    final sortedDates = salesByDate.keys.toList()..sort((a, b) {
      final order = {'Today': 0, 'Yesterday': 1};
      final aOrder = order[a] ?? 2;
      final bOrder = order[b] ?? 2;
      if (aOrder != bOrder) return aOrder.compareTo(bOrder);
      return b.compareTo(a);
    });

    return Column(
      children: sortedDates.map((date) {
        final sales = salesByDate[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
                        child: Text(date, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Text('${sales.length} sale${sales.length > 1 ? 's' : ''}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SaleHistoryDetailsScreen(date: date, sales: sales))),
                    child: const Text('View All', style: TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            ...sales.map((sale) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: AppTheme.buildCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildSaleInfo('Vehicle', sale['vehicleNo'] ?? 'N/A')),
                        Expanded(child: _buildSaleInfo('Broker', sale['brokerName'] ?? 'N/A')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildSaleInfo('Weight', '${sale['netWeight'] ?? 0}kg')),
                        Expanded(child: _buildSaleInfo('Amount', 'Rs ${sale['totalAmount'] ?? 0}')),
                      ],
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSaleInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDateHeader(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      
      if (dateOnly == today) {
        return 'Today';
      } else if (dateOnly == today.subtract(const Duration(days: 1))) {
        return 'Yesterday';
      } else {
        return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      }
    } catch (e) {
      return dateStr;
    }
  }

  Widget _infoLine(String label, String value) {
    return RichText(
      text: TextSpan(
        style: AppTheme.bodySmall,
        children: [
          TextSpan(text: '$label '),
          TextSpan(text: value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// --- Sale History Details Screen ---

class SaleHistoryDetailsScreen extends StatelessWidget {
  final String date;
  final List<dynamic> sales;

  const SaleHistoryDetailsScreen({
    super.key,
    required this.date,
    required this.sales,
  });

  Widget _buildInfoBadge(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textTertiary, fontSize: 11)),
                Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final int value = number is num ? number.toInt() : int.tryParse(number.toString()) ?? 0;
    return value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    // Extract common header data from the first sale
    final houseNo = sales.isNotEmpty ? (sales.first['houseNo']?.toString() ?? 'N/A') : 'N/A';
    final flockNo = sales.isNotEmpty ? (sales.first['flockNo']?.toString() ?? 'N/A') : 'N/A';
    
    // Calculate summary
    double totalWeight = 0;
    double totalAmount = 0;
    
    for (var sale in sales) {
      totalWeight += (sale['netWeight'] ?? 0).toDouble();
      totalAmount += (sale['totalAmount'] ?? 0).toDouble();
    }
    
    final avgRate = totalWeight > 0 ? (totalAmount / totalWeight) : 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Sales History', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8B2E8B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppTheme.buildBackground(context),
          SafeArea(
            child: Column(
              children: [
                // 1. PINNED HEADERS (Fixed at top - Made more compact)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: AppTheme.buildCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildInfoBadge('House No', houseNo, Icons.home_work_outlined)),
                            const SizedBox(width: 8),
                            Expanded(child: _buildInfoBadge('Flock No', flockNo, Icons.pets_outlined)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildInfoBadge('Date', date, Icons.calendar_today_outlined)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildInfoBadge(
                                'Vehicles', 
                                '${sales.length}', 
                                Icons.local_shipping_outlined
                              )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 2. FIXED TABLE HEADER BAR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: const [
                      Expanded(flex: 2, child: Text('Vehicle', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Net W', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold))),
                      Expanded(flex: 3, child: Text('T. Payment', textAlign: TextAlign.right, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // 3. SCROLLABLE INNER DATA (Dynamic middle section)
                Expanded(
                  child: sales.isEmpty
                      ? const Center(child: Text('No sales found', style: AppTheme.bodyMedium))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                          itemCount: sales.length,
                          itemBuilder: (context, index) {
                            final sale = sales[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2, 
                                    child: Text(
                                      sale['vehicleNo']?.toString() ?? 'N/A', 
                                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)
                                    )
                                  ),
                                  Expanded(
                                    flex: 2, 
                                    child: Text(
                                      '${_formatNumber(sale['netWeight'])} kg', 
                                      textAlign: TextAlign.center, 
                                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13)
                                    )
                                  ),
                                  Expanded(
                                    flex: 3, 
                                    child: Text(
                                      '${_formatNumber(sale['totalAmount'])} RS', 
                                      textAlign: TextAlign.right, 
                                      style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 14)
                                    )
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // 4. FIXED SUMMARY FOOTER (Pinned at bottom - More compact & semi-translucent)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withOpacity(0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, -4)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sale Summary', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(
                            'Total Weight: ${_formatNumber(totalWeight)} kg', 
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(color: Colors.white10, height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Avg Rate', style: TextStyle(color: AppTheme.textTertiary, fontSize: 11)),
                              Text('${avgRate.toStringAsFixed(2)} rs', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Total Net Amount', style: TextStyle(color: AppTheme.textTertiary, fontSize: 11)),
                              Text(
                                '${_formatNumber(totalAmount)} RS', 
                                style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 20)
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: fontSize)),
        Text(
          value, 
          style: TextStyle(
            color: color ?? AppTheme.textPrimary, 
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize + 2,
          ),
        ),
      ],
    );
  }
}

// --- Receipt Screen (Refined) ---

class ReceiptScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const ReceiptScreen({super.key, this.initialData});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  // Controllers for new fields
  final _vehicleController = TextEditingController();
  final _advanceController = TextEditingController();
  final _weight1Controller = TextEditingController();
  final _brokerController = TextEditingController();
  final _priceController = TextEditingController();
  
  // Keep existing controllers for now
  final _houseController = TextEditingController();
  final _flockController = TextEditingController();
  final _weight2Controller = TextEditingController();
  final _rateController = TextEditingController();
  
  // Dropdown data
  List<String> _vehicleNumbers = [];
  List<String> _filteredVehicles = [];
  List<String> _previousWeights = [];
  List<String> _flockNumbers = [];
  List<String> _houseNumbers = [];
  List<String> _brokerNames = [];
  List<String> _filteredBrokers = [];
  bool _brokerInitialized = false;
  String? _selectedVehicle;
  String? _selectedWeight;
  String? _selectedFlock;
  String? _selectedHouse;
  String? _selectedBroker;
  bool _isLoading = false;
  String? _validationError;
  bool _showVehicleDropdown = false;
  bool _showBrokerDropdown = false;
  final LayerLink _vehicleLayerLink = LayerLink();
  final LayerLink _brokerLayerLink = LayerLink();
  OverlayEntry? _vehicleOverlayEntry;
  OverlayEntry? _brokerOverlayEntry;

  @override
  void initState() {
    super.initState();
    // Initialize broker lists with sample data
    _brokerNames = ['John Smith', 'Ahmed Khan', 'Muhammad Ali', 'Sarah Johnson', 'David Brown'];
    _filteredBrokers = [];
    _brokerInitialized = true;
    
    _loadTodaySettings();
    _loadVehicleNumbers();
    _loadFlockNumbers();
    _loadHouseNumbers();
    _loadBrokerNames();
    
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _vehicleController.text = data['vehicleNo'] ?? '';
      _brokerController.text = data['brokerName'] ?? '';
      _selectedHouse = data['houseNo']?.toString();
      _houseController.text = _selectedHouse ?? '';
      _selectedFlock = data['flockNo']?.toString();
      _flockController.text = _selectedFlock ?? '';
      _advanceController.text = _formatNumber(data['advance']);
      _weight1Controller.text = data['weight1']?.toString() ?? '';
      
      final w2 = data['weight2'];
      _weight2Controller.text = (w2 == null || w2.toString() == '0' || w2.toString() == '0.0') ? '' : w2.toString();
      
      _rateController.text = data['rate']?.toString() ?? '';
      // Trigger price load from settings if not provided in data
      if (data['rate'] == null && data['price'] != null) {
        _rateController.text = data['price'].toString();
      }
    }
  }

  Future<void> _loadTodaySettings() async {
    try {
      final result = await ApiService.getSettings();
      if (result['success'] && result['data'].isNotEmpty) {
        final today = DateTime.now();
        final todayStr = '${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}';
        
        final todaySettings = result['data'].firstWhere(
          (setting) => setting['date'] == todayStr,
          orElse: () => result['data'][0],
        );
        
        if (mounted) {
          setState(() {
            _selectedHouse = todaySettings['houseNo']?.toString();
            _houseController.text = _selectedHouse ?? '';
            _selectedFlock = todaySettings['flockNo']?.toString();
            _flockController.text = _selectedFlock ?? '';
            _priceController.text = todaySettings['price']?.toString() ?? '';
            _rateController.text = _priceController.text;
          });
        }
      }
    } catch (e) {
      print('Error loading today settings: $e');
    }
  }

  Future<void> _loadVehicleNumbers() async {
    try {
      final result = await ApiService.getVehicles();
      if (result['success']) {
        final vehicles = result['data'].map<String>((vehicle) => vehicle['vehicleNumber'].toString()).toList();
        if (mounted) {
          setState(() {
            _vehicleNumbers = vehicles;
            _filteredVehicles = vehicles;
          });
        }
      }
    } catch (e) {
      print('Error loading vehicle numbers: $e');
    }
  }

  void _onVehicleChanged(String value) {
    print('DEBUG: Vehicle changed: "$value"');
    print('DEBUG: Total vehicles: ${_vehicleNumbers.length}');
    print('DEBUG: Filtered vehicles: ${_filteredVehicles.length}');
    
    setState(() {
      _filteredVehicles = _vehicleNumbers
          .where((vehicle) => vehicle.toLowerCase().contains(value.toLowerCase()))
          .toList();
      _showVehicleDropdown = value.isNotEmpty && _filteredVehicles.isNotEmpty;
    });
    
    print('DEBUG: Show dropdown: $_showVehicleDropdown');

    if (_showVehicleDropdown) {
      print('DEBUG: Showing overlay');
      _showOverlay();
    } else {
      print('DEBUG: Hiding overlay');
      _hideOverlay();
    }

    // Auto-fetch vehicle when user types a potential full number
    if (value.length >= 3) {
      _fetchVehicleFromAPI(value);
    } else if (value.isEmpty) {
      _selectedVehicle = null;
    }
  }

  void _onBrokerChanged(String value) {
    print('DEBUG: Broker changed: "$value"');
    
    // Ensure brokers are initialized
    if (!_brokerInitialized || _brokerNames.isEmpty) {
      _brokerNames = ['John Smith', 'Ahmed Khan', 'Muhammad Ali', 'Sarah Johnson', 'David Brown'];
      _filteredBrokers = [];
      _brokerInitialized = true;
      print('DEBUG: Brokers initialized in onChanged');
    }
    
    setState(() {
      _filteredBrokers = _brokerNames
          .where((broker) => broker.toLowerCase().contains(value.toLowerCase()))
          .toList();
      _showBrokerDropdown = value.isNotEmpty && _filteredBrokers.isNotEmpty;
      
      print('DEBUG: Total: ${_brokerNames.length}, Filtered: ${_filteredBrokers.length}');
      print('DEBUG: Show dropdown: $_showBrokerDropdown');
    });

    if (value.isEmpty) {
      _selectedBroker = null;
    }
  }

  Future<void> _fetchVehicleFromAPI(String vehicleNumber) async {
    try {
      final result = await ApiService.getVehicleByNumber(vehicleNumber);
      if (result['success'] && result['data'] != null) {
        final vehicle = result['data'];
        if (mounted) {
          setState(() {
            _brokerController.text = vehicle['brokerName'] ?? '';
          });
        }
      }

      // Also fetch weight history
      final historyResult = await ApiService.getVehicleWeightHistory(vehicleNumber);
      if (historyResult['success']) {
        final List<dynamic> data = historyResult['data'];
        final weights = data.map<String>((item) => item['weight1'].toString()).toList();
        if (mounted) {
          setState(() {
            _previousWeights = weights;
            if (weights.isEmpty) {
              _selectedWeight = null;
            }
          });
        }
      }
    } catch (e) {
      print('Error fetching vehicle from API: $e');
    }
  }

  void _onVehicleSelected(String vehicleNumber) async {
    _hideOverlay();
    setState(() {
      _selectedVehicle = vehicleNumber;
      _vehicleController.text = vehicleNumber;
      _showVehicleDropdown = false;
    });

    // Load vehicle details
    try {
      final result = await ApiService.getVehicleByNumber(vehicleNumber);
      if (result['success'] && result['data'] != null) {
        final vehicle = result['data'];
        if (mounted) {
          setState(() {
            _brokerController.text = vehicle['brokerName'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error loading vehicle details: $e');
    }

    // Load previous weights for this vehicle
    try {
      final result = await ApiService.getVehicleWeightHistory(vehicleNumber);
      if (result['success']) {
        final weights = result['data'].map<String>((weight) => weight['weight1'].toString()).toList();
        if (mounted) {
          setState(() {
            _previousWeights = weights;
          });
        }
      }
    } catch (e) {
      print('Error loading weight history: $e');
    }
  }

  void _onBrokerSelected(String brokerName) {
    setState(() {
      _selectedBroker = brokerName;
      _brokerController.text = brokerName;
      _showBrokerDropdown = false;
    });
  }

  Future<void> _loadHouseNumbers() async {
    try {
      final result = await ApiService.getHouses();
      if (result['success']) {
        final houses = result['data'].map<String>((house) => house.toString()).toList();
        if (mounted) {
          setState(() {
            _houseNumbers = houses;
          });
        }
      }
    } catch (e) {
      print('Error loading house numbers: $e');
    }
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final int value = number is num ? number.toInt() : int.tryParse(number.toString().replaceAll(',', '')) ?? 0;
    if (value == 0) return '';
    return value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  Future<void> _loadFlockNumbers() async {
    try {
      final result = await ApiService.getFlocks();
      if (result['success']) {
        final flocks = result['data'].map<String>((flock) => flock.toString()).toList();
        if (mounted) {
          setState(() {
            _flockNumbers = flocks;
          });
        }
      }
    } catch (e) {
      print('Error loading flock numbers: $e');
    }
  }

  Future<void> _loadBrokerNames() async {
    try {
      print('DEBUG: Loading broker names...');
      // Initialize with empty lists first
      if (mounted) {
        setState(() {
          _brokerNames = [];
          _filteredBrokers = [];
        });
      }
      
      final result = await ApiService.getBrokers();
      print('DEBUG: API result success: ${result['success']}');
      if (result['success']) {
        final brokers = result['data'].map<String>((broker) => broker.toString()).toList();
        print('DEBUG: Brokers loaded: $brokers');
        if (mounted) {
          setState(() {
            _brokerNames = brokers;
            _filteredBrokers = brokers;
            print('DEBUG: Broker names set: $_brokerNames');
          });
        }
      } else {
        print('DEBUG: API failed: ${result['message']}');
        // Add sample data for testing
        if (mounted) {
          setState(() {
            _brokerNames = ['John Smith', 'Ahmed Khan', 'Muhammad Ali', 'Sarah Johnson', 'David Brown'];
            _filteredBrokers = _brokerNames!;
            print('DEBUG: Using sample broker names: $_brokerNames');
          });
        }
      }
    } catch (e) {
      print('Error loading broker names: $e');
      // Add sample data for testing
      if (mounted) {
        setState(() {
          _brokerNames = ['John Smith', 'Ahmed Khan', 'Muhammad Ali', 'Sarah Johnson', 'David Brown'];
          _filteredBrokers = _brokerNames!;
          print('DEBUG: Using sample broker names due to error: $_brokerNames');
        });
      }
    }
  }

  double get _netWeight {
    final w1Str = _weight1Controller.text.replaceAll(',', '');
    final w2Str = _weight2Controller.text.replaceAll(',', '');
    if (w1Str.isEmpty || w2Str.isEmpty || w2Str == '0') return 0.0;
    
    final w1 = double.tryParse(w1Str) ?? 0;
    final w2 = double.tryParse(w2Str) ?? 0;
    return w2 - w1;
  }

  double get _totalAmount {
    final rateStr = _rateController.text.replaceAll(',', '');
    final rate = double.tryParse(rateStr) ?? 0;
    return _netWeight * rate;
  }
  void _showOverlay() {
    if (_vehicleOverlayEntry != null) {
      _vehicleOverlayEntry!.markNeedsBuild();
      return;
    }

    final overlay = Overlay.of(context);
    _vehicleOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 40, // Match search field width (padding 20 each side)
        child: CompositedTransformFollower(
          link: _vehicleLayerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60), // Reduced offset to ensure visibility
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            color: AppTheme.surfaceLight,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                border: Border.all(color: AppTheme.primary, width: 1),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredVehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = _filteredVehicles[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      vehicle,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    ),
                    onTap: () => _onVehicleSelected(vehicle),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_vehicleOverlayEntry!);
  }

  void _hideOverlay() {
    _vehicleOverlayEntry?.remove();
    _vehicleOverlayEntry = null;
  }

  void _showBrokerOverlay() {
    if (_brokerOverlayEntry != null) {
      _brokerOverlayEntry!.markNeedsBuild();
      return;
    }

    final overlay = Overlay.of(context);
    _brokerOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 40, // Match search field width (padding 20 each side)
        child: CompositedTransformFollower(
          link: _brokerLayerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50), // Further reduced offset for better visibility
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            color: AppTheme.surfaceLight,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                border: Border.all(color: AppTheme.primary, width: 1),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _filteredBrokers.length,
                itemBuilder: (context, index) {
                  final broker = _filteredBrokers[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      broker,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    ),
                    onTap: () => _onBrokerSelected(broker),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_brokerOverlayEntry!);
  }

  void _hideBrokerOverlay() {
    _brokerOverlayEntry?.remove();
    _brokerOverlayEntry = null;
  }


  @override
  void dispose() {
    _hideOverlay();
    _hideBrokerOverlay();
    _vehicleController.dispose();
    _houseController.dispose();
    _flockController.dispose();
    _advanceController.dispose();
    _weight1Controller.dispose();
    _weight2Controller.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Receipt'),
        backgroundColor: const Color(0xFF8B2E8B),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/Logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await AuthService.clearAuth();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'logout', child: Text('LogOut')),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppTheme.buildBackground(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Top Data Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTheme.buildDropdownField<String>(
                          label: 'House#',
                          value: _selectedHouse?.isEmpty == true ? null : _selectedHouse,
                          items: _houseNumbers.map((String house) {
                            return DropdownMenuItem<String>(
                              value: house,
                              child: Text(house),
                            );
                          }).toList(),
                          onChanged: widget.initialData != null ? null : (String? newValue) {
                            setState(() {
                              _selectedHouse = newValue;
                              _houseController.text = newValue ?? '';
                            });
                          },
                          hint: 'Select',
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppTheme.buildDropdownField<String>(
                          label: 'Flock#',
                          value: _selectedFlock?.isEmpty == true ? null : _selectedFlock,
                          items: _flockNumbers.map((String flock) {
                            return DropdownMenuItem<String>(
                              value: flock,
                              child: Text(flock),
                            );
                          }).toList(),
                          onChanged: widget.initialData != null ? null : (String? newValue) {
                            setState(() {
                              _selectedFlock = newValue;
                              _flockController.text = newValue ?? '';
                            });
                          },
                          hint: 'Select',
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: AppTheme.buildTextField(
                          label: 'Date',
                          controller: TextEditingController(text: '${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}'),
                          readOnly: true,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Vehicle Number Dropdown
                  _buildVehicleDropdown(),
                  const SizedBox(height: 24),

                  // Advance Amount Field (Optional)
                  AppTheme.buildTextField(
                    label: 'Advance Amount',
                    controller: _advanceController,
                    hint: 'Optional',
                    keyboardType: TextInputType.number,
                    readOnly: widget.initialData != null,
                    onChanged: (value) {
                      String cleanValue = value.replaceAll(',', '');
                      if (cleanValue.isNotEmpty) {
                        String formatted = _formatNumber(cleanValue);
                        _advanceController.value = TextEditingController.fromValue(
                          TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          ),
                        ).value;
                      }
                      setState(() {});
                    },
                    prefixIcon: const Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Rs ', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Weight 1 Field with Previous Weights
                  _buildWeight1Field(),
                  const SizedBox(height: 24),

                  if (widget.initialData != null) ...[
                    // Weight 2 Field
                    AppTheme.buildTextField(
                      label: 'Weight 2',
                      controller: _weight2Controller,
                      hint: '0.00 kg',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),

                    // Net Weight (Display Only)
                    AppTheme.buildTextField(
                      label: 'Net Weight',
                      controller: TextEditingController(
                        text: (_weight2Controller.text.isEmpty || _weight2Controller.text == '0') 
                          ? '' : '${_netWeight.toStringAsFixed(2)} kg'
                      ),
                      hint: 'Calculated from Weight 1 & 2',
                      readOnly: true,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Broker Name Field
                  _buildBrokerDropdown(),
                  const SizedBox(height: 24),

                   if (widget.initialData != null) ...[
                     // Rate Field
                     AppTheme.buildTextField(
                       label: 'Rate',
                       controller: _rateController,
                       hint: 'Rs 0',
                       keyboardType: TextInputType.number,
                       onChanged: (_) => setState(() {}),
                       prefixIcon: const Padding(
                         padding: EdgeInsets.all(16.0),
                         child: Text('Rs ', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                       ),
                     ),
                     const SizedBox(height: 32),
                   ],

                  if (widget.initialData != null) ...[
                    // Total Amount Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Total Amount', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text(
                          'Rs ${_totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Add/Update Receipt Button
                  _buildAddVehicleButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // New methods for the updated UI
  Widget _buildVehicleDropdown() {
    return CompositedTransformTarget(
      link: _vehicleLayerLink,
      child: AppTheme.buildTextField(
        label: 'Vehicle Number',
        controller: _vehicleController,
        hint: 'Enter vehicle number',
        readOnly: widget.initialData != null,
        onChanged: _onVehicleChanged,
        suffixIcon: widget.initialData != null ? null : IconButton(
          icon: const Icon(Icons.search, color: AppTheme.primary, size: 20),
          onPressed: () {
            if (_vehicleController.text.isNotEmpty) {
              _fetchVehicleFromAPI(_vehicleController.text);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBrokerDropdown() {
    return StatefulBuilder(
      builder: (context, setDropdownState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTheme.buildTextField(
              label: 'Broker Name',
              controller: _brokerController,
              hint: 'Enter broker name',
              readOnly: widget.initialData != null,
              onChanged: widget.initialData != null ? null : (value) {
                print('DEBUG: Broker typing: "$value"');
                
                // Filter brokers
                final allBrokers = _brokerNames.isNotEmpty ? _brokerNames : 
                  ['John Smith', 'Ahmed Khan', 'Muhammad Ali', 'Sarah Johnson', 'David Brown'];
                
                final filtered = value.isEmpty 
                  ? <String>[]
                  : allBrokers.where((b) => 
                      b.toLowerCase().contains(value.toLowerCase())
                    ).toList();
                
                print('DEBUG: Found ${filtered.length} matches');
                
                // Update dropdown visibility
                setDropdownState(() {
                  _filteredBrokers = filtered;
                  _showBrokerDropdown = filtered.isNotEmpty;
                });
              },
              suffixIcon: const Icon(Icons.person_search, color: AppTheme.primary, size: 20),
            ),
            // Simple dropdown list
            if (_showBrokerDropdown && _filteredBrokers.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  border: Border.all(color: AppTheme.primary, width: 1),
                ),
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredBrokers.length,
                  itemBuilder: (context, index) {
                    final broker = _filteredBrokers[index];
                    return ListTile(
                      dense: true,
                      title: Text(broker, 
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                      onTap: () {
                        print('DEBUG: Selected: $broker');
                        _brokerController.text = broker;
                        setDropdownState(() {
                          _showBrokerDropdown = false;
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildWeight1Field() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTheme.buildTextField(
          label: 'Weight 1',
          controller: _weight1Controller,
          hint: 'Enter weight',
          keyboardType: TextInputType.number,
          readOnly: widget.initialData != null,
          onChanged: (_) => setState(() {}),
        ),
        if (_previousWeights.isNotEmpty) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Last Weights: ', style: TextStyle(fontSize: 11, color: Colors.white54)),
                ..._previousWeights.take(3).map((w) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(w, style: const TextStyle(fontSize: 11, color: Colors.white70)),
                )).toList(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddVehicleButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _addVehicle,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: _isLoading ? Colors.grey : const Color(0xFF8B2E8B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  widget.initialData != null ? 'Finalize Receipt' : 'Add Vehicle',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _addVehicle() async {
    // Validate required fields
    if (_vehicleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle Number is required')),
      );
      return;
    }
    if (_weight1Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weight 1 is required')),
      );
      return;
    }
    if (_brokerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Broker Name is required')),
      );
      return;
    }
    // Additional validation for finalizing
    if (widget.initialData != null) {
      if (_rateController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rate is required to finalize')),
        );
        return;
      }
      if (_weight2Controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weight 2 is required to finalize')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final isFinalizing = widget.initialData != null;
    final advance = double.tryParse(_advanceController.text.replaceAll(',', '')) ?? 0;
    
    final saleData = {
      'vehicleNo': _vehicleController.text.trim(),
      'brokerName': _brokerController.text.trim(),
      'houseNo': _houseController.text.trim(),
      'flockNo': _flockController.text.trim(),
      'weight1': double.tryParse(_weight1Controller.text.replaceAll(',', '')) ?? 0,
      'weight2': isFinalizing ? (double.tryParse(_weight2Controller.text.replaceAll(',', '')) ?? 0) : 0,
      'netWeight': isFinalizing ? _netWeight : 0,
      'rate': double.tryParse(_rateController.text.replaceAll(',', '')) ?? 0,
      'totalAmount': isFinalizing ? _totalAmount : 0,
      'advance': advance,
      'due': isFinalizing ? (_totalAmount - advance) : 0,
      'status': isFinalizing ? 'completed' : 'pending',
      'date': isFinalizing ? widget.initialData!['date'] : DateTime.now().toIso8601String(),
    };

    try {
      final result = isFinalizing 
          ? await ApiService.updateSale(widget.initialData!['_id'], saleData)
          : await ApiService.createSale(saleData);
      
      if (result['success']) {
        if (mounted) {
          if (isFinalizing) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receipt finalized successfully!')),
            );
            
            final sale = result['data'];
            if (sale != null && sale['_id'] != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PaymentScreen(
                    saleId: sale['_id'].toString(),
                    initialData: sale,
                  ),
                ),
              );
            }
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Icon(Icons.check_circle_outline, color: AppTheme.primary, size: 48),
                content: const Text(
                  'Vehicle added to pending tasks successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                actions: [
                  Center(
                    child: SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Ok', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            );
            // Clear fields for next entry
            _vehicleController.clear();
            _advanceController.clear();
            _weight1Controller.clear();
            _brokerController.clear();
            _rateController.clear();
            setState(() {
              _selectedVehicle = null;
              _previousWeights = [];
            });
            _loadTodaySettings(); // Re-load default house/flock/price
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to process request')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Keep existing helper methods
  Widget _buildDataCapsule(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 11, color: Colors.white70),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.normal)),
            TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildFlockDropdownCapsule() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedFlock?.isEmpty == true ? null : _selectedFlock,
        hint: Text(
          _selectedFlock?.isNotEmpty == true ? 'Flock# $_selectedFlock' : 'Flock#',
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
        dropdownColor: const Color(0xFF1E1E1E),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
        underline: const SizedBox(),
        isDense: true,
        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
        items: _flockNumbers.map((String flock) {
          return DropdownMenuItem<String>(
            value: flock,
            child: Text(flock, style: const TextStyle(fontSize: 11)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedFlock = newValue;
            _flockController.text = newValue ?? '';
          });
        },
      ),
    );
  }

  Widget _buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 20),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
          ),
          child: const TextField(
            enabled: false,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Select option',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnderlinedField(String label, {TextEditingController? controller, String? hint, Widget? prefix, Widget? trailing}) {
    return AppTheme.buildTextField(
      label: label,
      controller: controller ?? TextEditingController(),
      hint: hint,
      prefixIcon: prefix,
      suffixIcon: trailing,
      onChanged: (_) => setState(() {}),
    );
  }
  }


// --- Pending Vehicles Screen ---

class PendingVehiclesScreen extends StatefulWidget {
  const PendingVehiclesScreen({super.key});

  @override
  State<PendingVehiclesScreen> createState() => _PendingVehiclesScreenState();
}

class _PendingVehiclesScreenState extends State<PendingVehiclesScreen> {
  List<dynamic> _pendingSales = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final result = await ApiService.getPendingSales();
    if (mounted) {
      setState(() {
        if (result['success']) {
          _pendingSales = result['data'];
        } else {
          _error = result['message'];
        }
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Pending Vehicles'),
        backgroundColor: const Color(0xFF8B2E8B),
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppTheme.buildBackground(context),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white)))
                    : _pendingSales.isEmpty
                        ? const Center(child: Text('No pending vehicles found', style: TextStyle(color: Colors.white70)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _pendingSales.length,
                            itemBuilder: (context, index) {
                              final sale = _pendingSales[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => ReceiptScreen(initialData: sale)),
                                  );
                                },
                                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                child: AppTheme.buildCard(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            sale['vehicleNo'] ?? 'N/A',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Colors.orange.withOpacity(0.5)),
                                            ),
                                            child: const Text(
                                              'PENDING',
                                              style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoColumn('Broker', sale['brokerName'] ?? 'N/A'),
                                          _buildInfoColumn('Date', _formatDate(sale['date'])),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildInfoColumn('Flock', sale['flockNo'] ?? 'N/A'),
                                          _buildInfoColumn('Weight', '${sale['weight1'] ?? 0} Kg'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// --- Reports Screen (List) ---

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<dynamic> _sales = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    final result = await ApiService.getSales();
    if (mounted) {
      setState(() {
        if (result['success']) {
          _sales = result['data'];
        } else {
          _error = result['message'];
        }
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Sales Reports'),
        backgroundColor: const Color(0xFF8B2E8B),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/Logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await AuthService.clearAuth();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'logout', child: Text('LogOut')),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppTheme.buildBackground(context),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                    : _sales.isEmpty
                        ? const Center(child: Text('No sales records found', style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _sales.length,
                            itemBuilder: (context, index) {
                              final sale = _sales[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(sale['vehicleNo'] ?? 'N/A',
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(_formatDate(sale['date']),
                                            style: const TextStyle(color: Colors.white54)),
                                      ],
                                    ),
                                    const Divider(height: 24, color: Colors.white10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _reportStat('Weight', '${sale['netWeight'] ?? 0} kg'),
                                        _reportStat('Rate', 'Rs ${sale['rate'] ?? 0}'),
                                        _reportStat('Total', 'Rs ${sale['totalAmount'] ?? 0}'),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _reportStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// --- Vehicle Detail Screen (Added) ---

class VehicleDetailScreen extends StatelessWidget {
  const VehicleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Vehicle Detail'),
        backgroundColor: const Color(0xFF8B2E8B),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/Logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await AuthService.clearAuth();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'logout', child: Text('LogOut')),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppTheme.buildBackground(context),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        return _buildVehicleDetailCard(index + 1);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B2E8B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Back', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetailCard(int index) {
    final weights = ['30 Kg', '70 Kg', '25 Kg', '10 Kg', '70 Kg', '60 Kg', '40 Kg'];
    final dates = ['15-02-22', '12-02-22', '21-02-22', '18-02-22', '22-02-22', '11-02-22', '11-02-22'];
    final houses = ['House#1', 'House#21', 'House#28', 'House#17', 'House#15', 'House#13', 'House#12'];
    final flocks = ['Flock#1', 'Flock#71', 'Flock#30', 'Flock#22', 'Flock#13', 'Flock#12', 'Flock#31'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Index Number - Purple Circle
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF8B2E8B),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Details - Weight label and House/Flock info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weight',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '${houses[index % 7]}   ${flocks[index % 7]}',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          // Value and Date - Right side
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                weights[index % 7],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                dates[index % 7],
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// --- Sales Report Screen ---

class SalesReportScreen extends StatefulWidget {
  final Map<String, dynamic>? saleData;
  const SalesReportScreen({super.key, this.saleData});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  Map<String, dynamic>? _saleData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.saleData != null) {
      _saleData = widget.saleData;
    } else {
      _isLoading = true;
      _loadSaleData();
    }
  }

  Future<void> _loadSaleData() async {
    final result = await ApiService.getSales();
    if (mounted) {
      setState(() {
        if (result['success'] && result['data'] != null && (result['data'] as List).isNotEmpty) {
          // Get the most recent sale
          final sales = result['data'] as List;
          _saleData = sales.first;
        } else {
          _error = 'No sales data available';
        }
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF8B2E8B))),
      );
    }

    if (_error != null && _saleData == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text(_error!, style: const TextStyle(color: Colors.white))),
      );
    }

    final data = _saleData!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Sales Report'),
        backgroundColor: const Color(0xFF8B2E8B),
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 1)),
              (route) => false,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: ClipOval(child: Image.asset('assets/images/Logo.png', fit: BoxFit.cover)),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReceipt(data),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppTheme.buildBackground(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  AppTheme.buildCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(AppTheme.borderRadius),
                              topRight: Radius.circular(AppTheme.borderRadius),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Sales Receipt",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildReportRow("Vehicle No", data['vehicleNo'] ?? 'N/A'),
                              _buildReportRow("Date", _formatDate(data['date'])),
                              _buildReportRow("House No", data['houseNo'] ?? 'N/A'),
                              _buildReportRow("Flock No", data['flockNo'] ?? 'N/A'),
                              const Divider(color: Colors.white10, height: 24),
                              _buildReportRow("Weight One", "${data['weight1'] ?? 0} Kg"),
                              _buildReportRow("Weight Two", "${data['weight2'] ?? 0} Kg"),
                              _buildReportRow("Net Weight", "${data['netWeight'] ?? 0} Kg"),
                              _buildReportRow("Rate", "Rs ${data['rate'] ?? 0}"),
                              const Divider(color: Colors.white10, height: 24),
                              _buildReportRow("Total Amount", "Rs ${data['totalAmount'] ?? 0}"),
                              _buildReportRow("Due", "Rs ${data['due'] ?? 0}"),
                              _buildReportRow("Broker Name", data['brokerName'] ?? 'N/A'),
                              _buildReportRow("Commission", "Rs ${data['commission'] ?? 0}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () => _printReceipt(data),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(color: const Color(0xFF8B2E8B), borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text("Print", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainNavigationScreen(initialIndex: 1)),
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text("Back", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printReceipt(Map<String, dynamic> data) async {
    final pdf = await _generatePdf(data);
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> _shareReceipt(Map<String, dynamic> data) async {
    final pdf = await _generatePdf(data);
    final pdfBytes = await pdf.save();
    
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/receipt_${data['_id']}.pdf';
    final file = File(path);
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles([XFile(path)], text: 'Sales Receipt for Vehicle: ${data['vehicleNo']}');
  }

  Future<pw.Document> _generatePdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    final themeColor = PdfColor.fromInt(0xFF8B2E8B); // AppTheme.primary

    // Load Logo image
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/Logoo.jpeg');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (e) {
      print('Error loading receipt logo: $e');
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header with Theme Background
              if (logoImage != null)
                pw.Container(
                  width: 50,
                  height: 50,
                  margin: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Image(logoImage),
                ),
              pw.Text(
                'Gondal Protein Farms',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: themeColor),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: pw.BoxDecoration(color: themeColor, borderRadius: pw.BorderRadius.circular(2)),
                child: pw.Text(
                  'SALES RECEIPT',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                ),
              ),
              pw.SizedBox(height: 15),

              // Details Section
              pw.Container(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildPdfRow('Vehicle No:', data['vehicleNo'] ?? 'N/A'),
                    _buildPdfRow('Date:', _formatDate(data['date'])),
                    _buildPdfRow('House No:', data['houseNo'] ?? 'N/A'),
                    _buildPdfRow('Flock No:', data['flockNo'] ?? 'N/A'),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 8),
                      child: pw.Divider(thickness: 1, color: themeColor),
                    ),
                    _buildPdfRow('Weight One:', '${data['weight1'] ?? 0} Kg'),
                    _buildPdfRow('Weight Two:', '${data['weight2'] ?? 0} Kg'),
                    _buildPdfRow('Net Weight:', '${data['netWeight'] ?? 0} Kg'),
                    _buildPdfRow('Rate:', 'Rs ${data['rate'] ?? 0}'),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 8),
                      child: pw.Divider(thickness: 1.5, color: themeColor),
                    ),
                    _buildPdfRow('Total Amount:', 'Rs ${data['totalAmount'] ?? 0}', isHighlight: true),
                    pw.Divider(thickness: 0.5, color: themeColor), // Double line effect
                    pw.SizedBox(height: 4),
                    _buildPdfRow('Due:', 'Rs ${data['due'] ?? 0}'),
                    _buildPdfRow('Advance:', 'Rs ${data['advance'] ?? 0}'),
                    _buildPdfRow('Broker Name:', data['brokerName'] ?? 'N/A'),
                    _buildPdfRow('Commission:', 'Rs ${data['commission'] ?? 0}'),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 25),
              
              // Signature Line
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                   pw.Column(
                     children: [
                        pw.Container(width: 100, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 0.5, color: PdfColors.black)))),
                        pw.SizedBox(height: 4),
                        pw.Text('Authorized Signature', style: const pw.TextStyle(fontSize: 8)),
                     ]
                   )
                ]
              ),
              
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 0.5, color: themeColor),
              pw.SizedBox(height: 8),
              
              // Footer info
              pw.Text(
                'Dera Farman Ali Gondal 5 KM, Kotmomin Bhalwal Road, Lilliani, Kotmomin Dist, Sargodha',
                style: const pw.TextStyle(fontSize: 7),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'E-mail: gondalproteinfarms@gmail.com',
                style: pw.TextStyle(fontSize: 7, color: themeColor),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'Mob: 0321-8462009, 0300-6012632',
                style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
              
              pw.SizedBox(height: 15),
              
              // QR CODE and Pro Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Container(
                    height: 40,
                    width: 40,
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: 'Gondal Protein Farms Receipt: ${data['_id']}',
                      color: themeColor,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(4)),
                child: pw.Center(
                  child: pw.Text(
                    'PROCESSED BY FARMER MANAGER',
                    style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700),
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Thank you for your business!',
                style: pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic, color: themeColor),
              ),
            ],
          );
        },
      ),
    );
    
    return pdf;
  }

  pw.Widget _buildPdfRow(String label, String value, {bool isHighlight = false}) {
    final themeColor = PdfColor.fromInt(0xFF8B2E8B);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label, 
            style: pw.TextStyle(fontSize: isHighlight ? 11 : 9, color: isHighlight ? themeColor : PdfColors.black, fontWeight: isHighlight ? pw.FontWeight.bold : null)
          ),
          pw.Text(
            value, 
            style: pw.TextStyle(fontSize: isHighlight ? 11 : 9, fontWeight: pw.FontWeight.bold, color: isHighlight ? themeColor : PdfColors.black)
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// --- Settings Screen (Admin Only) ---

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _houseNoController = TextEditingController();
  final _flockNoController = TextEditingController();
  final _priceController = TextEditingController();
  final _dateController = TextEditingController();
  bool _isLoading = false;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final result = await ApiService.getSettings();
      if (result['success'] && result['data'].isNotEmpty) {
        final settings = result['data'][0]; // Get first settings record
        setState(() {
          _houseNoController.text = settings['houseNo'] ?? '';
          _flockNoController.text = settings['flockNo'] ?? '';
          _priceController.text = settings['price']?.toString() ?? '';
          _dateController.text = settings['date'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    if (_houseNoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('House No is required')),
      );
      return;
    }
    if (_flockNoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flock No is required')),
      );
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Price is required')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final settingsData = {
      'houseNo': _houseNoController.text.trim(),
      'flockNo': _flockNoController.text.trim(),
      'price': double.tryParse(_priceController.text) ?? 0,
      'date': _dateController.text.trim(),
    };

    // First try to get existing settings
    final existingResult = await ApiService.getSettings();
    if (existingResult['success'] && existingResult['data'].isNotEmpty) {
      // Update existing settings
      final settingsId = existingResult['data'][0]['_id'];
      final result = await ApiService.updateSettings(settingsId, settingsData);
      
      if (result['success']) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings updated successfully!')),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to update settings')),
        );
      }
    } else {
      // Create new settings
      final result = await ApiService.createSettings(settingsData);
      
      if (result['success']) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!')),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to save settings')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8B2E8B),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      });
    }
  }

  @override
  void dispose() {
    _houseNoController.dispose();
    _flockNoController.dispose();
    _priceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8B2E8B),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/Logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await AuthService.clearAuth();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'logout', child: Text('LogOut')),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppTheme.buildBackground(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  // Header
                  AppTheme.buildCard(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Center(
                      child: Text(
                        'Admin Settings',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // House No Field
                  AppTheme.buildTextField(
                    label: 'House No',
                    controller: _houseNoController,
                    hint: 'Enter House Number',
                  ),
                  const SizedBox(height: 24),
                  // Flock No Field
                  AppTheme.buildTextField(
                    label: 'Flock No',
                    controller: _flockNoController,
                    hint: 'Enter Flock Number',
                  ),
                  const SizedBox(height: 24),
                  // Price Field
                  AppTheme.buildTextField(
                    label: 'Price',
                    controller: _priceController,
                    hint: 'Enter Price',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Rs ', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  // Date Field
                  AppTheme.buildTextField(
                    label: 'Date',
                    controller: _dateController,
                    hint: 'Select Date',
                    readOnly: true,
                    onTap: _selectDate,
                    suffixIcon: const Icon(Icons.calendar_today, color: AppTheme.textSecondary, size: 20),
                  ),
                  const SizedBox(height: 40),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B2E8B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsField(
    String label, {
    required TextEditingController controller,
    String? hint,
    Widget? prefix,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
          ),
          child: Row(
            children: [
              if (prefix != null) ...[
                prefix,
                const SizedBox(width: 4),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.normal),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if (suffix != null) suffix,
            ],
          ),
        ),
      ],
    );
  }
}

// --- Payment Screen ---

class PaymentScreen extends StatefulWidget {
  final String saleId;
  final Map<String, dynamic> initialData;

  const PaymentScreen({super.key, required this.saleId, required this.initialData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _cashController = TextEditingController();
  final _commissionController = TextEditingController();
  final _onlinePaymentController = TextEditingController();
  
  // Payment methods management
  List<String> _onlinePaymentMethods = [];
  List<String> _selectedOnlineMethods = []; // Support multiple selections
  final _accountHolderController = TextEditingController();
  final _bankNameController = TextEditingController();
  
  // Selected payment method details - multiple entries
  List<Map<String, dynamic>> _selectedPaymentEntries = [];
  
  double _totalAmount = 0;
  double _netWeight = 0;
  double _advance = 0;
  String _brokerName = "";
  bool _isLoading = false;
  
  // New payment method fields
  bool _showAddSection = false;
  final _newAccountHolderController = TextEditingController();
  final _newBankNameController = TextEditingController();
  
  // Display controllers
  late TextEditingController _totalAmountController;
  late TextEditingController _advanceAmountController;

  @override
  void initState() {
    super.initState();
    _totalAmount = (widget.initialData['totalAmount'] ?? 0).toDouble();
    _netWeight = (widget.initialData['netWeight'] ?? 0).toDouble();
    _advance = (widget.initialData['advance'] ?? 0).toDouble();
    _brokerName = widget.initialData['brokerName'] ?? "";
    
    // Ensure 0 values are treated as empty to show placeholders
    final initialCash = widget.initialData['cashAmount'] ?? 0;
    _cashController.text = (initialCash.toString() == '0' || initialCash.toString() == '0.0') ? '' : _formatNumber(initialCash);
    
    final initialComm = widget.initialData['commission'] ?? 0;
    _commissionController.text = (initialComm.toString() == '0' || initialComm.toString() == '0.0') ? '' : _formatNumber(initialComm);
    
    _totalAmountController = TextEditingController(text: _formatNumber(_totalAmount));
    _advanceAmountController = TextEditingController(text: _formatNumber(_advance));
    
    _loadPaymentMethods();
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final int value = number is num ? number.toInt() : int.tryParse(number.toString().replaceAll(',', '')) ?? 0;
    return value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  void _parseSelectedPaymentMethod(String selectedMethod) {
    if (selectedMethod.contains(' - ')) {
      final parts = selectedMethod.split(' - ');
      if (parts.length >= 2) {
        setState(() {
          // Check if this method is NOT already selected
          if (!_selectedPaymentEntries.any((entry) => entry['method'] == selectedMethod)) {
            _selectedPaymentEntries.add({
              'method': selectedMethod,
              'accountHolder': parts[0],
              'bankName': parts[1],
              'amount': TextEditingController(),
            });
          }
        });
      }
    }
  }

  void _removePaymentEntry(int index) {
    setState(() {
      _selectedPaymentEntries.removeAt(index);
    });
  }

  void _formatAmount(TextEditingController controller) {
    String text = controller.text.replaceAll(',', '');
    if (text.isEmpty) return;
    
    final value = double.tryParse(text);
    if (value != null) {
      // Simple comma formatting
      String numberStr = value.toStringAsFixed(0);
      String result = '';
      int len = numberStr.length;
      
      for (int i = 0; i < len; i++) {
        if ((len - i) % 3 == 0 && i != 0) {
          result += ',';
        }
        result += numberStr[i];
      }
      
      controller.text = result;
    }
  }

  Future<void> _saveNewPaymentMethod() async {
    if (_newAccountHolderController.text.isEmpty || _newBankNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both Account Holder and Bank Name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.createPaymentMethod({
        'accountHolder': _newAccountHolderController.text.trim(),
        'bankName': _newBankNameController.text.trim(),
      });

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method saved!')),
        );
        _newAccountHolderController.clear();
        _newBankNameController.clear();
        setState(() => _showAddSection = false);
        _loadPaymentMethods();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to save')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final result = await ApiService.getOnlinePaymentMethods();
      if (result['success']) {
        setState(() {
          // Backend returns array of objects with accountHolder and bankName
          // Convert to display format: "Account Holder - Bank Name"
          _onlinePaymentMethods = (result['data'] as List)
              .map((method) => '${method['accountHolder']} - ${method['bankName']}')
              .toList();
        });
      }
    } catch (e) {
      print('Error loading payment methods: $e');
    }
  }

  double get _totalOnlinePaid {
    double total = 0.0;
    for (var entry in _selectedPaymentEntries) {
      total += double.tryParse(entry['amount']!.text.replaceAll(',', '')) ?? 0.0;
    }
    return total;
  }

  double get _due {
    double cash = double.tryParse(_cashController.text.replaceAll(',', '')) ?? 0.0;
    double commission = double.tryParse(_commissionController.text.replaceAll(',', '')) ?? 0.0;
    double totalOnlinePaid = _totalOnlinePaid;
    return _totalAmount - (_advance + cash + totalOnlinePaid + commission);
  }

  Future<void> _finalizeReceipt() async {
    setState(() => _isLoading = true);
    
    final bankPayments = _selectedPaymentEntries.map((e) => {
      'amount': double.tryParse(e['amount']!.text.replaceAll(',', '')) ?? 0,
      'accountTitle': e['accountHolder'],
      'bankName': e['bankName'],
    }).toList();

    final saleData = {
      'status': 'completed',
      'cashAmount': double.tryParse(_cashController.text.replaceAll(',', '')) ?? 0,
      'bankPayments': bankPayments,
      'commission': double.tryParse(_commissionController.text.replaceAll(',', '')) ?? 0,
      'due': _due,
      'paymentMethod': bankPayments.isNotEmpty ? (_cashController.text != "0" ? 'Mixed' : 'Bank') : 'Cash',
    };

    try {
      final result = await ApiService.updateSale(widget.saleId, saleData);
      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receipt finalized successfully!')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => SalesReportScreen(
                saleData: result['data'],
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to finalize receipt')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: const Color(0xFF8B2E8B),
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AppTheme.buildBackground(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Summary Info at Top
                  AppTheme.buildCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      children: [
                        _buildSummaryRow("Total Amount", "Rs ${_totalAmountController.text}"),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Colors.white10),
                        ),
                        _buildSummaryRow("Advance Amount", "Rs ${_advanceAmountController.text}"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildPaymentField("Cash", _cashController, hint: "0"),
                  const SizedBox(height: 24),

                  // Online Payment Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Online Payment", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () => setState(() => _showAddSection = !_showAddSection),
                        icon: Icon(_showAddSection ? Icons.close : Icons.add_circle_outline, size: 20, color: AppTheme.primary),
                        label: Text(_showAddSection ? "Cancel" : "Add Method", style: const TextStyle(color: AppTheme.primary)),
                      ),
                    ],
                  ),

                  if (_showAddSection) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          _buildUnderlinedField("Account Holder Name", _newAccountHolderController),
                          const SizedBox(height: 12),
                          _buildUnderlinedField("Bank Name", _newBankNameController),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveNewPaymentMethod,
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                              child: const Text("Save Method"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  AppTheme.buildDropdownField<String>(
                    label: "Select Online Payment Method",
                    value: null,
                    hint: "Choose from saved methods",
                    items: _onlinePaymentMethods.map((method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) _parseSelectedPaymentMethod(value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Selected Payments List
                  ..._selectedPaymentEntries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final payment = entry.value;
                    return AppTheme.buildCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      payment['accountHolder'],
                                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Text(
                                      payment['bankName'],
                                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () => _removePaymentEntry(index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white10, height: 20),
                          _buildPaymentField("Amount Paid", payment['amount'], isCurrency: true),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 16),

                  AppTheme.buildTextField(
                    label: "Due",
                    controller: TextEditingController(text: "Rs ${_formatNumber(_due)}"),
                    readOnly: true,
                  ),
                  const SizedBox(height: 24),

                  _buildDisplayField("Broker Name", _brokerName),
                  const SizedBox(height: 20),

                  _buildPaymentField("Commission", _commissionController, hint: "0"),
                  const SizedBox(height: 32),

                  GestureDetector(
                    onTap: _isLoading ? null : _finalizeReceipt,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _isLoading ? Colors.grey : const Color(0xFF8B2E8B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Finalize Receipt", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF333333),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text("Back", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentField(String label, TextEditingController controller, {bool isCurrency = true, String? hint}) {
    return AppTheme.buildTextField(
      label: label,
      controller: controller,
      hint: hint,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        if (isCurrency) {
          String cleanValue = value.replaceAll(',', '');
          if (cleanValue.isNotEmpty) {
            String formatted = _formatNumber(cleanValue);
            controller.value = TextEditingController.fromValue(
              TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              ),
            ).value;
          }
        }
        setState(() {});
      },
      prefixIcon: const Padding(
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Rs ", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildUnderlinedField(String label, TextEditingController controller) {
    return AppTheme.buildTextField(
      label: label,
      controller: controller,
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDisplayField(String label, String value) {
    return AppTheme.buildTextField(
      label: label,
      controller: TextEditingController(text: value),
      readOnly: true,
    );
  }
}
