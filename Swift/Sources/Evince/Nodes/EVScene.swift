//
//  EVScene.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/29/21.
//

import Metal

@available(iOS 13.0, *)
open class EVScene {
    public var nodes: [EVNode] = []
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        update(deltaTime: deltaTime)
        
        for node in nodes {
            node.render(renderCommandEncoder: renderCommandEncoder)
        }
    }
    
    public func add(node: EVNode) {
        nodes.append(node)
    }
    
    open func update(deltaTime: Float) {}
}
