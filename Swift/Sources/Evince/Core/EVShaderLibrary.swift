//
//  ShaderLibrary.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/29/21.
//

import Metal

public enum ShaderTypes {
    case vertexBasic
    case fragmentBasic
    case fragmentTextured
}

@available(iOS 13.0, *)
public class EVShaderLibrary {
    
    
    public init() {
        fillLibrary()
    }
    
    private var _library: [ShaderTypes: EVShader] = [:]
    
    public func fillLibrary() {
        _library.updateValue(EVShader(name: "Basic Vertex Shader",
                                         functionName: "basic_vertex_shader"),
                                  forKey: .vertexBasic)
        _library.updateValue(EVShader(name: "Basic Fragment Shader",
                                         functionName: "basic_fragment_shader"),
                                  forKey: .fragmentBasic)
        _library.updateValue(EVShader(name: "Textured Fragment Shader",
                                         functionName: "textured_fragment_shader"),
                                  forKey: .fragmentTextured)
    }
    
    public subscript(_ type: ShaderTypes) -> MTLFunction {
        return (_library[type]?.function)!
    }

}
