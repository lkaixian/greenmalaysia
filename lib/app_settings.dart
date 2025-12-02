import 'package:flutter/material.dart';
import 'package:greenmalaysia/services/settings_service.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart'; // Import L10n

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the settings singleton
    final settings = SettingsService();

    // Use ListenableBuilder to rebuild JUST this page when settings change
    return ListenableBuilder(
      listenable: settings,
      builder: (context, child) {
        // Initialize Localization helper
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsTitle)), // Localized
          body: ListView(
            children: [
              // 1. LANGUAGE OPTION
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  l10n.language, // Localized
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              RadioListTile<String>(
                title: Text(l10n.englishUK), // Localized
                value: 'en',
                groupValue: settings.locale.languageCode,
                onChanged: (val) =>
                    settings.updateLocale(const Locale('en', 'GB')),
              ),
              RadioListTile<String>(
                title: Text(l10n.bahasaMelayu), // Localized
                value: 'ms',
                groupValue: settings.locale.languageCode,
                onChanged: (val) =>
                    settings.updateLocale(const Locale('ms', '')),
              ),

              const Divider(), // ----------------------------------
              // 2. AI ANALYSIS OPTION
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.aiAnalysisMode, // Localized
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              SwitchListTile(
                title: Text(
                  settings.isAiLiveMode
                      ? l10n.liveMode
                      : l10n.nonLiveMode, // Localized
                ),
                subtitle: Text(
                  settings.isAiLiveMode
                      ? l10n.liveModeSubtitle
                      : l10n.nonLiveModeSubtitle, // Localized
                ),
                value: settings.isAiLiveMode,
                onChanged: (val) => settings.updateAiMode(val),
              ),

              const Divider(), // ----------------------------------
              // 3. THEME OPTION
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.theme, // Localized
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),

              // Dropdown for Theme
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
                          Text(l10n.systemDefault), // Localized
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Row(
                        children: [
                          const Icon(Icons.light_mode),
                          const SizedBox(width: 10),
                          Text(l10n.lightMode), // Localized
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Row(
                        children: [
                          const Icon(Icons.dark_mode),
                          const SizedBox(width: 10),
                          Text(l10n.darkMode), // Localized
                        ],
                      ),
                    ),
                  ],
                  onChanged: (newMode) {
                    if (newMode != null) settings.updateThemeMode(newMode);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
