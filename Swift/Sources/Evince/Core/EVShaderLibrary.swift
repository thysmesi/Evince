//
//  ShaderLibrary.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/29/21.
//

import Metal

@available(iOS 13.0, *)
public class EVShaderLibrary {
    
    
    public init() {
        fillLibrary()
    }
    
    private var _library: [String: MTLFunction] = [:]
    
    public func fillLibrary() {
        _library.updateValue(EVEngine.defaultLibrary.makeFunction(name: "basic_vertex_shader")!, forKey: "basic_vertex_shader")
        _library.updateValue(EVEngine.defaultLibrary.makeFunction(name: "basic_fragment_shader")!, forKey: "basic_fragment_shader")
        _library.updateValue(EVEngine.defaultLibrary.makeFunction(name: "textured_fragment_shader")!, forKey: "textured_fragment_shader")
    }
    
    public func addShader(name: String, library: MTLLibrary = EVEngine.defaultLibrary) {
        _library.updateValue(library.makeFunction(name: name)!, forKey: name)
    }
    
    public subscript(_ type: String) -> MTLFunction {
        return _library[type]!
    }

}
