enum SettingsError: Error {
       case loadError
       case saveError
   }

   // You could create a method that throws errors for load/save