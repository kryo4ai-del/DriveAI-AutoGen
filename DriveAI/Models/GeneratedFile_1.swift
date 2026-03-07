private func updateSettings() {
       saveUserSettings()
   }
   
   func toggleNotifications() {
       notificationsEnabled.toggle()
       updateSettings()
   }

   func changeLanguage(to newLanguage: String) {
       language = newLanguage
       updateSettings()
   }

   func toggleDarkMode() {
       darkModeEnabled.toggle()
       updateSettings()
   }