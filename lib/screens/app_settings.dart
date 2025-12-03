import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for number input
import 'package:greenmalaysia/services/settings_service.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  // Local state for safety lock
  bool _isLocked = true;
  final TextEditingController _radiusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load current radius into controller
    final settings = SettingsService();
    _radiusController.text = settings.navRadius.toString();
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsService();

    return ListenableBuilder(
      listenable: settings,
      builder: (context, child) {
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsTitle)),
          body: ListView(
            children: [
              // 1. LANGUAGE OPTION
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

              // 2. AI ANALYSIS OPTION
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

              const Divider(),

              // 3. THEME OPTION
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

              // 4. ADVANCED SECTION (NEW)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.advanced, // Localized "Advanced"
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red, // Red to indicate caution
                  ),
                ),
              ),

              // A. Safety Toggle
              CheckboxListTile(
                secondary: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
                title: Text(l10n.unlockAdvanced), // "Unlock Advanced Features"
                subtitle: const Text("Untick to edit sensitive settings"),
                value: _isLocked, // Ticked = Locked
                activeColor: Colors.red,
                onChanged: (bool? value) {
                  setState(() {
                    _isLocked = value ?? true;
                  });
                },
              ),

              // B. Radius Input
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  controller: _radiusController,
                  enabled: !_isLocked, // Disable if locked
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.radiusSet, // "Navigation Radius (m)"
                    helperText: l10n.radiusHelp, // "Distance threshold..."
                    suffixText: "m",
                    border: const OutlineInputBorder(),
                    filled: true,
                    // Grey out background if locked
                    fillColor: _isLocked ? Colors.grey[200] : null,
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
