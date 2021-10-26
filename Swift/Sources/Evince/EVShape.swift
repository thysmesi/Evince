//
//  EVShape.swift
//  EvinceTest
//
//  Created by Corbin Bigler on 10/23/21.
//

import SwiftUI
import Surrow
import MetalKit

@available(iOS 14.0, *)
public class EVShape: EVRenderable {
    public static func absToRel(of point: Point) -> SIMD3<Float> {
        let relative = point * 2 / Size(UIScreen.main.bounds.size) * Vector(1, -1) + Vector(-1, 1)
        return SIMD3<Float>(Float(relative.x), Float(relative.y), 0)
    }
    
    public var polygon: Polygon
    public var position = SIMD2<Float>(repeating: 0)
    public var rotation: Float = 0
    public var scale = SIMD2<Float>(repeating: 1)
    
    var transformations: EVTransformations {
        let center = Self.absToRel(of: polygon.center)
        let screen = Size(UIScreen.main.bounds.size)

        let translation = matrix_float4x4(rows: [
            [1, 0, 0,position.x / Float(screen.width)],
            [0, 1, 0,-position.y / Float(screen.height)],
            [0, 0, 1,0],
            [0,0,0,1]
        ])
            
        let rotation = matrix_float4x4(rows: [
            [cos(self.rotation),-sin(self.rotation), 0,0],
            [sin(self.rotation), cos(self.rotation), 0,0],
            [0, 0, 1,0],
            [0,0,0,1]
        ])
        let to = Float(screen.min / screen.width)
        let bo = Float(screen.min / screen.height)
        let b = matrix_multiply(matrix_float4x4(rows: [
            [to, 0, 0, center.x],
            [0, bo, 0, center.y],
            [0, 0, 1,0],
            [0, 0, 0, 1]
        ]), rotation)
        let c = matrix_multiply(b, matrix_float4x4(rows: [
            [1 / to, 0, 0,-center.x / to],
            [0, 1 / bo, 0,-center.y / bo],
            [0, 0, 1,0],
            [0,0,0,1]
        ]))
        


        
        let scale = matrix_float4x4(rows: [
            [self.scale.x, 0, 0,0],
            [0, self.scale.y, 0,0],
            [0, 0, 1,0],
            [0,0,0,1]
        ])
        let matrix = matrix_multiply(scale, matrix_multiply(translation, c))
        return EVTransformations(matrix: matrix)
    }

    public var pipelineState: MTLRenderPipelineState!
    public let vertexFunctionName: String
    public var fragmentFunctionName: String
    public let device: MTLDevice
    public let color: Color
    public var vertices: [EVVertex] = []
    public var indices: [UInt16] = []
    public var texture: MTLTexture?
    
    public var vertexBuffer: MTLBuffer?
    public var indexBuffer: MTLBuffer?
        
    public init(_ box: Box, color: Color = .gray, device: MTLDevice, textureName: String? = nil, vertexFunctionName: String = "ev_vertex_shader", fragmentFunctionName: String = "ev_fragment_shader") {
        self.vertexFunctionName = vertexFunctionName
        self.fragmentFunctionName = fragmentFunctionName
        self.color = color
        self.device = device
        self.polygon = box.polygon
        
        if let path = textureName {
            setTexture(imageName: path)
            self.fragmentFunctionName = "ev_textured_fragment_shader"
        }
        
        let polygon = box.polygon
        self.vertices = [
            EVVertex(position: Self.absToRel(of: polygon.points[0]), color: color.simd, texture: SIMD2<Float>(1,1)),
            EVVertex(position: Self.absToRel(of: polygon.points[1]), color: color.simd, texture: SIMD2<Float>(0,1)),
            EVVertex(position: Self.absToRel(of: polygon.points[2]), color: color.simd, texture: SIMD2<Float>(0,0)),
            EVVertex(position: Self.absToRel(of: polygon.points[3]), color: color.simd, texture: SIMD2<Float>(1,0))
        ]
        self.indices = [
            0, 1, 2,
            2, 3, 0
        ]
        
        self.pipelineState = buildPipelineState(device: device)
        
        buildBuffers(device: device)
    }
    public init(_ polygon: Polygon, color: Color = .gray, device: MTLDevice, textureName: String? = nil, vertexFunctionName: String = "ev_vertex_shader", fragmentFunctionName: String = "ev_fragment_shader") {
        self.vertexFunctionName = vertexFunctionName
        self.fragmentFunctionName = fragmentFunctionName
        self.color = color
        self.device = device
        self.polygon = polygon
        
        if let path = textureName {
            setTexture(imageName: path)
            self.fragmentFunctionName = "ev_textured_fragment_shader"
        }
        
        let bounding = polygon.bounding
        for point in polygon.points {
            let t = (point - bounding.position) / bounding.size
            self.vertices.append(EVVertex(position: Self.absToRel(of: point), color: color.simd, texture: SIMD2<Float>(Float(t.x),Float(t.y))))
        }
        let triangles = polygon.triangles
        for triangle in triangles {
            self.indices.append(UInt16(Int(polygon.points.firstIndex(of: triangle.points[0])!)))
            self.indices.append(UInt16(Int(polygon.points.firstIndex(of: triangle.points[1])!)))
            self.indices.append(UInt16(Int(polygon.points.firstIndex(of: triangle.points[2])!)))
        }

        self.pipelineState = buildPipelineState(device: device)
        
        buildBuffers(device: device)
    }
    
    func setTexture(imageName: String) {
        let textureLoader = MTKTextureLoader(device: device)
        
        var texture: MTLTexture? = nil
        
        let textureLoaderOptions: [MTKTextureLoader.Option : Any]
        let origin = NSString(string: MTKTextureLoader.Origin.bottomLeft.rawValue)
        textureLoaderOptions = [MTKTextureLoader.Option.origin : origin]
        
        if let textureURL = Bundle.main.url(forResource: imageName, withExtension: nil) {
            do {
                texture = try textureLoader.newTexture(URL: textureURL, options: textureLoaderOptions)
            } catch {
                print("texture not created")
            }
        }
        
        self.texture = texture
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
        
        var t = transformations
        commandEncoder.setVertexBytes(&t,
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
