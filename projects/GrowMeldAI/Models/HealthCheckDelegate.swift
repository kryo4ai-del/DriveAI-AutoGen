protocol HealthCheckDelegate: AnyObject {
    func healthStatusDidChange(_ status: AIServiceStatus)
}
