// lib/features/driver/presentation/pages/driver_settings_page.dart

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:parkirin/core/services/localization_service.dart';
import 'package:parkirin/core/services/theme_service.dart';
import 'package:parkirin/features/driver/widgets/driver_appbar.dart';
import 'package:parkirin/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language {
  final String name;
  final String code;
  final String flag;

  const Language({
    required this.name,
    required this.code,
    required this.flag,
  });
}

class DriverSettingsPage extends StatefulWidget {
  const DriverSettingsPage({super.key});

  @override
  State<DriverSettingsPage> createState() => _DriverSettingsPageState();
}

class _DriverSettingsPageState extends State<DriverSettingsPage> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _biometricLogin = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('pushNotifications') ?? true;
      _emailNotifications = prefs.getBool('emailNotifications') ?? true;
      _biometricLogin = prefs.getBool('biometricLogin') ?? false;
    });
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('pushNotifications', _pushNotifications);
    await prefs.setBool('emailNotifications', _emailNotifications);
    await prefs.setBool('biometricLogin', _biometricLogin);
  }

  Widget _buildLanguageDropdown(
      ThemeData theme, LocalizationService localizationService) {
    final currentLanguage = localizationService.getCurrentLanguage();

    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: PopupMenuPosition.under,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLanguage.flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              currentLanguage.name,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurface,
            ),
          ],
        ),
      ),
      itemBuilder: (context) {
        return LocalizationService.supportedLanguages.map((language) {
          final isSelected = language.code == currentLanguage.code;
          return PopupMenuItem<String>(
            value: language.code,
            child: Row(
              children: [
                Text(
                  language.flag,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  language.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? theme.colorScheme.primary : null,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ],
            ),
          );
        }).toList();
      },
      onSelected: (String languageCode) {
        localizationService.changeLocale(languageCode);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final localizationService = Provider.of<LocalizationService>(context);
    final themeService = Provider.of<ThemeService>(context);

    return Scaffold(
      appBar: DriverAppBar(
        title: loc.settings,
        showLogout: true,
        showNotification: true,
      ),
      // Use SingleChildScrollView inside a Column to prevent scrolling unless necessary
      body: Column(
        children: [
          const SizedBox(height: 8), // Add small spacing after AppBar
          Expanded(
            child: SingleChildScrollView(
              physics:
                  const NeverScrollableScrollPhysics(), // Disable scrolling
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: loc.language,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(loc.language),
                        trailing:
                            _buildLanguageDropdown(theme, localizationService),
                      ),
                    ],
                  ),
                  _buildSection(
                    title: loc.theme,
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.dark_mode),
                        title: Text(loc.darkMode),
                        value: themeService.isDarkMode,
                        onChanged: (bool value) {
                          themeService.setDarkMode(value);
                        },
                      ),
                    ],
                  ),
                  _buildSection(
                    title: loc.notifications,
                    children: [
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications_none),
                        title: Text(loc.pushNotifications),
                        value: _pushNotifications,
                        onChanged: (bool value) {
                          setState(() {
                            _pushNotifications = value;
                          });
                          _saveSettings();
                        },
                      ),
                    ],
                  ),
                  _buildSection(
                    title: loc.about,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text(loc.version),
                        trailing: Text(_appVersion),
                      ),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: Text(loc.privacyPolicy),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          //  Navigate to privacy policy page
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text(loc.termsOfService),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Navigate to terms of service page
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
                16, 16, 16, 8), // Reduced top padding from 24 to 16
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
        ...children,
      ],
    );
  }
}
