import simd

public protocol sizeable{ }
public extension sizeable{
    static var size: Int{
        return MemoryLayout<Self>.size
    }
    
    static var stride: Int{
        return MemoryLayout<Self>.stride
    }
    
    static func size(_ count: Int)->Int{
        return MemoryLayout<Self>.size * count
    }
    
    static func stride(_ count: Int)->Int{
        return MemoryLayout<Self>.stride * count
    }
}

extension Float: sizeable { }
extension UInt16: sizeable { }
extension SIMD2: sizeable { }
extension SIMD3: sizeable { }
extension SIMD4: sizeable { }

public struct EVVertex: sizeable{
    var position: SIMD2<Float>
    var color: SIMD4<Float>
    var textureCoordinate: SIMD2<Float>
    
    public init(position: SIMD2<Float>, color: SIMD4<Float>, textureCoordinate: SIMD2<Float>) {
        self.position = position
        self.color = color
        self.textureCoordinate = textureCoordinate
    }
}

public struct EVModelConstants: sizeable{
    var modelMatrix = matrix_identity_float4x4
}
