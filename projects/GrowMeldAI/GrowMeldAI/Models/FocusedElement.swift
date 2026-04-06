// ✅ FIXED – LandingScreen.swift
@FocusState private var focusedElement: FocusedElement?

enum FocusedElement: Hashable {
    case hero
    case feature(id: String)
    case testimonialScroll
    case faq(id: String)
    case ctaButton
}

var body: some View {
    VStack {
        LandingHeroSection()
            .focused($focusedElement, equals: .hero)
        
        LandingFeatureGrid()
            .focused($focusedElement, equals: .feature(id: "grid"))
        
        LandingTestimonialSection()
            .focused($focusedElement, equals: .testimonialScroll)
        
        LandingFAQSection()
            .focused($focusedElement, equals: .faq(id: "accordion"))
    }
    .onMoveCommand { direction in
        // Define logical navigation
        switch direction {
        case .down:
            focusedElement = .testimonialScroll
        case .up:
            focusedElement = .hero
        default:
            break
        }
    }
}