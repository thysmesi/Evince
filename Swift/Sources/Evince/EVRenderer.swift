//
//  EVRenderer.swift
//  EvinceTest
//
//  Created by Corbin Bigler on 10/23/21.
//

import MetalKit

@available(iOS 14.0, *)
public class EVRenderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    var scene: EVScene?
    
    var samplerState: MTLSamplerState?
    var depthStencilState: MTLDepthStencilState?

    public init(device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()!
        super.init()
        buildSamplerState()
        buildDepthStencilState()
    }
    
    private func buildSamplerState() {
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        samplerState = device.makeSamplerState(descriptor: descriptor)
    }
    private func buildDepthStencilState() {
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }
}

@available(iOS 14.0, *)
extension EVRenderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }

    public func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor else { return }
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder =
            commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        let delta = 1 / Float(view.preferredFramesPerSecond)
        commandEncoder.setFragmentSamplerState(samplerState, index: 0)
        commandEncoder.setDepthStencilState(depthStencilState)
        
        scene?.render(commandEncoder: commandEncoder, delta: delta)
        
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
