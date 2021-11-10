//
//  EVNode.swift
//  EvinceTesting
//
//  Created by Corbin Bigler on 11/9/21.
//

import Metal

@available(iOS 10.0, *)
open class EVNode {
    
    public var vertices: [EVVertex] = []
    public var vertexBuffer: MTLBuffer!
    public var evince: Evince
    
    public var pipelineState: MTLRenderPipelineState
    public var pipelineStateName: String
    
    public var texture: MTLTexture?
    public var samplerState: MTLSamplerState

    open func setBytes(renderCommandEncoder: MTLRenderCommandEncoder) {}
    
    public init(vertices: [EVVertex], pipelineState: String, evince: Evince, texture: String? = nil, samplerState: String = "linear_sampler_state"){
        self.vertices = vertices
        self.evince = evince
        self.samplerState = evince.samplerStates[samplerState]!
        self.pipelineState = evince.pipelineStates[pipelineState]!
        self.pipelineStateName = pipelineState
        if let texture = texture {
            self.texture = evince.textures[texture]!
        }
    }
}
