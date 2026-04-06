// CameraOnboardingCoordinator
import Foundation
import UIKit

final class DIContainer {
    private var factories: [ObjectIdentifier: () -> Any] = [:]
    func register<T>(_ type: T.Type, factory: @escaping () -> T) { factories[ObjectIdentifier(type)] = factory }
    func resolve<T>(_ type: T.Type) -> T { (factories[ObjectIdentifier(type)]!() as! T) }
}
