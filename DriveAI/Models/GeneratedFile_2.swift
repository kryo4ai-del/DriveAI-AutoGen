private func loadUserSettings() {
       let settings = userSettingsService.loadSettings()
       notificationsEnabled = settings.notificationsEnabled
       language = settings.language.isEmpty ? SettingsConstants.defaultLanguage : settings.language
       darkModeEnabled = settings.darkModeEnabled
   }