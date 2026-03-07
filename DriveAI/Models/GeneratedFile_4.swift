@Published var errorMessage: String? = nil

   func loadUserSettings() {
       do {
           let settings = try userSettingsService.loadSettings()
           notificationsEnabled = settings.notificationsEnabled
           language = settings.language
           darkModeEnabled = settings.darkModeEnabled
       } catch let error as SettingsError {
           errorMessage = error.localizedDescription // Present this error in the UI
       }
   }