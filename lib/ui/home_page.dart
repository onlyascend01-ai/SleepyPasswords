import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sleepy_passwords/core/password_generator.dart';
import 'package:sleepy_passwords/ui/settings_page.dart'; // Import Settings Page
import 'dart:ui'; // For ImageFilter

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String _password = '';
  bool _isLoading = false;
  bool _isCopied = false;
  final _lengthController = TextEditingController(text: '16');
  bool _useDigits = true;
  bool _useSymbols = true;
  
  // Theme State
  bool _isDarkMode = true;
  
  // Settings State
  bool _autoCopy = false;
  bool _excludeSimilar = false;
  bool _hapticsEnabled = true;
  double _animationSpeed = 1.0;

  // History State
  List<String> _passwordHistory = [];
  bool _showHistory = false;
  
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 4), // Slower, smoother rotation
      vsync: this,
    );
    
    // Smooth continuous rotation
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );
    
    // Bouncy scale for the button press
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.1, curve: Curves.easeOut),
      ),
    );
    
    // Pulsing glow
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  // --- Logic ---

  Future<void> _generate() async {
    // Haptic feedback
    if (_hapticsEnabled) {
      try { HapticFeedback.selectionClick(); } catch (_) {}
    }
    
    setState(() {
      _isLoading = true;
      _password = '';
      _isCopied = false;
    });

    // Start animation (adjust speed dynamically)
    _animationController.duration = Duration(milliseconds: (4000 / _animationSpeed).round());
    _animationController.repeat();

    // UX Delay (adjusted for speed)
    await Future.delayed(Duration(milliseconds: (600 / _animationSpeed).round()));

    final length = int.tryParse(_lengthController.text) ?? 16;
    final generator = PasswordGenerator();
    final password = generator.generate(
      length: length,
      useDigits: _useDigits,
      useSymbols: _useSymbols,
      excludeSimilar: _excludeSimilar, // Use new setting
    );

    setState(() {
      _password = password;
      _isLoading = false;
      // Add to history
      if (!_passwordHistory.contains(password)) {
        _passwordHistory.insert(0, password);
        if (_passwordHistory.length > 10) _passwordHistory.removeLast();
      }
    });

    // Stop animation smoothly
    _animationController.stop();
    _animationController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    
    if (_hapticsEnabled) {
      try { HapticFeedback.heavyImpact(); } catch (_) {}
    }

    // Auto-Copy Feature
    if (_autoCopy) {
      await _copyToClipboard(silent: true); 
      // Show snackbar even if silent is requested for feedback? 
      // Actually let's just show it so user knows.
    }
  }

  Future<void> _copyToClipboard({bool silent = false}) async {
    if (_password.isEmpty) return;
    
    await Clipboard.setData(ClipboardData(text: _password));
    if (_hapticsEnabled) {
      try { HapticFeedback.mediumImpact(); } catch (_) {}
    }
    
    setState(() => _isCopied = true);
    
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Copied to clipboard'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isCopied = false);
  }

  // Settings Navigation
  Future<void> _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          initialSettings: SettingsData(
            autoCopy: _autoCopy,
            excludeSimilar: _excludeSimilar,
            hapticsEnabled: _hapticsEnabled,
            isDarkMode: _isDarkMode,
            animationSpeed: _animationSpeed,
          ),
        ),
      ),
    );

    if (result != null) {
      if (result == 'CLEAR_HISTORY') {
        setState(() => _passwordHistory.clear());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History cleared'), duration: Duration(seconds: 1)),
        );
      } else if (result is SettingsData) {
        setState(() {
          _autoCopy = result.autoCopy;
          _excludeSimilar = result.excludeSimilar;
          _hapticsEnabled = result.hapticsEnabled;
          _isDarkMode = result.isDarkMode;
          _animationSpeed = result.animationSpeed;
        });
      }
    }
  }

  String _getPasswordStrength() {
    if (_password.isEmpty) return '';
    int strength = 0;
    if (_password.length >= 12) strength++;
    if (_password.length >= 16) strength++;
    if (_useDigits) strength++;
    if (_useSymbols) strength++;
    
    if (strength >= 4) return 'Excellent';
    if (strength >= 3) return 'Strong';
    if (strength >= 2) return 'Good';
    return 'Weak';
  }

  Color _getStrengthColor() {
    final strength = _getPasswordStrength();
    switch (strength) {
      case 'Excellent': return Colors.greenAccent;
      case 'Strong': return Colors.green;
      case 'Good': return Colors.orange;
      default: return Colors.red;
    }
  }

  double _getStrengthPercent() {
    if (_password.isEmpty) return 0;
    int strength = 0;
    if (_password.length >= 12) strength++;
    if (_password.length >= 16) strength++;
    if (_useDigits) strength++;
    if (_useSymbols) strength++;
    return strength / 4;
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    // Dynamic Theme Colors
    final bgColor = _isDarkMode ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final cardColor = _isDarkMode ? const Color(0xFF1F2937) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF111827);
    final subTextColor = _isDarkMode ? Colors.white70 : Colors.black54;
    final accentColor = Colors.orange;

    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text('SleepyPasswords', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          actions: [
            // History Toggle
            IconButton(
              icon: Icon(Icons.history_rounded, color: _showHistory ? accentColor : textColor),
              onPressed: () => setState(() => _showHistory = !_showHistory),
              tooltip: 'History',
            ),
            // Settings Button
            IconButton(
              icon: Icon(Icons.settings_rounded, color: textColor),
              onPressed: _openSettings,
              tooltip: 'Settings',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // --- THE POP LOCK BUTTON ---
                GestureDetector(
                  onTap: _isLoading ? null : _generate,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return SizedBox(
                        width: 300,
                        height: 300,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 1. Glow
                            Container(
                              width: 280,
                              height: 280,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withOpacity(_isLoading ? _glowAnimation.value : 0.1),
                                    blurRadius: 50,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            
                            // 2. Rotating Ring (Outer)
                            RotationTransition(
                              turns: _rotationAnimation,
                              child: Container(
                                width: 290,
                                height: 290,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: accentColor.withOpacity(0.3),
                                    width: 1,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Container(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                                  ),
                                ),
                              ),
                            ),

                            // 3. Counter-Rotating Ring (Inner)
                            RotationTransition(
                              turns: ReverseAnimation(_rotationAnimation),
                              child: Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: accentColor.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: 10, height: 10,
                                    decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                                  ),
                                ),
                              ),
                            ),

                            // 4. Main Circle (Button)
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isDarkMode ? const Color(0xFF2D3748) : const Color(0xFFFFFFFF),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isLoading 
                                  ? CircularProgressIndicator(color: accentColor, strokeWidth: 3)
                                  : Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.lock_outline_rounded, 
                                            size: 32, 
                                            color: accentColor
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            _password.isEmpty ? "TAP TO\nUNLOCK" : _password,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: _password.isEmpty ? 14 : 18,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 40),

                // --- STRENGTH BAR ---
                if (_password.isNotEmpty)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                         BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Security Level", style: TextStyle(color: subTextColor)),
                            Text(_getPasswordStrength(), style: TextStyle(color: _getStrengthColor(), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _getStrengthPercent(),
                            backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(_getStrengthColor()),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _copyToClipboard,
                            icon: Icon(_isCopied ? Icons.check : Icons.copy),
                            label: Text(_isCopied ? "COPIED" : "COPY PASSWORD"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isCopied ? Colors.green : accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // --- HISTORY PANEL ---
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: _showHistory && _passwordHistory.isNotEmpty
                      ? Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: accentColor.withOpacity(0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("History", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 10),
                              ..._passwordHistory.take(5).map((pass) => 
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Text("• ", style: TextStyle(color: accentColor)),
                                      Expanded(child: Text(pass, style: TextStyle(color: subTextColor, fontFamily: 'monospace'))),
                                      IconButton(
                                        icon: const Icon(Icons.copy_rounded, size: 16),
                                        color: subTextColor,
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: pass));
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Copied $pass"), duration: const Duration(seconds: 1)));
                                        },
                                      )
                                    ],
                                  ),
                                )
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // --- SETTINGS PANEL ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                     boxShadow: [
                         BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                  ),
                  child: Column(
                    children: [
                      // Length Input
                      TextField(
                        controller: _lengthController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor, fontSize: 18),
                        decoration: InputDecoration(
                          labelText: 'Length',
                          labelStyle: TextStyle(color: subTextColor),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _isDarkMode ? Colors.grey[800]! : Colors.grey[300]!)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor)),
                          filled: true,
                          fillColor: _isDarkMode ? Colors.black26 : Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Toggles
                      _buildSwitch('Digits (0-9)', _useDigits, (v) => setState(() => _useDigits = v), textColor, accentColor),
                      Divider(color: _isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                      _buildSwitch('Symbols (!@#)', _useSymbols, (v) => setState(() => _useSymbols = v), textColor, accentColor),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, Function(bool) onChanged, Color textColor, Color accentColor) {
    return SwitchListTile.adaptive(
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeColor: accentColor,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
