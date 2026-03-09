var notifyChanged = false
     let settingRow = SettingRow(option: SettingOption(title: "Notifications", isOn: true, description: "Receive notifications.")) {
         notifyChanged = true
     }