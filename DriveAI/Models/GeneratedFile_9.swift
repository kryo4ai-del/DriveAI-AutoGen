@State private var isQuickStartActive = false

     // In Button action:
     Button(action: {
         isQuickStartActive = true
         action()
     }) {
         ...
     }