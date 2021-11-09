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
    public var position: SIMD3<Float>
    public var color: SIMD4<Float>
    public var textureCoordinate: SIMD2<Float>
    
    public init(position: SIMD3<Float>, color: SIMD4<Float>, textureCoordinate: SIMD2<Float>) {
        self.position = SIMD3<Float>(position.x, -position.y, 0)
        self.color = color
        self.textureCoordinate = textureCoordinate
    }
}

public struct EVModelConstants: sizeable{
    public var modelMatrix = matrix_identity_float4x4
}
