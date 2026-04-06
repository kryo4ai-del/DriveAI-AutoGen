struct QuestionAnswerLayoutView: View {
    @Environment(\.variantResolver) var variantResolver
    
    var body: some View {
        let variant = variantResolver.resolveVariant("answer_layout_v1")
        
        if variant == "horizontal" {
            HorizontalAnswerLayout()
        } else {
            VerticalAnswerLayout()
        }
    }
}

struct TimerDisplayView: View {
    @Environment(\.variantResolver) var variantResolver
    
    var body: some View {
        let variant = variantResolver.resolveVariant("timer_design_v1")
        
        if variant == "countdown" {
            CountdownTimerView()
        } else if variant == "progress" {
            ProgressTimerView()
        }
    }
}