//
//  EVNode.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/27/21.
//

import Metal
import simd
import Surrow
import UIKit

class EVNode {
//    private func mToTL(point: Point){
//
//    }
//    private func tlToM(point: Point){
//        let screen = Size(UIScreen.main.bounds.size)
//
//    }
    
    var id = UUID()
    var children: [EVNode] = []
    
    var position = SIMD2<Float>(repeating: 0)
    var scale = SIMD2<Float>(repeating: 1)
    var rotation: Float = 0
    
    var transformations: matrix_float4x4 {
        let screen = Size(UIScreen.main.bounds.size)
        let radians = rotation * (Float.pi/180)
        
        let c = position.x / Float(screen.width/2)
        let d = -position.y / Float(screen.height/2)
        let g = self.scale.x
        let h = self.scale.y
        let t = Float(screen.min / screen.width)
        let b = Float(screen.min / screen.height)
        let cosr = cos(radians)
        let sinr = sin(radians)
        
//        return matrix_float4x4(rows: [
//            [g*cosr, -(g*t*sinr)/(b), 0, ((h*t*sinr)/(b))+c+(g*cosr)-1],
//            [(b*g*sinr)/(t), g*cosr, 0, ((b*g*sinr)/(t))+d-(h*cosr)+1],
//            [0, 0, 1, 0],
//            [0 ,0, 0, 1]
//        ])
        return matrix_float4x4(rows: [
            [g*sinr, -(g*t*cosr)/(b), 0, ((h*t*cosr)/(b))+c+(g*sinr)-1],
            [(b*g*cosr)/(t), g*sinr, 0, ((b*g*cosr)/(t))+d-(h*sinr)+1],
            [0, 0, 1, 0],
            [0 ,0, 0, 1]
        ])
    }
        
    func add(child node: EVNode) {
        children.append(node)
    }
    func remove(child node: EVNode) -> Bool {
        if let index = children.firstIndex(where: {$0.id == node.id }) {
            children.remove(at: index)
            return true
        }
        return false
    }
    func remove(child id: UUID) -> Bool {
        if let index = children.firstIndex(where: {$0.id == id }) {
            children.remove(at: index)
            return true
        }
        return false
    }
    
    func render(commandEncoder: MTLRenderCommandEncoder, parentTransformations: matrix_float4x4) {
//        let transformations = matrix_multiply(parentTransformations, self.transformations)
        
        for child in children {
            child.render(commandEncoder: commandEncoder, parentTransformations: transformations)
        }
        if let renderable = self as? EVRenderable {
            renderable.doRender(commandEncoder: commandEncoder, transformations: transformations)
        }
    }
}