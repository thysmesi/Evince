//
//  EVModelConstants.swift
//  EvinceTesting
//
//  Created by Corbin Bigler on 11/9/21.
//

import Foundation
import simd

public struct EVModelConstants: Sizeable {
    public var modelMatrix: float4x4
    public init(modelMatrix: float4x4 = matrix_identity_float4x4) {
        self.modelMatrix = modelMatrix
    }
}
