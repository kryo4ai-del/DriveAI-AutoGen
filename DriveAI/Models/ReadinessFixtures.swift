enum ReadinessFixtures {
       static func mockReport(score: Int = 75) -> ExamReadinessReport {
           ExamReadinessReport(overallScore: score, categoryBreakdown: [])
       }
   }