import SwiftUI

@MainActor
class ShareQuestionViewModel: ObservableObject {
    @Published var isShareSheetPresented = false
    @Published var shareableCard: ShareableQuestionCard?
    
    private let seoService: SEOService
    private let shareService: ShareService
    
    init(seoService: SEOService, shareService: ShareService) {
        self.seoService = seoService
        self.shareService = shareService
    }
    
    func prepareShare(for question: Question) {
        shareableCard = seoService.createShareableCard(for: question)
        isShareSheetPresented = true
    }
    
    func getShareItems(for question: Question) -> [Any] {
        var items: [Any] = [shareService.generateShareText(for: question)]
        
        if let image = shareService.generateShareImage(for: question) {
            items.append(image)
        }
        
        return items
    }
}