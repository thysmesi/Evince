//
//  EVNode.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/29/21.
//

import Metal
import simd
import UIKit

@available(iOS 13.0, *)
open class EVNode {
    public let id: UUID
    
    public var position = SIMD2<Float>(0,0)
    public var scale = SIMD2<Float>(1,1)
    public var rotation: Float = 0
    
    public var children: [EVNode] = []
            
    var modelConstants = EVModelConstants()
    
    open var modelMatrix: matrix_float4x4 {
        let radians = -rotation * (Float.pi/180)
        
        let translation = matrix_float4x4(rows: [
            [1, 0, 0, position.x],
            [0, 1, 0, -position.y],
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
        return ((translation * rotation) * scale)
    }
        
    public init(id: UUID = UUID()){
        self.id = id
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder, parentModelMatrix: matrix_float4x4) {
          let modelViewMatrix = parentModelMatrix * modelMatrix
          for child in children {
              child.render(renderCommandEncoder: renderCommandEncoder, parentModelMatrix: modelViewMatrix)
          }
          
          if let renderable = self as? EVRenderable {
              renderable.doRender(renderCommandEncoder: renderCommandEncoder, modelViewMatrix: modelViewMatrix)
          }
    }
    
    public func add(child: EVNode) {
        children.append(child)
    }
}
