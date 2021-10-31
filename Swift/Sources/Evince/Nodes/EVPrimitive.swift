//
//  File.swift
//  
//
//  Created by Corbin Bigler on 10/31/21.
//

import Metal
import simd

@available(iOS 13.0, *)
open class EVPrimitive: EVNode, EVRenderable {    
    
    public var vertices: [EVVertex] = []
    public var indices: [UInt16]?

    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer?
    
    public var renderPipelineState: MTLRenderPipelineState!
    
    public var texture: MTLTexture?
    
    public init(id: UUID = UUID(), vertexShader: String? = nil, fragmentShader: String? = nil) {
        super.init(id: id)
        
        if vertexShader != fragmentShader {
            let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
            
            renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            renderPipelineDescriptor.vertexFunction = EVEngine.shaders[vertexShader ?? "basic_vertex_shader"]
            renderPipelineDescriptor.fragmentFunction = EVEngine.shaders[fragmentShader ?? "basic_fragment_shader"]
            renderPipelineDescriptor.vertexDescriptor = EVEngine.vertexDescriptor
            
            renderPipelineState = try! EVEngine.device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } else {
            renderPipelineState = EVEngine.basicRenderPipelineState
        }
        
        buildVertices()
        buildBuffers()
    }
    
    open func buildVertices() {}
    public final func buildBuffers(){
        vertexBuffer = EVEngine.device.makeBuffer(bytes: vertices,
                                                    length: EVVertex.stride(vertices.count),
                                                    options: [])
        if let indices = indices {
            indexBuffer = EVEngine.device.makeBuffer(bytes: indices,
                                                        length: UInt16.size(vertices.count),
                                                        options: [])
        }
    }
    
    func doRender(renderCommandEncoder: MTLRenderCommandEncoder, modelViewMatrix: float4x4){
        modelConstants.modelMatrix = modelViewMatrix
        
        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setVertexBytes(&modelConstants, length: EVModelConstants.stride, index: 1)
        
        if let texture = texture {
            renderCommandEncoder.setFragmentSamplerState(EVEngine.samplerState, index: 0)
            renderCommandEncoder.setFragmentTexture(texture, index: 0)
        }
        
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0,
                                             index: 0)
        if let indexBuffer = indexBuffer, let indices = indices {
            print(indices.count)
            print(vertices.count)
            renderCommandEncoder.drawIndexedPrimitives(type: .triangle,
                                                 indexCount: indices.count,
                                                 indexType: .uint16,
                                                 indexBuffer: indexBuffer,
                                                 indexBufferOffset: 0)
        } else {
            renderCommandEncoder.drawPrimitives(type: .triangle,
                                                vertexStart: 0,
                                                vertexCount: vertices.count)
        }
    }
    
    public func add(child: EVNode) {
        children.append(child)
    }
}
