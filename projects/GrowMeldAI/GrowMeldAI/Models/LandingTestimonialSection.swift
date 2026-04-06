struct LandingTestimonialSection: View {
    @State private var currentTestimonialIndex: Int = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("landing.testimonials.title".localized)
                .font(LandingTypography.sectionTitle)
            
            VStack(spacing: 12) {
                // Testimonial carousel
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(testimonials.enumerated()), id: \.offset) { index, testimonial in
                            TestimonialCard(testimonial: testimonial)
                                .frame(width: 280)
                                .onAppear {
                                    currentTestimonialIndex = index
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                // Pagination dots
                HStack(spacing: 6) {
                    ForEach(0..<testimonials.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentTestimonialIndex ? Color.primary : Color.secondary)
                            .frame(width: 8, height: 8)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .accessibilityLabel("Testimonial \(currentTestimonialIndex + 1) of \(testimonials.count)")
            }
        }
    }
}