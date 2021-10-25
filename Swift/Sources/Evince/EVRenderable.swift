//
//  EVRenderable.swift
//  EvinceTest
//
//  Created by Corbin Bigler on 10/23/21.
//

import Metal

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public protocol EVRenderable: AnyObject {
    var pipelineState: MTLRenderPipelineState! { get set }
    var vertexFunctionName: String { get }
    var fragmentFunctionName: String { get }
    var vertexDescriptor: MTLVertexDescriptor { get }
    
    func render(commandEncoder: MTLRenderCommandEncoder)
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension EVRenderable {
    public var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[2].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<EVVertex>.stride
        return vertexDescriptor
    }

    public func buildPipelineState(device: MTLDevice) -> MTLRenderPipelineState {
        let libraryURL: URL = Bundle.module.url(forResource: "EVShaders", withExtension: "metal")!
//        guard let metalDevice: MTLDevice = MTLCreateSystemDefaultDevice() else { return }
        let library = try? device.makeLibrary(filepath: libraryURL.path)
//        guard let metalShader: MTLFunction = metalLib.makeFunction(name: "myMetalFunc") else { return }

//        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: vertexFunctionName)
        let fragmentFunction = library?.makeFunction(name: fragmentFunctionName)

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
        
        return pipelineState
    }
}

