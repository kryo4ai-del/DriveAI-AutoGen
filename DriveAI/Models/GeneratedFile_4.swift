if isLoading {
         VStack {
             ProgressView("Lade Fortschritt...")
                 .progressViewStyle(CircularProgressViewStyle())
             Text("Bitte warten…")
                 .font(.subheadline)
         }
     }