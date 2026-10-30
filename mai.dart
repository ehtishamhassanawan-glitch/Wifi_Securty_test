import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const WifiSecurityApp());
}

class WifiSecurityApp extends StatelessWidget {
  const WifiSecurityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Security Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  String? selectedWifi;

  // Mock Wi-Fi List
  final List> wifiList = [
    {'ssid': 'MyHome_WiFi_5G', 'signal': 'Strong', 'icon': Icons.wifi},
    {'ssid': 'Tenda_Office_Net', 'signal': 'Medium', 'icon': Icons.wifi},
    {'ssid': 'PTCL-BB-892', 'signal': 'Weak', 'icon': Icons.wifi_lock},
    {'ssid': 'TP-Link_Guest', 'signal': 'Strong', 'icon': Icons.wifi_lock},
  ];

  // Attack State
  bool isAttacking = false;
  int attackSeconds = 0;
  Timer? attackTimer;
  String? attackResult;
  bool showResultCloseButton = false;

  // Speed Test State
  bool isTestingSpeed = false;
  double downloadSpeed = 0.0;
  double uploadSpeed = 0.0;
  int pingMs = 0;

  @override
  void initState() {
    super.initState();
    // App open hote hi Disclaimer dialog show karna
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimerDialog();
    });
  }

  // ---------------- DISCLAIMER DIALOG (10 SEC TIMER) ----------------
  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const DisclaimerDialog();
      },
    );
  }

  // ---------------- BRUTE FORCE SIMULATION ----------------
  void _startSecurityTest() {
    if (selectedWifi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pehle apna Wi-Fi select karein!')),
      );
      return;
    }

    setState(() {
      isAttacking = true;
      attackSeconds = 0;
      attackResult = null;
      showResultCloseButton = false;
    });

    // Simulated Timer (1 sec real = 1 min simulation)
    attackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        attackSeconds += 60; // Har second 1 minute add karega

        // Randomly stop test or reach limits
        // 1. Weak Security (< 10 min) -> simulated at 5 min
        // 2. Normal Security (10 min - 1 hr) -> simulated at 30 min
        // 3. Strong Security (> 2 hours) -> simulated at 130 min
      });
    });
  }

  void _stopAndEvaluateTest(int simulatedMinutes) {
    attackTimer?.cancel();
    String resultText = "";

    if (simulatedMinutes < 10) {
      resultText = "Weak Security";
    } else if (simulatedMinutes <= 60) {
      resultText = "Normal Security";
    } else {
      resultText = "Strong Security";
    }

    setState(() {
      isAttacking = false;
      attackResult = resultText;
    });

    // 5 second wait karne ke baad X sign show karna
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          showResultCloseButton = true;
        });
      }
    });
  }

  // ---------------- SPEED TEST SIMULATION ----------------
  void _runSpeedTest() async {
    setState(() {
      isTestingSpeed = true;
      downloadSpeed = 0.0;
      uploadSpeed = 0.0;
      pingMs = 0;
    });

    final random = Random();
    
    // Simulate Ping
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      pingMs = random.nextInt(30) + 12; // 12ms - 42ms
    });

    // Simulate Download
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        downloadSpeed = (random.nextDouble() * 40 + 10); // 10 - 50 Mbps
      });
    }

    // Simulate Upload
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        uploadSpeed = (random.nextDouble() * 20 + 5); // 5 - 25 Mbps
      });
    }

    setState(() {
      isTestingSpeed = false;
    });
  }

  @override
  void dispose() {
    attackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WiFi Security Test'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: _selectedNavIndex == 0 ? _buildSecurityTestTab() : _buildSpeedTestTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) => setState(() => _selectedNavIndex = index),
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Security Test',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speed),
            label: 'Speed Test',
          ),
        ],
      ),
    );
  }

  // ---------------- TAB 1: SECURITY TEST ----------------
  Widget _buildSecurityTestTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Available Wi-Fi Networks:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          // Wi-Fi Dialogue / List Box
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyan.withOpacity(0.3)),
            ),
            child: ListView.builder(
              itemCount: wifiList.length,
              itemBuilder: (context, index) {
                final wifi = wifiList[index];
                final isSelected = selectedWifi == wifi['ssid'];
                return ListTile(
                  leading: Icon(wifi['icon'], color: isSelected ? Colors.cyanAccent : Colors.white),
                  title: Text(wifi['ssid']),
                  subtitle: Text('Signal: ${wifi['signal']}'),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.cyanAccent) : null,
                  onTap: isAttacking ? null : () {
                    setState(() {
                      selectedWifi = wifi['ssid'];
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Start / Stop Attack Controls
          if (!isAttacking && attackResult == null)
            ElevatedButton(
              onPressed: _startSecurityTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('START SECURITY TEST', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            ),

          // Attack Running Screen
          if (isAttacking) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const CircularProgressIndicator(color: Colors.redAccent),
                  const SizedBox(height: 15),
                  const Text('Brute Force Attack in Progress...', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('Simulated Time Elapsed: ${attackSeconds ~/ 60} mins'),
                  const SizedBox(height: 15),
                  const Text('Simulation Control Buttons (Testing ke liye):', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _stopAndEvaluateTest(5), 
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('< 10 Mins'),
                      ),
                      ElevatedButton(
                        onPressed: () => _stopAndEvaluateTest(30), 
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        child: const Text('30 Mins'),
                      ),
                      ElevatedButton(
                        onPressed: () => _stopAndEvaluateTest(130), 
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('> 2 Hours'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],

          // Display Result
          if (attackResult != null) ...[
            const SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: attackResult == "Weak Security" ? Colors.red : (attackResult == "Normal Security" ? Colors.orange : Colors.green),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text('TEST RESULT', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 10),
                      Text(
                        attackResult!,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: attackResult == "Weak Security" ? Colors.red : (attackResult == "Normal Security" ? Colors.orange : Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),

                // 5 Sec baad X sign aane wala feature
                if (showResultCloseButton)
                  Positioned(
                    right: 5,
                    top: 5,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          attackResult = null;
                          showResultCloseButton = false;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- TAB 2: SPEED TEST ----------------
  Widget _buildSpeedTestTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSpeedMetric('DOWNLOAD', '${downloadSpeed.toStringAsFixed(1)} Mbps', Icons.arrow_downward),
              _buildSpeedMetric('UPLOAD', '${uploadSpeed.toStringAsFixed(1)} Mbps', Icons.arrow_upward),
            ],
          ),
          const SizedBox(height: 30),
          _buildSpeedMetric('PING / LATENCY', '$pingMs ms', Icons.network_check),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: isTestingSpeed ? null : _runSpeedTest,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: isTestingSpeed
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text('RUN SPEED TEST', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedMetric(String title, String value, IconData icon) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.cyanAccent),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ---------------- DISCLAIMER DIALOG COMPONENT ----------------
class DisclaimerDialog extends StatefulWidget {
  const DisclaimerDialog({super.key});

  @override
  State<DisclaimerDialog> createState() => _DisclaimerDialogState();
}

class _DisclaimerDialogState extends State<DisclaimerDialog> {
  int _secondsRemaining = 10;
  Timer? _timer;
  bool _showCloseIcon = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _secondsRemaining = 0;
          _showCloseIcon = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('DISCLAIMER', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                _showCloseIcon
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    : Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
                        child: Text('$_secondsRemaining', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
              ],
            ),
            const SizedBox(height: 15),
            const Text(
              'Yeh app sirf apne own router par use karein. Yeh sirf aapke apne Wi-Fi ki security testing ke liye hai.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
