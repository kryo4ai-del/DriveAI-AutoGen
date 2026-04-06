// Add notification/callback mechanism
protocol IAPServiceDelegate: AnyObject {
    func iapServiceDidVerifyTransaction(_ transaction: Transaction)
    func iapServiceDidFailTransaction(_ error: IAPError)
}
