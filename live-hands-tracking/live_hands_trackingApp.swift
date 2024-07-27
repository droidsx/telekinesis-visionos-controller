//
//  live_hands_trackingApp.swift
//  live-hands-tracking
//
//  Created by Yuriy Nefedov on 27.07.2024.
//

import SwiftUI

@main
struct live_hands_trackingApp: App {
    @StateObject private var webSocketManager = WebSocketManager()
    
    init() {
        UserDefaults.standard.issueClientIdIfNecessary()
    }
    
    var body: some Scene {
        WindowGroup(id: "RootWindow") {
            ContentView()
                .environmentObject(webSocketManager)
        }
        .defaultSize(CGSize(width: 400, height: 150))

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environmentObject(webSocketManager)
        }
        .upperLimbVisibility(.hidden)
    }
}
