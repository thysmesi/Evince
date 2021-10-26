//
//  EVScene.swift
//  EvinceTest
//
//  Created by Corbin Bigler on 10/23/21.
//

import Metal

@available(iOS 14.0, *)
open class EVScene {
    let id = UUID()
    
    public var device: MTLDevice
    public var children: [EVShape] = []
    public var update: ((_ delta: Float, _ children: [EVShape]) -> Void) = {_,_  in }

//    public func add(shape)
    
    public init(device: MTLDevice) {
        self.device = device
    }
    
    open func render(commandEncoder: MTLRenderCommandEncoder, delta: Float) {
        update(delta, children)
        
        for child in children {
            child.render(commandEncoder: commandEncoder)
        }
    }
}
