//
//  EVRenderer.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/27/21.
//

import MetalKit

@available(iOS 13.0, *)
public class EVRenderer: NSObject {
    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue

    public var scene: EVScene?

    public var samplerState: MTLSamplerState?

    public init(device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()!
        super.init()
        buildSamplerState()
    }
  
    private func buildSamplerState() {
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        samplerState = device.makeSamplerState(descriptor: descriptor)
    }
}

@available(iOS 13.0, *)
extension EVRenderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }

    public func draw(in view: MTKView) {
        scene?.update()
        
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor else { return }
//        print(view.depthStencilTexture?.pixelFormat)
//        print(view.colorPixelFormat)
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        
        commandEncoder.setFragmentSamplerState(samplerState, index: 0)
        
        scene?.render(commandEncoder: commandEncoder, parentTransformations: matrix_float4x4(1))
        
        commandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
