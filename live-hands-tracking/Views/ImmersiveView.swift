//
//  ImmersiveView.swift
//  live-hands-tracking
//
//  Created by Yuriy Nefedov on 27.07.2024.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

struct ImmersiveView: View {
    @EnvironmentObject private var webSocketManager: WebSocketManager
    @StateObject private var motionManager = MotionManager()
    @State private var webSocketTimer: Timer? = nil
    
    private let webSocketPayloadInterval: TimeInterval = 1
    
    private static let controlPanelWorldPosition: SIMD3<Float> = [0, 1.5, -0.75]
    private static let controlPanelAnchor: AnchorEntity = .init(world: controlPanelWorldPosition)
    
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        RealityView { content, attachments in
            content.add(motionManager.rootEntity)
            for chirality in [HandAnchor.Chirality.left, .right] {
                for jointName in HandSkeleton.JointName.allCases {
                    let jointEntity = ModelEntity(mesh: .generateSphere(radius: 0.006),
                                                  materials: [SimpleMaterial()])
                    let handJoint = HandJoint(chirality: chirality, joint: jointName)
                    jointEntity.name = handJoint.id
                    motionManager.rootEntity.addChild(jointEntity)
                }
            }
            if let attachment = attachments.entity(for: "control-panel") {
                Self.controlPanelAnchor.addChild(attachment)
                content.add(Self.controlPanelAnchor)
            }
        } attachments: {
            Attachment(id: "control-panel") {
                let status = webSocketManager.inferredStatus
                VStack(spacing: 16) {
                    Button("Disconnect") {
                        webSocketManager.disconnect()
                        self.stopTransmission()
                        Task {
                            await dismissImmersiveSpace()
                            openWindow(id: "RootWindow")
                        }
                    }
                    HStack(spacing: 12) {
                        Text("Status:")
                        HStack(spacing: 6) {
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundStyle(status.associatedColor)
                            Text(status.userFacingName)
                        }
                    }
                }
            }
        }
        .task {
            await motionManager.startSession()
        }
        .task {
            await motionManager.handleSessionUpdates()
        }
        .onAppear {
            self.webSocketTimer = Timer.scheduledTimer(withTimeInterval: webSocketPayloadInterval, repeats: true) { _ in
                let jsonMessage = motionManager.handsPosition.jsonPayload.jsonData
                webSocketManager.sendMessage(data: jsonMessage)
            }
        }
        .onDisappear {
            self.stopTransmission()
        }
    }
    
    private func stopTransmission() {
        self.webSocketTimer?.invalidate()
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
