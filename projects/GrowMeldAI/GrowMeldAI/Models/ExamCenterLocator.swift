// Deliverable: Services/Location/ExamCenterLocator.swift
struct ExamCenterLocator {
    let localDatabase: [ExamCenter] // bundled JSON/SQLite
    
    func nearbyExamCenters(
        from location: CLLocationCoordinate2D,
        within radiusKm: Double = 25
    ) -> [ExamCenter]
    
    func sortByDistance(_ centers: [ExamCenter], from location: CLLocationCoordinate2D) -> [ExamCenter]
}
