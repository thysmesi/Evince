//
//  File.swift
//  
//
//  Created by Corbin Bigler on 10/31/21.
//

import Metal
import simd

protocol EVRenderable {
    var renderPipelineState: MTLRenderPipelineState! { get set }    
    var modelConstants: EVModelConstants { get set }
    
    func doRender(renderCommandEncoder: MTLRenderCommandEncoder, modelViewMatrix: matrix_float4x4)
}
