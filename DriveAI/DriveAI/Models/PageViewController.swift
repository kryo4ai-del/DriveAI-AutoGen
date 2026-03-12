// Views/PageViewController.swift
import SwiftUI

struct PageViewController: View {
    var pages: [OnboardingScreenModel]
    @Binding var currentPage: Int
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(pages.indices, id: \.self) { index in
                OnboardingPageView(screenModel: pages[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}

struct OnboardingPageView: View {
    var screenModel: OnboardingScreenModel
    
    var body: some View {
        VStack {
            Image(screenModel.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 300)
            
            Text(screenModel.formattedTitle)
                .font(.largeTitle)
                .padding()
            
            Text(screenModel.description)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}