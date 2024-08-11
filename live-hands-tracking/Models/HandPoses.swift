//
//  HandsPosition.swift
//  live-hands-tracking
//
//  Created by Yuriy Nefedov on 27.07.2024.
//

import Foundation
import ARKit
import RealityKit

struct HandPoses {
    var joints: [HandJoint : HandPose?]
    
    func pinchGestureDistance(for chirality: HandAnchor.Chirality) -> Float? {
        if let indexFingerTip = joints[.init(chirality: chirality, joint: .indexFingerTip)],
           let indexFingerTip,
           let thumbTip = joints[.init(chirality: chirality, joint: .thumbTip)],
           let thumbTip
        {
            return indexFingerTip.position.distance(to: thumbTip.position)
        }
        return nil
    }
    
    func pinchGestureActive(for chirality: HandAnchor.Chirality) -> Bool {
        let maxFingerTipDistance: Float = 0.01
        guard let distance = pinchGestureDistance(for: chirality) else { return false }
        return distance < maxFingerTipDistance
    }
    
    init(joints: [HandJoint : HandPose?] = [:]) {
        self.joints = joints
    }
    
    var jsonPayload: JsonPayload {
        .init(
            leftHand: handPayload(.left),
            rightHand: handPayload(.right)
        )
    }
    
    func handPayload(_ chirality: HandAnchor.Chirality) -> JsonPayload.HandPayload {
        var jointPositionsParameter = [String : [String : [String : Float]]]()
        for (key, value) in joints.filter({ $0.key.chirality == chirality }) {
            if let value {
                jointPositionsParameter[key.joint.description] = .init()
                jointPositionsParameter[key.joint.description]!["position"] = [
                    "x" : value.position.x,
                    "y" : value.position.y,
                    "z" : value.position.z
                ]
                jointPositionsParameter[key.joint.description]!["orientation"] = [
                    "w" : value.orientation.real,
                    "x" : value.orientation.imag.x,
                    "y" : value.orientation.imag.y,
                    "z" : value.orientation.imag.z
                ]
            }
        }
        return .init(
            isPinchGesture: self.pinchGestureActive(for: chirality),
            jointPoses: jointPositionsParameter
        )
    }
    
    struct JsonPayload {
        let clientId: String
        let timestamp: Date
        let leftHand: HandPayload
        let rightHand: HandPayload
        
        struct HandPayload {
            let isPinchGesture: Bool
            let jointPoses: [String : [String : [String : Float]]]
            
            var jsonData: [String : Any] {
                [
                    "isPinchGesture" : isPinchGesture,
                    "jointPositions" : jointPoses
                ]
            }
        }
        
        init(
            clientId: String = UserDefaults.standard.clientId ?? "null",
            timestamp: Date = .now,
            leftHand: HandPayload,
            rightHand: HandPayload
        ) {
            self.clientId = clientId
            self.timestamp = timestamp
            self.leftHand = leftHand
            self.rightHand = rightHand
        }
        
        var jsonData: [String : Any] {
            [
                "clientId" : clientId,
                "timestamp" : Int(timestamp.timeIntervalSince1970),
                "leftHand" : leftHand.jsonData,
                "rightHand" : rightHand.jsonData
            ]
        }
    }
}

struct HandPose {
    let position: SIMD3<Float>
    let orientation: simd_quatf
}
