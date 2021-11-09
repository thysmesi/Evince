//
//  Evince.swift
//  EvinceTesting
//
//  Created by Corbin Bigler on 11/9/21.
//

import Foundation
import MetalKit

@available(iOS 10.0, *)
public class Evince {
    
    
    // MARK: - Constants
    public let device: MTLDevice
    public let defaultLibrary: MTLLibrary
    public let commandQueue: MTLCommandQueue
    public let textureLoader: MTKTextureLoader
    public let vertexDescriptor: MTLVertexDescriptor
    
    
    // MARK: - Libraries
    public var pipelineDescriptors: [String:MTLRenderPipelineDescriptor] = [:]
    public var pipelineStates: [String:MTLRenderPipelineState] = [:]
    public var samplerStates: [String:MTLSamplerState] = [:]
    public var textures: [String:MTLTexture] = [:]
    public var shaders: [String:MTLFunction] = [:]
    
    
    // MARK: - Independents
    public var nodes: [EVNode] = []
    public var position = SIMD2<Float>(0,0)
    public var scale = SIMD2<Float>(1,1)
    public var rotation: Float = 0
    
    
    // MARK: - Dependents
    public var modelConstants: EVModelConstants = EVModelConstants()
    open var modelMatrix: matrix_float4x4 {
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
            [0, -scale.y, 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        ])
        let standardize = matrix_float4x4(rows: [
            [1 / Float(screen.width/2), 0, 0, 0],
            [0, 1 / Float(screen.height/2), 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1]
        ])
        
        return standardize * ((translation * rotation) * scale)
    }

    
    // MARK: - Initializers
    public init(device: MTLDevice = MTLCreateSystemDefaultDevice()!,
         vertexDescriptor: MTLVertexDescriptor = EVVertex.descriptor){
        self.device = device
        self.vertexDescriptor = vertexDescriptor
        self.textureLoader =  MTKTextureLoader(device: self.device)
        self.defaultLibrary = (try? device.makeDefaultLibrary(bundle: Bundle.module)) ?? device.makeDefaultLibrary()!
        self.commandQueue = device.makeCommandQueue()!
        
        setShader("basic_fragment_shader")
        setShader("basic_vertex_shader")
        setShader("transforming_vertex_shader")
        setShader("textured_fragment_shader")
        setPipelineDescriptor("basic_pipeline_descriptor", vertex: "basic_vertex_shader", fragment: "basic_fragment_shader")
        setPipelineDescriptor("textured_pipeline_descriptor", vertex: "basic_vertex_shader", fragment: "basic_fragment_shader")
        setPipelineState("basic_pipeline_state", pipelineDescriptor: "basic_pipeline_descriptor")
        setPipelineState("textured_pipeline_state", pipelineDescriptor: "textured_pipeline_descriptor")
        
        let linear = MTLSamplerDescriptor()
        linear.minFilter = .linear
        linear.magFilter = .linear
        setSamplerState("linear_sampler_state", samplerDescriptor: linear)
        
        let nearest = MTLSamplerDescriptor()
        nearest.minFilter = .nearest
        nearest.magFilter = .nearest
        setSamplerState("nearest_sampler_state", samplerDescriptor: nearest)
    }
    
    
    // MARK: - Methods
    open func render(renderCommandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        update(deltaTime: deltaTime)
        modelConstants.modelMatrix = modelMatrix
        
        renderCommandEncoder.setVertexBytes(&modelConstants, length: EVModelConstants.stride, index: 1)
        
        if nodes.count > 0 {
            renderCommandEncoder.setRenderPipelineState(nodes[0].pipelineState)
            var lastPipelineState = nodes[0].pipelineStateName
            for node in nodes {
                if node.pipelineStateName != lastPipelineState {
                    renderCommandEncoder.setRenderPipelineState(node.pipelineState)
                    lastPipelineState = node.pipelineStateName
                }
                
                node.setBytes(renderCommandEncoder: renderCommandEncoder)
                
                if let texture = node.texture {
                    renderCommandEncoder.setFragmentSamplerState(node.samplerState, index: 0)
                    renderCommandEncoder.setFragmentTexture(texture, index: 0)
                }
                
                renderCommandEncoder.setVertexBuffer(node.vertexBuffer,
                                                     offset: 0,
                                                     index: 0)
                renderCommandEncoder.drawPrimitives(type: .triangle,
                                                    vertexStart: 0,
                                                    vertexCount: node.vertices.count)
            }
        }
    }
    
    open func update(deltaTime: Float) {}
    
    public func addNode(_ node: EVNode) {
        nodes.append(node)
        
        if node.vertexBuffer == nil {
            node.vertexBuffer = device.makeBuffer(bytes: node.vertices,
                                                  length: EVVertex.stride(node.vertices.count),
                                                  options: [])
        }
    }
    
    public func setTexture(_ key: String, named: String? = nil, scale: Double = 1.0){
        let _named = named ?? key
        textures[key] = try! textureLoader.newTexture(name: _named, scaleFactor: scale, bundle: .main, options: [MTKTextureLoader.Option.SRGB : (false as NSNumber)])
    }
    public func setTexture(_ key: String, url: URL){
        textures[key] = try! textureLoader.newTexture(URL: url, options: [MTKTextureLoader.Option.SRGB : (false as NSNumber)])
    }
    public func setTexture(_ key: String, texture: MTLTexture) {
        textures[key] = texture
    }
    
    public func setShader(_ key: String, named: String? = nil, library: MTLLibrary? = nil) {
        let _named = named ?? key
        let _library = library ?? defaultLibrary
        shaders[key] = _library.makeFunction(name: _named)!
    }
    public func setShader(_ key: String, shader: MTLFunction) {
        shaders[key] = shader
    }
    
    public func setPipelineDescriptor(_ key: String, vertex: String, fragment: String) {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = shaders[vertex]
        pipelineDescriptor.fragmentFunction = shaders[fragment]
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        pipelineDescriptors[key] = pipelineDescriptor
    }
    public func setPipelineDescriptor(_ key: String, pipelineDescriptor: MTLRenderPipelineDescriptor) {
        pipelineDescriptors[key] = pipelineDescriptor
    }
    
    public func setPipelineState(_ key: String, pipelineDescriptor: String) {
        pipelineStates[key] = try! device.makeRenderPipelineState(descriptor: pipelineDescriptors[pipelineDescriptor]!)
    }
    public func setPipelineState(_ key: String, pipelineState: MTLRenderPipelineState) {
        pipelineStates[key] = pipelineState
    }

    public func setSamplerState(_ key: String, samplerDescriptor: MTLSamplerDescriptor) {
        samplerStates[key] = device.makeSamplerState(descriptor: samplerDescriptor)!
    }
    public func setSamplerState(_ key: String, samplerState: MTLSamplerState) {
        samplerStates[key] = samplerState
    }
}
