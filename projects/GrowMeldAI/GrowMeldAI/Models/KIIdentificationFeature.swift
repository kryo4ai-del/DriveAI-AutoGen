// Features/KIIdentificationFeature.swift
import SwiftUI

public enum KIIdentificationFeature {
    public static func rootView() -> some View {
        NavigationStack {
            KIIdentificationView()
        }
    }
}