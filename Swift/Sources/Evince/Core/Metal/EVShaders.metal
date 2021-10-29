//
//  EVShaders.metal
//  EVTesting
//
//  Created by Corbin Bigler on 10/29/21.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn{
    float2 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
    float2 textureCoordinate [[ attribute(2) ]];
};

struct RasterizerData{
    float4 position [[ position ]];
    float4 color;
    float2 textureCoordinate;
    float totalGameTime;
};

struct ModelConstants{
    float4x4 modelMatrix;
};

vertex RasterizerData basic_vertex_shader(const VertexIn vIn [[ stage_in ]],
                                          constant ModelConstants &sceneConstants [[ buffer(1) ]],
                                          constant ModelConstants &modelConstants [[ buffer(2) ]]){
    RasterizerData rd;
    
    rd.position = (modelConstants.modelMatrix * float4(vIn.position, 1));
    rd.color = vIn.color;
    rd.textureCoordinate = vIn.textureCoordinate;
    
    return rd;
}

fragment half4 basic_fragment_shader(RasterizerData rd [[ stage_in ]]){
    float4 color = rd.color;
    return half4(color.r, color.g, color.b, color.a);
}

fragment float4 textured_fragment_shader(RasterizerData rd [[ stage_in ]],
                                 sampler sampler2d [[ sampler(0) ]],
                                 texture2d<float> texture [[ texture(0) ]] ) {
    
    float4 color = texture.sample(sampler2d, rd.textureCoordinate);
    if (color.a == 0.0) {
        discard_fragment();
    }
    return float4(color.r, color.g, color.b, color.a);
}
