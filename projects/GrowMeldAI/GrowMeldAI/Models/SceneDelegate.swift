class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    static var appNetworkMonitor: NetworkMonitor?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        SceneDelegate.appNetworkMonitor = NetworkMonitor()
    }
}