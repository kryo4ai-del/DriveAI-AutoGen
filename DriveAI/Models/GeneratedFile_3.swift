// Use Combine to publish updates to a subscriber
   func toggleNotifications() {
       notificationsEnabled.toggle()
       updateSettings()
       
       // Publish the notification to any subscribers
       settingsChanged.send(notificationsEnabled)
   }

   let settingsChanged = PassthroughSubject<Bool, Never>()