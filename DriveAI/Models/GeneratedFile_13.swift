var notifyChanged = false
     let settingOption = SettingOption(title: "Notifications", isOn: true)
     let settingRow = SettingRow(option: settingOption) {
         notifyChanged = true
     }