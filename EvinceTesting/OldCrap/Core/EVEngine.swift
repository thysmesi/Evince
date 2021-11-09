//
//  EVEngine.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/29/21.
//

import MetalKit

@available(iOS 13.0, *)
public class EVEngine{
    public static let device = MTLCreateSystemDefaultDevice()!
    public static let commandQueue = device.makeCommandQueue()!
    public static let defaultLibrary = (try? device.makeDefaultLibrary(bundle: Bundle.module)) ?? device.makeDefaultLibrary()!
    public static let shaders = EVShaderLibrary()
    public static let vertexDescriptor = { () -> MTLVertexDescriptor in
        let vertexDescriptor = MTLVertexDescriptor()
        
        //Position
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0
        
        //Color
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = SIMD3<Float>.size
        
        //Texture Coordinate
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].bufferIndex = 0
        vertexDescriptor.attributes[2].offset = SIMD3<Float>.size + SIMD4<Float>.size
        
        vertexDescriptor.layouts[0].stride = EVVertex.stride
        return vertexDescriptor
    }()
    public static let basicRenderPipelineDescriptor = { () -> MTLRenderPipelineDescriptor in
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
        renderPipelineDescriptor.vertexFunction = shaders["basic_vertex_shader"]
        renderPipelineDescriptor.fragmentFunction = shaders["basic_fragment_shader"]
        renderPipelineDescriptor.vertexDescriptor = vertexDescriptor
        return renderPipelineDescriptor
    }()
    public static let basicRenderPipelineState = try! device.makeRenderPipelineState(descriptor: basicRenderPipelineDescriptor)
    public static let samplerState = { () -> MTLSamplerState in
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.magFilter = .linear
        return device.makeSamplerState(descriptor: samplerDescriptor)!
    }()
    public static let textureLoader = MTKTextureLoader(device: device)
}
