//
//  EVVertex.swift
//  EvinceTesting
//
//  Created by Corbin Bigler on 11/9/21.
//

import Foundation
import Metal

public struct EVVertex {
    public static let descriptor = { () -> MTLVertexDescriptor in
        let vertexDescriptor = MTLVertexDescriptor()
        
        //Position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        
        //Color
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = SIMD3<Float>.size
        
        //Texture Coordinate
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].bufferIndex = 0
        vertexDescriptor.attributes[2].offset = SIMD3<Float>.size + SIMD4<Float>.size
        
        vertexDescriptor.layouts[0].stride = EVVertex.stride
        return vertexDescriptor
    }()
    
    public var position: SIMD3<Float>
    public var color: SIMD4<Float>
    public var textureCoordinate: SIMD2<Float>
    
    public init(position: SIMD3<Float>, color: SIMD4<Float>, textureCoordinate: SIMD2<Float>) {
        self.position = SIMD3<Float>(position.x, position.y, 0)
        self.color = color
        self.textureCoordinate = textureCoordinate
    }
}
