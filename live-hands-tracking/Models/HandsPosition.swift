//
//  HandsPosition.swift
//  live-hands-tracking
//
//  Created by Yuriy Nefedov on 27.07.2024.
//

import Foundation
import ARKit
import RealityKit

struct HandsPosition {
    var jointPositions: [HandJoint : SIMD3<Float>?]
    
    func pinchGestureDistance(for chirality: HandAnchor.Chirality) -> Float? {
        if let indexFingerTip = jointPositions[.init(chirality: chirality, joint: .indexFingerTip)],
           let indexFingerTip,
           let thumbTip = jointPositions[.init(chirality: chirality, joint: .thumbTip)],
           let thumbTip
        {
            return indexFingerTip.distance(to: thumbTip)
        }
        return nil
    }
    
    func pinchGestureActive(for chirality: HandAnchor.Chirality) -> Bool {
        let maxFingerTipDistance: Float = 0.01
        guard let distance = pinchGestureDistance(for: chirality) else { return false }
        return distance < maxFingerTipDistance
    }
    
    init(jointPositions: [HandJoint : SIMD3<Float>?] = [:]) {
        self.jointPositions = jointPositions
    }
    
    var jsonPayload: JsonPayload {
        .init(
            leftHand: handPayload(.left),
            rightHand: handPayload(.right)
        )
    }
    
    func handPayload(_ chirality: HandAnchor.Chirality) -> JsonPayload.HandPayload {
        var jointPositionsParameter = [String : [String : Float]]()
        for (key, value) in jointPositions.filter({ $0.key.chirality == chirality }) {
            if let value {
                jointPositionsParameter[key.joint.description] = ["x" : value.x, "y" : value.y, "z" : value.z]
            }
        }
        return .init(
            isPinchGesture: self.pinchGestureActive(for: chirality),
            jointPositions: jointPositionsParameter
        )
    }
    
    struct JsonPayload {
        let clientId: String
        let timestamp: Date
        let leftHand: HandPayload
        let rightHand: HandPayload
        
        struct HandPayload {
            let isPinchGesture: Bool
            let jointPositions: [String : [String : Float]]
            
            var jsonData: [String : Any] {
                [
                    "isPinchGesture" : isPinchGesture,
                    "jointPositions" : jointPositions
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
