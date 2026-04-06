struct CategoryGroup: Identifiable {
    let id: String
    let name: String  // "Verkehrssicherheit", "Umweltschutz", "Recht"
    let description: String
    let categories: [Category]
    let mastery: Double  // Aggregate mastery across group
}

struct CategoryGroupView: View {
    let groups: [CategoryGroup]
    
    var body: some View {
        List {
            ForEach(groups) { group in
                NavigationLink(destination: CategoryDetailView(group: group)) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(group.name)
                                    .font(.driveAIHeadline)
                                Text(group.description)
                                    .font(.driveAICaption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            Spacer()
                            Text("\(Int(group.mastery * 100))%")
                                .font(.driveAIBody)
                                .foregroundColor(AppColors.progress(group.mastery))
                        }
                        
                        // Mini progress bar
                        ProgressView(value: group.mastery)
                            .tint(AppColors.progress(group.mastery))
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}