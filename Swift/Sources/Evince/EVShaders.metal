#include <metal_stdlib>
using namespace metal;

struct EVTransformations {
  float4x4 matrix;
};

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
    float2 textureCoordinates [[ attribute(2) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float2 textureCoordinates;
};

vertex VertexOut ev_vertex_shader(const VertexIn vertexIn [[ stage_in ]],
                                  constant EVTransformations &evTransformations [[ buffer(1) ]])  {
  
    VertexOut vertexOut;
  
    vertexOut.position = evTransformations.matrix * vertexIn.position;
    vertexOut.color = vertexIn.color;
    vertexOut.textureCoordinates = vertexIn.textureCoordinates;

    return vertexOut;
}

fragment half4 ev_fragment_shader(VertexOut vertexIn [[ stage_in ]]) {
    return half4(vertexIn.color);
}

fragment half4 ev_textured_fragment_shader(VertexOut vertexIn [[ stage_in ]],
                                 sampler sampler2d [[ sampler(0) ]],
                                 texture2d<float> texture [[ texture(0) ]] ) {
    float4 color = texture.sample(sampler2d, vertexIn.textureCoordinates);
    if (color.a == 0.0) {
        discard_fragment();
    }
    return half4(color.r, color.g, color.b, 1);
}
