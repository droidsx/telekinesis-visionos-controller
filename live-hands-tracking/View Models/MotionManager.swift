//
//  MotionManager.swift
//
//  Created by Yuriy Nefedov on 14.06.2024.
//

import SwiftUI
import ARKit
import RealityKit

class MotionManager: ObservableObject, Service {
    
    @Published var handsPosition: HandsPosition = .init()
    @Published var rootEntity = Entity()
    
    private let session = ARKitSession()
    let provider = HandTrackingProvider()
    
    private let desiredJoint: (chirality: HandAnchor.Chirality, joint: HandSkeleton.JointName) = (.right, .middleFingerKnuckle)
    
    private var jointEntityName: String {
        "\(desiredJoint.joint)\(desiredJoint.chirality)"
    }
    
    func startSession() async {
        self.log("Starting session")
        try? await session.run([provider])
    }
    
    func handleSessionUpdates() async {
        self.log("Handling session updates")
        for await update in provider.anchorUpdates {
            let handAnchor = update.anchor
            for jointName in HandSkeleton.JointName.allCases {
                if let jointPosition = handAnchor.handSkeleton?.joint(jointName) {
                    let handJoint = HandJoint(chirality: handAnchor.chirality, joint: jointName)
                    DispatchQueue.main.async {
                        self.handsPosition.jointPositions[handJoint] = self.jointTranslation(from: jointPosition.anchorFromJointTransform)
                        if let joint = handAnchor.handSkeleton?.joint(jointName),
                           let jointEntity = self.rootEntity.findEntity(named: handJoint.id) {
                            jointEntity.setTransformMatrix(handAnchor.originFromAnchorTransform * joint.anchorFromJointTransform,
                                                           relativeTo: nil)
                        }
                    }
                }
            }
        }
    }
    
    private func jointTranslation(from transform: float4x4) -> SIMD3<Float> {
        SIMD3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
}

