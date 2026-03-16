import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
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
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isAdmin = false;
  List<Widget> _screens = [];

  final GlobalKey<_HomeScreenState> _homeKey = GlobalKey<_HomeScreenState>();
  final GlobalKey<_PendingVehiclesScreenState> _pendingKey = GlobalKey<_PendingVehiclesScreenState>();

  @override
  void initState() {
    super.initState();
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
                              const SizedBox(height: 80),
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
                                    onPressed: () {},
                                    child: const Text('View All', style: TextStyle(color: AppTheme.accent)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
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

  Widget _buildTransactionList() {
    if (_recentSales.isEmpty) {
      return AppTheme.buildCard(
        child: const Center(
          child: Text('No sales recorded today', style: AppTheme.bodyMedium),
        ),
      );
    }

    return Column(
      children: _recentSales.take(5).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final sale = entry.value;
        return AppTheme.buildCard(
          padding: const EdgeInsets.all(16).copyWith(bottom: 0),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('Sale ${index + 1}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _infoLine('House No:', sale['houseNo'] ?? 'N/A'),
                        ),
                        Expanded(
                          child: _infoLine('Flock No:', sale['flockNo'] ?? 'N/A'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _infoLine('Total Weight:', '${sale['netWeight'] ?? 0}kg'),
                        ),
                        Expanded(
                          child: _infoLine('Total Payments:', '${sale['totalAmount'] ?? 0}K'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right, color: Colors.white, size: 24),
              ),
            ],
          ),
        ));
      }).toList(),
    );
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
  String? _selectedVehicle;
  String? _selectedWeight;
  String? _selectedFlock;
  bool _isLoading = false;
  String? _validationError;
  bool _showVehicleDropdown = false;

  @override
  void initState() {
    super.initState();
    _loadTodaySettings();
    _loadVehicleNumbers();
    _loadFlockNumbers();
    
    if (widget.initialData != null) {
      final data = widget.initialData!;
      _vehicleController.text = data['vehicleNo'] ?? '';
      _brokerController.text = data['brokerName'] ?? '';
      _houseController.text = data['houseNo'] ?? '';
      _selectedFlock = data['flockNo']?.toString();
      _flockController.text = _selectedFlock ?? '';
      _advanceController.text = data['advance']?.toString() ?? '';
      _weight1Controller.text = data['weight1']?.toString() ?? '';
      _weight2Controller.text = data['weight2']?.toString() ?? '';
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
            _houseController.text = todaySettings['houseNo'] ?? '';
            _selectedFlock = todaySettings['flockNo'] ?? '';
            _flockController.text = _selectedFlock ?? '';
            _priceController.text = todaySettings['price']?.toString() ?? '';
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
    setState(() {
      // Don't re-assign to controller.text here as it causes cursor jumping
      // _vehicleController.text = value; 
      
      // Always show filtered vehicles for suggestions, but don't restrict typing
      _filteredVehicles = _vehicleNumbers
          .where((vehicle) => vehicle.toLowerCase().contains(value.toLowerCase()))
          .toList();
      _showVehicleDropdown = value.isNotEmpty && _filteredVehicles.isNotEmpty;
    });

    // Auto-fetch vehicle when user types a potential full number
    if (value.length >= 3) {
      _fetchVehicleFromAPI(value);
    } else if (value.isEmpty) {
      _brokerController.clear();
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

  double get _netWeight {
    final w1 = double.tryParse(_weight1Controller.text) ?? 0;
    final w2 = double.tryParse(_weight2Controller.text) ?? 0;
    return w2 - w1;
  }

  double get _totalAmount {
    final rate = double.tryParse(_rateController.text) ?? 0;
    return _netWeight * rate;
  }


  @override
  void dispose() {
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
                  const SizedBox(height: 80),
                  // Top Data Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTheme.buildTextField(
                          label: 'House#',
                          controller: _houseController,
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedFlock = newValue;
                              _flockController.text = newValue ?? '';
                            });
                          },
                          hint: 'Select',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTheme.buildTextField(
                          label: 'Date',
                          controller: TextEditingController(text: '${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}'),
                          readOnly: true,
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
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Rs ', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
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
                      controller: TextEditingController(text: '${_netWeight.toStringAsFixed(2)} kg'),
                      readOnly: true,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Broker Name Field
                  AppTheme.buildTextField(
                    label: 'Broker Name',
                    controller: _brokerController,
                    hint: 'Enter broker name',
                  ),
                  const SizedBox(height: 24),

                  // Rate Field
                  AppTheme.buildTextField(
                    label: 'Rate',
                    controller: _rateController,
                    hint: 'Rs 0',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 32),

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
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppTheme.buildTextField(
          label: 'Vehicle Number',
          controller: _vehicleController,
          hint: 'Enter vehicle number',
          onChanged: _onVehicleChanged,
          suffixIcon: IconButton(
            icon: const Icon(Icons.search, color: AppTheme.primary, size: 20),
            onPressed: () {
              if (_vehicleController.text.isNotEmpty) {
                _fetchVehicleFromAPI(_vehicleController.text);
              }
            },
          ),
        ),
        if (_showVehicleDropdown)
          Positioned(
            top: 76,
            left: 0,
            right: 0,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                border: Border.all(color: AppTheme.primary, width: 1),
              ),
              child: ListView.builder(
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
      ],
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
    if (_rateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rate is required')),
      );
      return;
    }

    // Additional validation for finalizing
    if (widget.initialData != null) {
      if (_weight2Controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weight 2 is required to finalize')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final isFinalizing = widget.initialData != null;
    final advance = double.tryParse(_advanceController.text) ?? 0;
    
    final saleData = {
      'vehicleNo': _vehicleController.text.trim(),
      'brokerName': _brokerController.text.trim(),
      'houseNo': _houseController.text.trim(),
      'flockNo': _flockController.text.trim(),
      'weight1': double.tryParse(_weight1Controller.text) ?? 0,
      'weight2': isFinalizing ? (double.tryParse(_weight2Controller.text) ?? 0) : 0,
      'netWeight': isFinalizing ? _netWeight : 0,
      'rate': double.tryParse(_rateController.text) ?? 0,
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vehicle added to pending tasks!')),
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
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  ),
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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: ClipOval(child: Image.asset('assets/images/Logo.png', fit: BoxFit.cover)),
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
                    onTap: () => Navigator.of(context).pop(),
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
    
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('SALES RECEIPT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              _buildPdfRow('Vehicle No:', data['vehicleNo'] ?? 'N/A'),
              _buildPdfRow('Date:', _formatDate(data['date'])),
              _buildPdfRow('House No:', data['houseNo'] ?? 'N/A'),
              _buildPdfRow('Flock No:', data['flockNo'] ?? 'N/A'),
              pw.Divider(),
              _buildPdfRow('Weight One:', '${data['weight1'] ?? 0} Kg'),
              _buildPdfRow('Weight Two:', '${data['weight2'] ?? 0} Kg'),
              _buildPdfRow('Net Weight:', '${data['netWeight'] ?? 0} Kg'),
              _buildPdfRow('Rate:', 'Rs ${data['rate'] ?? 0}'),
              pw.Divider(),
              _buildPdfRow('Total Amount:', 'Rs ${data['totalAmount'] ?? 0}'),
              _buildPdfRow('Due:', 'Rs ${data['due'] ?? 0}'),
              _buildPdfRow('Advance:', 'Rs ${data['advance'] ?? 0}'),
              _buildPdfRow('Broker Name:', data['brokerName'] ?? 'N/A'),
              _buildPdfRow('Commission:', 'Rs ${data['commission'] ?? 0}'),
              pw.SizedBox(height: 20),
              pw.Center(child: pw.Text('Thank you!', style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic))),
            ],
          );
        },
      ),
    );
    
    return pdf;
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
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
  final _cashController = TextEditingController(text: "0");
  final _commissionController = TextEditingController(text: "0");
  final List<Map<String, TextEditingController>> _bankEntries = [];
  
  double _totalAmount = 0;
  double _netWeight = 0;
  double _advance = 0;
  String _brokerName = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _totalAmount = (widget.initialData['totalAmount'] ?? 0).toDouble();
    _netWeight = (widget.initialData['netWeight'] ?? 0).toDouble();
    _advance = (widget.initialData['advance'] ?? 0).toDouble();
    _brokerName = widget.initialData['brokerName'] ?? "";
  }

  void _addBankEntry() {
    setState(() {
      _bankEntries.add({
        'amount': TextEditingController(text: "0"),
        'title': TextEditingController(),
        'bankName': TextEditingController(),
      });
    });
  }

  double get _totalBankPaid {
    double total = 0;
    for (var entry in _bankEntries) {
      total += double.tryParse(entry['amount']!.text) ?? 0;
    }
    return total;
  }

  double get _due {
    double cash = double.tryParse(_cashController.text) ?? 0;
    double commission = double.tryParse(_commissionController.text) ?? 0;
    return _totalAmount - (_advance + cash + _totalBankPaid + commission);
  }

  Future<void> _finalizeReceipt() async {
    setState(() => _isLoading = true);
    
    final bankPayments = _bankEntries.map((e) => {
      'amount': double.tryParse(e['amount']!.text) ?? 0,
      'accountTitle': e['title']!.text,
      'bankName': e['bankName']!.text,
    }).toList();

    final saleData = {
      'status': 'completed',
      'cashAmount': double.tryParse(_cashController.text) ?? 0,
      'bankPayments': bankPayments,
      'commission': double.tryParse(_commissionController.text) ?? 0,
      'due': _due,
      'paymentMethod': _bankEntries.isNotEmpty ? (_cashController.text != "0" ? 'Mixed' : 'Bank') : 'Cash',
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
                  const SizedBox(height: 10),
                  AppTheme.buildCard(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: const Center(
                      child: Text(
                        "Payment Method",
                        style: TextStyle(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildPaymentField("Cash", _cashController),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Bank", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      TextButton(
                        onPressed: _addBankEntry,
                        child: const Text("Add", style: TextStyle(color: Color(0xFF8B2E8B), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  ..._bankEntries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controllers = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        children: [
                          _buildPaymentField("Amount", controllers['amount']!),
                          _buildUnderlinedField("Account Title", controllers['title']!),
                          _buildUnderlinedField("Bank Name", controllers['bankName']!),
                          if (_bankEntries.length > 1)
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                onPressed: () => setState(() => _bankEntries.removeAt(index)),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: AppTheme.buildTextField(
                          label: "Due",
                          controller: TextEditingController(text: "Rs ${_due.toStringAsFixed(0)}"),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTheme.buildTextField(
                          label: "Weight",
                          controller: TextEditingController(text: "${_netWeight.toStringAsFixed(2)} kg"),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  AppTheme.buildTextField(
                    label: "Broker Name",
                    controller: TextEditingController(text: _brokerName),
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),

                  AppTheme.buildTextField(
                    label: "Commission",
                    controller: _commissionController,
                    hint: "Rs 0",
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Rs ", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),

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
                            : const Text("Get Receipt", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildPaymentField(String label, TextEditingController controller, {bool isCurrency = false}) {
    return AppTheme.buildTextField(
      label: label,
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      prefixIcon: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Rs ", style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildUnderlinedField(String label, TextEditingController controller) {
    return AppTheme.buildTextField(
      label: label,
      controller: controller,
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
