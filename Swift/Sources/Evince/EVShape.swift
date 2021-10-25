//
//  EVShape.swift
//  EvinceTest
//
//  Created by Corbin Bigler on 10/23/21.
//

import SwiftUI
import Surrow

@available(iOS 14.0, *)
public class EVShape: EVRenderable {
    public static func absToRel(of point: Point) -> SIMD3<Float> {
        let relative = point * 2 / Size(UIScreen.main.bounds.size) * Vector(1, -1) + Vector(-1, 1)
        return SIMD3<Float>(Float(relative.x), Float(relative.y), 0)
    }

    
    public var pipelineState: MTLRenderPipelineState!
    public let vertexFunctionName: String
    public let fragmentFunctionName: String
    public let device: MTLDevice
    public let color: Color
    public let vertices: [EVVertex]
    public let indices: [UInt16]
    public let texture: MTLTexture?
    
    public var transformations = EVTransformations()
    
    public var vertexBuffer: MTLBuffer?
    public var indexBuffer: MTLBuffer?
    
    public init(_ box: Box, color: Color = .gray, device: MTLDevice, texture: MTLTexture? = nil, vertexFunctionName: String = "ev_vertex_shader", fragmentFunctionName: String = "ev_fragment_shader") {
        self.vertexFunctionName = vertexFunctionName
        self.fragmentFunctionName = fragmentFunctionName
        self.color = color
        self.texture = texture
        self.device = device
        
        let polygon = box.polygon
        self.vertices = [
            EVVertex(position: Self.absToRel(of: polygon.points[0]), color: color.simd, texture: SIMD2<Float>(0,0)),
            EVVertex(position: Self.absToRel(of: polygon.points[1]), color: color.simd, texture: SIMD2<Float>(1,0)),
            EVVertex(position: Self.absToRel(of: polygon.points[2]), color: color.simd, texture: SIMD2<Float>(1,1)),
            EVVertex(position: Self.absToRel(of: polygon.points[3]), color: color.simd, texture: SIMD2<Float>(0,1))
        ]
        self.indices = [
            0, 1, 2,
            2, 3, 0
        ]
        
        self.pipelineState = buildPipelineState(device: device)
        
        buildBuffers(device: device)
    }
    
    private func buildBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                        length: vertices.count * MemoryLayout<EVVertex>.stride,
                                        options: [])
        indexBuffer = device.makeBuffer(bytes: indices,
                                        length: indices.count * MemoryLayout<UInt16>.size,
                                        options: [])
    }
    
    public func render(commandEncoder: MTLRenderCommandEncoder) {
        guard let indexBuffer = indexBuffer else { return }
        
        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer,
                                       offset: 0, index: 0)
        commandEncoder.setVertexBytes(&transformations,
                                      length: MemoryLayout<EVTransformations>.stride,
                                      index: 1)
        
        commandEncoder.setFragmentTexture(texture, index: 0)
        
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: indices.count,
                                             indexType: .uint16,
                                             indexBuffer: indexBuffer,
                                             indexBufferOffset: 0)
    }

}
