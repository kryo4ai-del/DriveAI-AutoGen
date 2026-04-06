// TrackingBackend.swift
import Foundation

/// Protocol defining the interface for tracking backends.
public protocol TrackingBackend: AnyObject {
    func track(_ event: TrackingEvent)
    func flush() async throws
}