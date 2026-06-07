import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenmalaysia/services/settings_service.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool _isLocked = true;
  final TextEditingController _radiusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = SettingsService();
    _radiusController.text = settings.navRadius.toString();
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, child) {
        final l10n = AppLocalizations.of(context)!;

        // Dynamic color for locked/disabled fields
        Color lockedFillColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsTitle)),
          body: ListView(
            children: [
              // --- 1. LANGUAGE SECTION ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  l10n.language,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              RadioListTile<String>(
                title: Text(l10n.englishUK),
                value: 'en',
                groupValue: settings.locale.languageCode,
                onChanged: (val) =>
                    settings.updateLocale(const Locale('en', 'GB')),
              ),
              RadioListTile<String>(
                title: Text(l10n.bahasaMelayu),
                value: 'ms',
                groupValue: settings.locale.languageCode,
                onChanged: (val) =>
                    settings.updateLocale(const Locale('ms', '')),
              ),
              const Divider(),

              // --- 2. AI CONFIGURATION SECTION ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.aiAnalysisMode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              // A. Live Mode Toggle
              SwitchListTile(
                title: Text(
                  settings.isAiLiveMode ? l10n.liveMode : l10n.nonLiveMode,
                ),
                subtitle: Text(
                  settings.isAiLiveMode
                      ? l10n.liveModeSubtitle
                      : l10n.nonLiveModeSubtitle,
                ),
                value: settings.isAiLiveMode,
                onChanged: (val) => settings.updateAiMode(val),
              ),

              // B. NEW: High Precision Toggle
              SwitchListTile(
                title: const Text("High Precision Model"), // Add to l10n later
                subtitle: const Text("Uses FP32. Slower but more accurate."),
                // We assume SettingsService now has this property (see step 2 below)
                value: settings.useHighPrecision,
                activeColor: Colors.orange,
                onChanged: (val) => settings.updateHighPrecision(val),
              ),
              const Divider(),

              // --- 3. THEME SECTION ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.theme,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButtonFormField<ThemeMode>(
                  value: settings.themeMode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Row(
                        children: [
                          const Icon(Icons.phone_android),
                          const SizedBox(width: 10),
                          Text(l10n.systemDefault),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Row(
                        children: [
                          const Icon(Icons.light_mode),
                          const SizedBox(width: 10),
                          Text(l10n.lightMode),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Row(
                        children: [
                          const Icon(Icons.dark_mode),
                          const SizedBox(width: 10),
                          Text(l10n.darkMode),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (newMode) {
                    if (newMode != null) settings.updateThemeMode(newMode);
                  },
                ),
              ),
              const Divider(),

              // --- 4. ADVANCED SECTION ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.advanced,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),

              CheckboxListTile(
                secondary: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
                title: Text(l10n.unlockAdvanced),
                subtitle: const Text("Untick to edit sensitive settings"),
                value: _isLocked,
                activeColor: Colors.red,
                onChanged: (bool? value) {
                  setState(() {
                    _isLocked = value ?? true;
                  });
                },
              ),

              // --- A. Show Performance HUD ---
              SwitchListTile(
                secondary: const Icon(Icons.speed, color: Colors.cyan),
                title: const Text("Show Performance HUD"),
                subtitle: const Text("Display model, CPU, FPS & timing overlay"),
                value: settings.showHud,
                activeColor: Colors.cyan,
                onChanged: _isLocked ? null : (val) => settings.updateShowHud(val),
              ),

              // --- B. Force Model ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  value: settings.forcedModel,
                  decoration: InputDecoration(
                    labelText: "AI Model",
                    helperText: "Auto selects based on your CPU",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.memory),
                    filled: _isLocked,
                    fillColor: _isLocked ? lockedFillColor : null,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'auto', child: Text("Auto (Smart Select)")),
                    DropdownMenuItem(value: 'mta-v2-yolov11n-low.tflite', child: Text("YOLOv11n Low (3.1MB)")),
                    DropdownMenuItem(value: 'mta-v2-yolov11n-high.tflite', child: Text("YOLOv11n High (11.1MB)")),
                    DropdownMenuItem(value: 'mta-v2-yolov11s-low.tflite', child: Text("YOLOv11s Low (10.1MB)")),
                    DropdownMenuItem(value: 'mta-v2-yolov11s-high.tflite', child: Text("YOLOv11s High (38.7MB)")),
                  ],
                  onChanged: _isLocked ? null : (val) {
                    if (val != null) settings.updateForcedModel(val);
                  },
                ),
              ),

              // --- C. Thread Count ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: DropdownButtonFormField<int>(
                  value: settings.aiThreadCount,
                  decoration: InputDecoration(
                    labelText: "AI Thread Count",
                    helperText: "0 = Auto (recommended)",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.developer_board),
                    filled: _isLocked,
                    fillColor: _isLocked ? lockedFillColor : null,
                  ),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text("Auto")),
                    DropdownMenuItem(value: 1, child: Text("1 Thread")),
                    DropdownMenuItem(value: 2, child: Text("2 Threads")),
                    DropdownMenuItem(value: 3, child: Text("3 Threads")),
                    DropdownMenuItem(value: 4, child: Text("4 Threads")),
                    DropdownMenuItem(value: 6, child: Text("6 Threads")),
                    DropdownMenuItem(value: 8, child: Text("8 Threads")),
                  ],
                  onChanged: _isLocked ? null : (val) {
                    if (val != null) settings.updateAiThreadCount(val);
                  },
                ),
              ),

              // --- D. Force GPU ---
              SwitchListTile(
                secondary: const Icon(Icons.graphic_eq, color: Colors.orange),
                title: const Text("Force GPU Delegate"),
                subtitle: const Text("May crash on unsupported devices"),
                value: settings.forceGpu,
                activeColor: Colors.orange,
                onChanged: _isLocked ? null : (val) => settings.updateForceGpu(val),
              ),

              // --- E. Navigation Radius ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  controller: _radiusController,
                  enabled: !_isLocked,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    color: _isLocked
                        ? (isDark ? Colors.white54 : Colors.black38)
                        : (isDark ? Colors.white : Colors.black),
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.radiusSet,
                    helperText: l10n.radiusHelp,
                    suffixText: "m",
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: _isLocked ? lockedFillColor : null,
                    prefixIcon: const Icon(Icons.radar),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      int? newVal = int.tryParse(value);
                      if (newVal != null) {
                        settings.updateNavRadius(newVal);
                      }
                    }
                  },
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }
}
