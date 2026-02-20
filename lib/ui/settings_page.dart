import 'package:flutter/material.dart';

class SettingsData {
  bool autoCopy;
  bool excludeSimilar;
  bool hapticsEnabled;
  bool isDarkMode;
  double animationSpeed; // 0.5 (slow) to 2.0 (fast)

  SettingsData({
    required this.autoCopy,
    required this.excludeSimilar,
    required this.hapticsEnabled,
    required this.isDarkMode,
    required this.animationSpeed,
  });
}

class SettingsPage extends StatefulWidget {
  final SettingsData initialSettings;

  const SettingsPage({super.key, required this.initialSettings});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsData _settings;

  @override
  void initState() {
    super.initState();
    // Copy initial settings to local state
    _settings = SettingsData(
      autoCopy: widget.initialSettings.autoCopy,
      excludeSimilar: widget.initialSettings.excludeSimilar,
      hapticsEnabled: widget.initialSettings.hapticsEnabled,
      isDarkMode: widget.initialSettings.isDarkMode,
      animationSpeed: widget.initialSettings.animationSpeed,
    );
  }

  void _saveAndExit() {
    Navigator.pop(context, _settings);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _settings.isDarkMode;
    final theme = isDark ? ThemeData.dark() : ThemeData.light();
    final bgColor = isDark ? const Color(0xFF111827) : const Color(0xFFF3F4F6);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final accentColor = Colors.orange;

    return Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor: bgColor,
        appBarTheme: AppBarTheme(backgroundColor: bgColor, elevation: 0, iconTheme: IconThemeData(color: textColor)),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('SleepyPasswords Settings', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _saveAndExit,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _settings = SettingsData(
                    autoCopy: false,
                    excludeSimilar: false,
                    hapticsEnabled: true,
                    isDarkMode: widget.initialSettings.isDarkMode, // Keep current theme
                    animationSpeed: 1.0,
                  );
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset'), duration: Duration(milliseconds: 500)),
                );
              },
              child: Text('Reset', style: TextStyle(color: textColor.withOpacity(0.8))),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader('GENERATION', textColor),
            _buildSwitchTile(
              title: 'Auto-Copy Password',
              subtitle: 'Copy immediately after generating',
              value: _settings.autoCopy,
              onChanged: (v) => setState(() => _settings.autoCopy = v),
              cardColor: cardColor,
              textColor: textColor,
              accentColor: accentColor,
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Exclude Similar Characters',
              subtitle: 'Avoid l, 1, I, O, 0',
              value: _settings.excludeSimilar,
              onChanged: (v) => setState(() => _settings.excludeSimilar = v),
              cardColor: cardColor,
              textColor: textColor,
              accentColor: accentColor,
            ),

            const SizedBox(height: 30),
            _buildSectionHeader('APPEARANCE & FEEL', textColor),
            
            _buildSwitchTile(
              title: 'Dark Mode',
              subtitle: 'Easier on the eyes at night',
              value: _settings.isDarkMode,
              onChanged: (v) => setState(() => _settings.isDarkMode = v),
              cardColor: cardColor,
              textColor: textColor,
              accentColor: accentColor,
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Haptic Feedback',
              subtitle: 'Vibrate on interactions',
              value: _settings.hapticsEnabled,
              onChanged: (v) => setState(() => _settings.hapticsEnabled = v),
              cardColor: cardColor,
              textColor: textColor,
              accentColor: accentColor,
            ),
            const SizedBox(height: 12),
            
            // Animation Speed Slider
            Container(
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
                  Text('Animation Speed', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Slider(
                    value: _settings.animationSpeed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 3,
                    label: _settings.animationSpeed == 0.5 ? 'Slow' : (_settings.animationSpeed == 1.0 ? 'Normal' : 'Fast'),
                    activeColor: accentColor,
                    inactiveColor: isDark ? Colors.grey[800] : Colors.grey[300],
                    onChanged: (v) => setState(() => _settings.animationSpeed = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Slow', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('Normal', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('Fast', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            _buildSectionHeader('DATA', textColor),
            
            GestureDetector(
              onTap: () {
                Navigator.pop(context, 'CLEAR_HISTORY'); 
                // Special signal to clear history, handled in HomePage
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.delete_outline_rounded, color: Colors.red),
                    SizedBox(width: 16),
                    Text(
                      'Clear Password History',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                'SleepyPasswords v1.2\nMade by Lux',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: color.withOpacity(0.6),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color cardColor,
    required Color textColor,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: SwitchListTile.adaptive(
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13)),
        value: value,
        onChanged: onChanged,
        activeColor: accentColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
