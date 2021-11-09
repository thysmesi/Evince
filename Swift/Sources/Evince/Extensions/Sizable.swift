//
//  sizable.swift
//  EvinceTesting
//
//  Created by Corbin Bigler on 11/9/21.
//

import Foundation

public protocol Sizeable{ }
public extension Sizeable{
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

extension Float: Sizeable { }
extension UInt16: Sizeable { }
extension SIMD2: Sizeable { }
extension SIMD3: Sizeable { }
extension SIMD4: Sizeable { }
extension EVVertex: Sizeable { }
