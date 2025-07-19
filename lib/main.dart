import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  runApp(BIWorkTrackerApp());
}

class BIWorkTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BI WorkTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: SplashScreen(),
    );
  }
}

// API Service Class
class ApiService {
  // Production URL - Update this when deploying to custom domain
  static const String baseUrl = 'https://workspace.yavuzsahins.repl.co';
  // For production deployment, replace with: 'https://yourdomain.com'
  
  static String? _token;
  static User? _currentUser;
  
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);
        
        // Save token to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_data', jsonEncode(data['user']));
        
        return {'success': true, 'user': _currentUser};
      } else {
        return {'success': false, 'message': 'Invalid credentials'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  static Future<bool> checkIn(double latitude, double longitude, String locationName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/checkin'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'locationName': locationName,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  static Future<bool> checkOut(double latitude, double longitude, String locationName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'locationName': locationName,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  static Future<Map<String, dynamic>> getStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/status'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error getting status: $e');
    }
    return {'isWorking': false};
  }
  
  static Future<List<WorkLog>> getLogs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/logs'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['logs'] as List)
            .map((log) => WorkLog.fromJson(log))
            .toList();
      }
    } catch (e) {
      print('Error getting logs: $e');
    }
    return [];
  }
  
  static Future<void> logout() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
  
  static Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');
      
      if (token != null && userData != null) {
        _token = token;
        _currentUser = User.fromJson(jsonDecode(userData));
        return true;
      }
    } catch (e) {
      print('Error restoring session: $e');
    }
    return false;
  }
  
  static User? get currentUser => _currentUser;
  static String? get token => _token;
}

// Models
class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String language;
  final String role;
  final bool isActive;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.language,
    required this.role,
    required this.isActive,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
      language: json['language'],
      role: json['role'],
      isActive: json['isActive'],
    );
  }
}

class WorkLog {
  final int id;
  final int userId;
  final String type;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  
  WorkLog({
    required this.id,
    required this.userId,
    required this.type,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.locationName,
  });
  
  factory WorkLog.fromJson(Map<String, dynamic> json) {
    return WorkLog(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      locationName: json['locationName'],
    );
  }
}

// Location Service
class LocationService {
  static Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
  
  static Future<Position?> getCurrentLocation() async {
    try {
      if (await checkPermissions()) {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
    return null;
  }
  
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    // This would typically use a geocoding service
    // For now, return formatted coordinates
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    await Future.delayed(Duration(seconds: 2));
    
    final hasSession = await ApiService.restoreSession();
    
    if (hasSession) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ApiService.currentUser?.role == 'admin' 
              ? AdminDashboard() 
              : MobileDashboard(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade600,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 24),
            Image.asset(
              'assets/images/logo.png',
              height: 120,
              width: 200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24),
            Text(
              'BI WorkTracker',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Professional Work Tracking System',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter username and password');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final result = await ApiService.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );
    
    setState(() {
      _isLoading = false;
    });
    
    if (result['success']) {
      final user = result['user'] as User;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => user.role == 'admin' 
              ? AdminDashboard() 
              : MobileDashboard(),
        ),
      );
    } else {
      _showError(result['message']);
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'BI WorkTracker',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 48),
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

// Mobile Dashboard (Employee Interface)
class MobileDashboard extends StatefulWidget {
  @override
  _MobileDashboardState createState() => _MobileDashboardState();
}

class _MobileDashboardState extends State<MobileDashboard> {
  bool _isWorking = false;
  bool _isLoading = false;
  List<WorkLog> _workLogs = [];
  Timer? _statusTimer;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _startStatusTimer();
  }
  
  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
  
  void _startStatusTimer() {
    _statusTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _checkStatus();
    });
  }
  
  Future<void> _loadInitialData() async {
    await _checkStatus();
    await _loadWorkLogs();
  }
  
  Future<void> _checkStatus() async {
    final status = await ApiService.getStatus();
    if (mounted) {
      setState(() {
        _isWorking = status['isWorking'] ?? false;
      });
    }
  }
  
  Future<void> _loadWorkLogs() async {
    final logs = await ApiService.getLogs();
    if (mounted) {
      setState(() {
        _workLogs = logs;
      });
    }
  }
  
  Future<void> _toggleWorkStatus() async {
    setState(() {
      _isLoading = true;
    });
    
    final position = await LocationService.getCurrentLocation();
    if (position == null) {
      _showError('Location permission required');
      setState(() {
        _isLoading = false;
      });
      return;
    }
    
    final locationName = await LocationService.getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );
    
    bool success;
    if (_isWorking) {
      success = await ApiService.checkOut(
        position.latitude,
        position.longitude,
        locationName,
      );
    } else {
      success = await ApiService.checkIn(
        position.latitude,
        position.longitude,
        locationName,
      );
    }
    
    setState(() {
      _isLoading = false;
    });
    
    if (success) {
      await _checkStatus();
      await _loadWorkLogs();
      _showSuccess(_isWorking ? 'Checked out successfully' : 'Checked in successfully');
    } else {
      _showError('Failed to update status');
    }
  }
  
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Future<void> _logout() async {
    await ApiService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('BI WorkTracker'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade600,
                        child: Text(
                          user?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Unknown User',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isWorking ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _isWorking ? 'Working' : 'Not Working',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Check In/Out Button
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _toggleWorkStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isWorking ? Colors.red.shade600 : Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isWorking ? Icons.logout : Icons.login,
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              _isWorking ? 'Check Out' : 'Check In',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
              
              SizedBox(height: 32),
              
              // Recent Activity
              Text(
                'Recent Activity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              
              if (_workLogs.isEmpty)
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.history, size: 48, color: Colors.grey.shade400),
                          SizedBox(height: 16),
                          Text(
                            'No activity yet',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ..._workLogs.take(10).map((log) => Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: log.type == 'checkin' ? Colors.green : Colors.red,
                      child: Icon(
                        log.type == 'checkin' ? Icons.login : Icons.logout,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      log.type == 'checkin' ? 'Checked In' : 'Checked Out',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('MMM dd, yyyy - HH:mm').format(log.timestamp)),
                        if (log.locationName != null)
                          Text(
                            log.locationName!,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                    trailing: Icon(Icons.location_on, color: Colors.grey.shade400),
                  ),
                )).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

// Admin Dashboard
class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BI WorkTracker Admin'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await ApiService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings, size: 80, color: Colors.blue.shade600),
            SizedBox(height: 24),
            Text(
              'BI WorkTracker Admin',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Use the web interface for full admin features',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MobileDashboard()),
                );
              },
              child: Text('Switch to Employee View'),
            ),
          ],
        ),
      ),
    );
  }
}