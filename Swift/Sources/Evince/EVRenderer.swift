//
//  EVRenderer.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/27/21.
//

import MetalKit

class EVRenderer: NSObject {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    var scene: EVScene?

    var samplerState: MTLSamplerState?

    init(device: MTLDevice) {
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

extension EVRenderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }

    func draw(in view: MTKView) {
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
