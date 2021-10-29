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
    public var position = SIMD2<Float>(0,0)
    public var scale = SIMD2<Float>(1,1)
    public var rotation: Float = 0
    
    public var vertices: [EVVertex] = []
    public var indices: [UInt16]?
    
    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer?
    
    public var renderPipelineState: MTLRenderPipelineState!
    
    var modelConstants = EVModelConstants()
    
    var modelMatrix: matrix_float4x4 {
        let radians = -rotation * (Float.pi/180)
        let screen = UIScreen.main.bounds.size
        
        let translation = matrix_float4x4(rows: [
            [1, 0, 0, position.x - Float(screen.width/2)],
            [0, 1, 0, -position.y + Float(screen.height/2)],
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
        let standardize = matrix_float4x4(rows: [
            [1 / Float(screen.width/2), 0, 0, 0],
            [0, -1 / Float(screen.height/2), 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        ])
        
        return standardize * ((translation * rotation) * scale)
    }
    
    public var texture: MTLTexture?
    
    public init(vertexShader: ShaderTypes? = nil, fragmentShader: ShaderTypes? = nil){
        buildVertices()
        buildBuffers()
        
        if vertexShader != fragmentShader {
            let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
            
            renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            renderPipelineDescriptor.vertexFunction = EVEngine.shaders[vertexShader ?? .vertexBasic]
            renderPipelineDescriptor.fragmentFunction = EVEngine.shaders[fragmentShader ?? .fragmentBasic]
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
    
    private func updateModelConstants(){
        modelConstants.modelMatrix = modelMatrix
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder){
        updateModelConstants()
        
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
}
