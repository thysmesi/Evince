//
//  EVScene.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/27/21.
//

import Metal
import Surrow
import UIKit

class EVScene: EVNode {
    var device: MTLDevice
    
    init(device: MTLDevice) {
      self.device = device
      super.init()
    }

    open func update() {}
}
