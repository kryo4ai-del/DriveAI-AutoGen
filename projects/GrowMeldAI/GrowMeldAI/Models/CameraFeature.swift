// Camera.swift
struct CameraFeature {
    #if CAMERA_ENABLED
    static let isEnabled = true
    #else
    static let isEnabled = false
    #endif
}