//
//  HandJoint.swift
//  live-hands-tracking
//
//  Created by Yuriy Nefedov on 27.07.2024.
//

import Foundation
import ARKit

struct HandJoint: Identifiable, Hashable {
    let chirality: HandAnchor.Chirality
    let joint: HandSkeleton.JointName
    
    init(chirality: HandAnchor.Chirality, joint: HandSkeleton.JointName) {
        self.chirality = chirality
        self.joint = joint
    }
    
    var id: String {
        "\(chirality.description)-\(joint.description)"
    }
}
