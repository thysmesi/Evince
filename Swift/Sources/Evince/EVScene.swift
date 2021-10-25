//
//  EVScene.swift
//  EvinceTest
//
//  Created by Corbin Bigler on 10/23/21.
//

import Metal

@available(iOS 14.0, *)
public class EVScene {
    public var device: MTLDevice
    public var children: [EVShape] = []
    public var update: ((_ delta: Float) -> Void) = {_ in }

//    public func add(shape)
    
    public init(device: MTLDevice) {
        self.device = device
    }
    
    public func render(commandEncoder: MTLRenderCommandEncoder, delta: Float) {
        update(delta)
        
        for child in children {
            child.render(commandEncoder: commandEncoder)
        }
    }
}
