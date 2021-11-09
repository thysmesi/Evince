#ifndef SHARED_METAL
#define SHARED_METAL

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

#endif
