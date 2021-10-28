//
//  EVShapeNode.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/27/21.
//

import Metal
import simd
import Surrow
import UIKit
import MetalKit

class EVShapeNode: EVNode, EVRenderable {
    var device: MTLDevice
    
    var vertices: [EVVertex] = []
    var indices: [UInt16] = []
    
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    
    var pipelineState: MTLRenderPipelineState!
    
    var vertexFunctionName: String = "ev_shape_vertex_shader"
    var fragmentFunctionName: String = "ev_shape_fragment_shader"
    
    var texture: MTLTexture?
    
    var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].offset = MemoryLayout<SIMD3<Float>>.stride + MemoryLayout<SIMD4<Float>>.stride
        vertexDescriptor.attributes[2].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<EVVertex>.stride
        
        return vertexDescriptor
    }
    
    init(_ polygon: Polygon, device: MTLDevice, color: HexColor = HexColor(), textureNamed: String? = nil) {
        self.device = device
        super.init()
        
        if let named = textureNamed {load(texture: named)}

        setupVertices(polygon, color: color)
        buildBuffers(device: device)
        pipelineState = buildPipelineState(device: device)
    }
    init(_ size: Size, device: MTLDevice, color: HexColor = HexColor(), textureNamed: String? = nil) {
        self.device = device
        super.init()
        
        if let named = textureNamed {load(texture: named)}
        
        setupVertices(Box(position: Point.origin, size: size).polygon, color: color)
        buildBuffers(device: device)
        pipelineState = buildPipelineState(device: device)
    }
    init(_ box: Box, device: MTLDevice, color: HexColor = HexColor(), textureNamed: String? = nil) {
        self.device = device
        super.init()
        
        if let named = textureNamed {load(texture: named)}
        
        setupVertices(box.polygon, color: color)
        buildBuffers(device: device)
        pipelineState = buildPipelineState(device: device)
    }
    
    func load(texture named: String) {
        texture = try? MTKTextureLoader(device: device).newTexture(name: named, scaleFactor: UIScreen.main.scale, bundle: Bundle.main)
        fragmentFunctionName = "ev_textured_fragment_shader"
    }
    func setupVertices(_ polygon: Polygon, color: HexColor) {
        let scale = Size(UIScreen.main.bounds.size).vector
        func relative(point: Point) -> SIMD3<Float> {
            let relative = point * Vector(1, -1) / (scale/2) + Vector(-1,1)
//            let relative = point /
            return SIMD3<Float>(Float(relative.x), Float(relative.y), 0)
        }
        
        func texturePosition(point: Point) -> SIMD2<Float> {
            let relative = (point - polygon.bounding.position) / polygon.bounding.size
            return SIMD2(Float(relative.x), Float(relative.y))
        }
        
        let color = color.simd4
        
        for point in polygon.points {
            vertices.append(EVVertex(position: relative(point: point), color: color, texture: texturePosition(point: point)))
        }
        let triangles = polygon.triangles
        for triangle in triangles {
            for point in triangle.points {
                indices.append(UInt16(Int(polygon.points.firstIndex {$0.id == point.id}!)))
            }
        }
    }
    
    private func buildBuffers(device: MTLDevice) {
      vertexBuffer = device.makeBuffer(bytes: vertices,
                                       length: vertices.count *
                                        MemoryLayout<EVVertex>.stride,
                                       options: [])
      indexBuffer = device.makeBuffer(bytes: indices,
                                      length: indices.count * MemoryLayout<UInt16>.size,
                                      options: [])
    }
    
    func doRender(commandEncoder: MTLRenderCommandEncoder, transformations: matrix_float4x4) {
        guard let indexBuffer = indexBuffer else { return }        
        var modelConstants = EVModelConstants(matrix: transformations)

        commandEncoder.setRenderPipelineState(pipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer,
                                       offset: 0, index: 0)
        commandEncoder.setVertexBytes(&modelConstants,
                                      length: MemoryLayout<EVModelConstants>.stride,
                                      index: 1)
        commandEncoder.setFragmentTexture(texture, index: 0)

        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: indices.count,
                                             indexType: .uint16,
                                             indexBuffer: indexBuffer,
                                             indexBufferOffset: 0)
    }
}
