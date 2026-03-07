// In QuickStartButton:
     Button(action: {
         action()
         // Optionally show some feedback
     }) {
         Text("Schnellstart")
             .font(.title2)
             .fontWeight(.bold)
             .padding()
             .frame(maxWidth: .infinity)
             .buttonStyle()
     }