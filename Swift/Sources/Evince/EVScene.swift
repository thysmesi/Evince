//
//  EVScene.swift
//  EvinceTest
//
//  Created by Corbin Bigler on 10/23/21.
//

import Metal

class EVScene {
    var device: MTLDevice
    var children: [EVShape] = []
    var update: ((_ delta: Float) -> Void) = {_ in }

    init(device: MTLDevice) {
        self.device = device
    }
    
    func render(commandEncoder: MTLRenderCommandEncoder, delta: Float) {
        update(delta)
        
        for child in children {
            child.render(commandEncoder: commandEncoder)
        }
    }
}
