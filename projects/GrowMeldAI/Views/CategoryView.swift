struct CategoryView: View {
    @Binding var navigationPath: NavigationPath  // ← Circular reference potential
    
    // If CategoryView keeps strong reference to navigationPath binding
    // and AppNavigation creates CategoryView with self binding,
    // you get retain cycle
}