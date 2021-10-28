//
//  Shader.metal
//  EVTesting
//
//  Created by Corbin Bigler on 10/27/21.
//

#include <metal_stdlib>
using namespace metal;

struct EVModelConstants {
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

vertex VertexOut ev_shape_vertex_shader(const VertexIn vertexIn [[ stage_in ]],
                                  constant EVModelConstants &evModelConstants [[ buffer(1) ]])  {
    VertexOut vertexOut;
  
    vertexOut.position = evModelConstants.matrix * vertexIn.position;
    vertexOut.color = vertexIn.color;
    vertexOut.textureCoordinates = vertexIn.textureCoordinates;

    return vertexOut;
}

fragment float4 ev_shape_fragment_shader(VertexOut vertexIn [[ stage_in ]]) {
    return float4(vertexIn.color);
}
fragment float4 ev_textured_fragment_shader(VertexOut vertexIn [[ stage_in ]],
                                 sampler sampler2d [[ sampler(0) ]],
                                 texture2d<float> texture [[ texture(0) ]] ) {
    float4 color = texture.sample(sampler2d, vertexIn.textureCoordinates);
    if (color.a == 0.0) {
        discard_fragment();
    }
    return float4(color.r, color.g, color.b, color.a);
}

//
//fragment half4 ev_textured_fragment_shader(VertexOut vertexIn [[ stage_in ]],
//                                 sampler sampler2d [[ sampler(0) ]],
//                                 texture2d<float> texture [[ texture(0) ]] ) {
//    float4 color = texture.sample(sampler2d, vertexIn.textureCoordinates);
//    if (color.a == 0.0) {
//        discard_fragment();
//    }
//    return half4(color.r, color.g, color.b, 1);
//}
//
//
//vertex float4 ev_shape_vertex_shader(const device packed_float3 *vertices [[ buffer(0) ]], uint vertexId [[ vertex_id ]]) {
//    return float4(vertices[vertexId], 1);
//}
//fragment half4 ev_shape_fragment_shader() {
//    return half4(1, 1, 0, 1);
//}
//
//
//vertex float4 vertex_shader(const device packed_float3 *vertices [[ buffer(0) ]], uint vertexId [[ vertex_id ]]) {
//    return float4(vertices[vertexId], 1);
//}
//
//fragment half4 fragment_shader() {
//    return half4(1, 1, 0, 1);
//}
