//
//  EVScene.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/27/21.
//

import Metal
import Surrow
import UIKit

@available(iOS 13.0, *)
public class EVScene: EVNode {
    public var device: MTLDevice
    
    public init(device: MTLDevice) {
      self.device = device
      super.init()
    }

    open func update() {}
}
