//
//  EVScene.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/29/21.
//

import Metal
import simd
import UIKit

@available(iOS 13.0, *)
open class EVScene {
    public var position = SIMD2<Float>(0,0)
    public var scale = SIMD2<Float>(1,1)
    public var rotation: Float = 0

    public var nodes: [EVNode] = []
    
    public init(){}
    
    var sceneConstants = EVModelConstants()
    
    var modelMatrix: matrix_float4x4 {
        let radians = -rotation * (Float.pi/180)
        let screen = UIScreen.main.bounds.size
        
        let translation = matrix_float4x4(rows: [
            [1, 0, 0, position.x - Float(screen.width/2)],
            [0, 1, 0, -position.y + Float(screen.height/2)],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        ])
        let rotation = matrix_float4x4(rows: [
            [cos(radians), -sin(radians), 0, 0],
            [sin(radians), cos(radians), 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        ])
        let scale = matrix_float4x4(rows: [
            [scale.x, 0, 0, 0],
            [0, scale.y, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        ])
        let standardize = matrix_float4x4(rows: [
            [1 / Float(screen.width/2), 0, 0, 0],
            [0, 1 / Float(screen.height/2), 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        ])
        
        return standardize * ((translation * rotation) * scale)
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        update(deltaTime: deltaTime)
        sceneConstants.modelMatrix = modelMatrix
        
        renderCommandEncoder.setVertexBytes(&sceneConstants, length: EVModelConstants.stride, index: 1)

        for node in nodes {
            node.render(renderCommandEncoder: renderCommandEncoder)
        }
    }
    
    public func add(node: EVNode) {
        nodes.append(node)
    }
    
    open func update(deltaTime: Float) {}
}
