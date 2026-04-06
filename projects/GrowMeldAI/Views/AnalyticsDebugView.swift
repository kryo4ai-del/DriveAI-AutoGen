import SwiftUI
// Views/Debug/AnalyticsDebugView.swift
// Available only in #DEBUG builds

struct AnalyticsDebugView: View {
    @State private var loggedEvents: [(String, [String: Any]?)] = []
    
    var body: some View {
        NavigationStack {
            List(loggedEvents.indices, id: \.self) { idx in
                VStack(alignment: .leading) {
                    Text(loggedEvents[idx].0).font(.headline)
                    Text(String(describing: loggedEvents[idx].1))
                        .font(.caption).foregroundColor(.gray)
                }
            }
        }
    }
}