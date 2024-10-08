//
//  MotionManager.swift
//
//  Created by Yuriy Nefedov on 14.06.2024.
//

import SwiftUI
import ARKit
import RealityKit

class MotionManager: ObservableObject, Service {
    
    @Published var handPoses: HandPoses = .init()
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
                if let joint = handAnchor.handSkeleton?.joint(jointName) {
                    let handJoint = HandJoint(chirality: handAnchor.chirality, joint: jointName)
                    DispatchQueue.main.async {
                        if let jointEntity = self.rootEntity.findEntity(named: handJoint.id) {
                            jointEntity.setTransformMatrix(
                                handAnchor.originFromAnchorTransform * joint.anchorFromJointTransform,
                                relativeTo: nil
                            )
                            
                            let translation = self.jointTranslation(
                                jointTransform: joint.anchorFromJointTransform,
                                handTransform: handAnchor.originFromAnchorTransform
                            )
                            let orientation = self.jointOrientation(
                                jointTransform: joint.anchorFromJointTransform,
                                handTransform: handAnchor.originFromAnchorTransform
                            )
                            
                            self.handPoses.joints[handJoint] = .init(
                                position: translation,
                                orientation: orientation
                            )
                            
                        }
                    }
                }
            }
        }
    }
    
    private func jointTranslation(jointTransform: float4x4, handTransform: float4x4) -> SIMD3<Float> {
        let transform = handTransform * jointTransform
        return SIMD3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    private func jointOrientation(jointTransform: float4x4, handTransform: float4x4) -> simd_quatf {
        let transform = handTransform * jointTransform
        return simd_quaternion(transform)
    }
}

