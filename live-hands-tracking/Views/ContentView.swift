//
//  ContentView.swift
//  live-hands-tracking
//
//  Created by Yuriy Nefedov on 27.07.2024.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @EnvironmentObject private var webSocketManager: WebSocketManager
    
    @State private var urlInput = "wss://droid-osmosis.onrender.com"

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow

    @ViewBuilder
    var body: some View {
        VStack(spacing: 24) {
            TextField("Socket URI", text: $urlInput)
                .textFieldStyle(.roundedBorder)
                .frame(height: 72)
            
            Button("Start") {
                if let validUrl {
                    webSocketManager.connect(url: validUrl)
                    Task {
                        await openImmersiveSpace(id: "ImmersiveSpace")
                        dismissWindow()
                    }
                }
            }
            .disabled(validUrl == nil)
        }
        .font(.title3)
        .padding()
        .padding(.horizontal)
    }
    
    
    var validUrl: URL? {
        URL(string: urlInput)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
