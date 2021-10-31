//
//  EVNode.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/29/21.
//

import Metal
import simd
import UIKit

@available(iOS 13.0, *)
open class EVNode {
    public let id: UUID
    
    public var position = SIMD2<Float>(0,0) {
        didSet {
            _updateModelConstants = true
        }
    }
    public var scale = SIMD2<Float>(1,1) {
        didSet {
            _updateModelConstants = true
        }
    }
    public var rotation: Float = 0 {
        didSet {
            _updateModelConstants = true
        }
    }
    
    public var vertices: [EVVertex] = []
    public var indices: [UInt16]?
    
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer?
    
    public var renderPipelineState: MTLRenderPipelineState!
        
    var modelConstants = EVModelConstants()
    private var _updateModelConstants: Bool = true
    
    var modelMatrix: matrix_float4x4 {
        let radians = -rotation * (Float.pi/180)
        
        let translation = matrix_float4x4(rows: [
            [1, 0, 0, position.x],
            [0, 1, 0, -position.y],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        ])
        let rotation = matrix_float4x4(rows: [
            [cos(radians), -sin(radians), 0, 0],
            [sin(radians), cos(radians), 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        ])
        let scale = matrix_float4x4(rows: [
            [scale.x, 0, 0, 0],
            [0, scale.y, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        ])
        return ((translation * rotation) * scale)
    }
    
    public var texture: MTLTexture?
    
    public init(id: UUID = UUID(), vertexShader: String? = nil, fragmentShader: String? = nil){
        self.id = id
        
        buildVertices()
        buildBuffers()
        
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
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder){
        if _updateModelConstants {
            modelConstants.modelMatrix = modelMatrix
            _updateModelConstants = false
        }
        
        renderCommandEncoder.setRenderPipelineState(renderPipelineState)
        renderCommandEncoder.setVertexBytes(&modelConstants, length: EVModelConstants.stride, index: 2)
        
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
}
