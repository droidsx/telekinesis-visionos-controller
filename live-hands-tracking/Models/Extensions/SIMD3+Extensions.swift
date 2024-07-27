//
//  SIMD3+Extensions.swift
//  live-hands-tracking
//
//  Created by Yuriy Nefedov on 27.07.2024.
//

import simd

extension SIMD3 where Scalar == Float {
    func distance(to vector: SIMD3<Float>) -> Float {
        let delta = self - vector
        return length(delta)
    }
}

