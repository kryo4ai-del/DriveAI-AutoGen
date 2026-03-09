.alert(isPresented: $showErrorAlert) {
         Alert(
             title: Text("Fehler"),
             message: Text(errorMessage ?? "Unbekannter Fehler aufgetreten."),
             dismissButton: .default(Text("OK"))
         )
     }