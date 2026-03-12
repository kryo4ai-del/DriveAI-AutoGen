enum SettingsUpdateType {
       case notificationsChanged
       case languageChanged
       case darkModeChanged
   }
   
   var settingsChanged = PassthroughSubject<SettingsUpdateType, Never>()
   
   func toggleNotifications() {
       notificationsEnabled.toggle()
       updateSettings()
       settingsChanged.send(.notificationsChanged)
   }