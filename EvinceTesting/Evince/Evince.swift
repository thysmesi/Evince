//
//  Evince.swift
//  EvinceTesting
//
//  Created by Corbin Bigler on 11/9/21.
//

import Foundation
import MetalKit

//enum EVKey {
//    case texture(String)
//    case vertex(String)
//    case fragment(String)
//    case samplerState(String)
//    case pipelineDescriptors(String)
//    case pipelineStates(String)
//}

//protocol EVKey {
//    var key: String { get }
//}

class Evince {
    
    
    // MARK: - Constants
    let device: MTLDevice
    let defaultLibrary: MTLLibrary
    let commandQueue: MTLCommandQueue
    let textureLoader: MTKTextureLoader
    let vertexDescriptor: MTLVertexDescriptor
    
    
    // MARK: - Libraries
    var pipelineDescriptors: [String:MTLRenderPipelineDescriptor] = [:]
    var pipelineStates: [String:MTLRenderPipelineState] = [:]
    var samplerStates: [String:MTLSamplerState] = [:]
    var textures: [String:MTLTexture] = [:]
    var shaders: [String:MTLFunction] = [:]
    
    
    // MARK: - Independents
    var nodes: [EVNode] = []
    
    
    // MARK: - Initializers
    init(device: MTLDevice = MTLCreateSystemDefaultDevice()!,
         vertexDescriptor: MTLVertexDescriptor = EVVertex.descriptor){
        self.device = device
        self.vertexDescriptor = vertexDescriptor
        self.textureLoader =  MTKTextureLoader(device: self.device)
        self.defaultLibrary = self.device.makeDefaultLibrary()!
        self.commandQueue = device.makeCommandQueue()!
        
        setShader("basic_fragment_shader")
        setShader("basic_vertex_shader")
        setShader("basic_textured_fragment_shader")
        setPipelineDescriptor("basic_pipeline_descriptor", vertex: "basic_vertex_shader", fragment: "basic_fragment_shader")
        setPipelineDescriptor("textured_pipeline_descriptor", vertex: "basic_vertex_shader", fragment: "basic_fragment_shader")
        setPipelineState("basic_pipeline_state", pipelineDescriptor: "basic_pipeline_descriptor")
        setPipelineState("textured_pipeline_state", pipelineDescriptor: "textured_pipeline_descriptor")
    }
    
    
    // MARK: - Methods
    func addNode(_ node: EVNode) {
        nodes.append(node)
    }
    
    func setTexture(_ key: String, named: String? = nil, scale: Double = 1.0){
        let _named = named ?? key
        textures[key] = try! textureLoader.newTexture(name: _named, scaleFactor: scale, bundle: .main, options: [MTKTextureLoader.Option.SRGB : (false as NSNumber)])
    }
    func setTexture(_ key: String, url: URL){
        textures[key] = try! textureLoader.newTexture(URL: url, options: [MTKTextureLoader.Option.SRGB : (false as NSNumber)])
    }
    func setTexture(_ key: String, texture: MTLTexture) {
        textures[key] = texture
    }
    
    func setShader(_ key: String, named: String? = nil, library: MTLLibrary? = nil) {
        let _named = named ?? key
        let _library = library ?? defaultLibrary
        shaders[key] = _library.makeFunction(name: _named)!
    }
    func setShader(_ key: String, shader: MTLFunction) {
        shaders[key] = shader
    }
    
    func setPipelineDescriptor(_ key: String, vertex: String, fragment: String) {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = shaders[vertex]
        pipelineDescriptor.fragmentFunction = shaders[vertex]
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        pipelineDescriptors[key] = pipelineDescriptor
    }
    func setPipelineDescriptor(_ key: String, pipelineDescriptor: MTLRenderPipelineDescriptor) {
        pipelineDescriptors[key] = pipelineDescriptor
    }
    
    func setPipelineState(_ key: String, pipelineDescriptor: String) {
        pipelineStates[key] = try! device.makeRenderPipelineState(descriptor: pipelineDescriptors[pipelineDescriptor]!)
    }
    func setPipelineState(_ key: String, pipelineState: MTLRenderPipelineState) {
        pipelineStates[key] = pipelineState
    }

    func setSamplerState(_ key: String, samplerDescriptor: MTLSamplerDescriptor) {
        samplerStates[key] = device.makeSamplerState(descriptor: samplerDescriptor)!
    }
    func setSamplerState(_ key: String, samplerState: MTLSamplerState) {
        samplerStates[key] = samplerState
    }
    
    
    // MARK: - Operators
    subscript(shader: String) -> MTLFunction {
        return shaders[shader]!
    }
    subscript(texture: String) -> MTLTexture {
        return textures[texture]!
    }
}
