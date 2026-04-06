// Services/EventBus/EventBus.swift
import Foundation

// Actor EventBus declared in Models/EventBusProtocol.swift

protocol EventObserver: AnyObject {
    func handle(_ event: AppEvent) async
}