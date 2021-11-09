//
//  Basic.metal
//  EvinceTesting
//
//  Created by Corbin Bigler on 11/9/21.
//

#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

vertex RasterizerData basic_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                          constant ModelConstants &modelConstants [[ buffer(1) ]]){
    RasterizerData rd;
    
    rd.position = modelConstants.modelMatrix * float4(vIn.position, 1);
    rd.color = vIn.color;
    rd.textureCoordinate = vIn.textureCoordinate;
    
    return rd;
}

fragment half4 basic_fragment_shader(RasterizerData rd [[ stage_in ]]){
    float4 color = rd.color;
    return half4(color.r, color.g, color.b, color.a);
}

fragment float4 basic_textured_fragment_shader(RasterizerData rd [[ stage_in ]],
                                 sampler sampler2d [[ sampler(0) ]],
                                 texture2d<float> texture [[ texture(0) ]] ) {
    
    float4 color = texture.sample(sampler2d, rd.textureCoordinate);
    if (color.a == 0.0) {
        discard_fragment();
    }
    return float4(color.r, color.g, color.b, color.a);
}
