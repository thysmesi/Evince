//
//  HexColor.swift
//  PerfectMap
//
//  Created by Corbin Bigler on 10/25/21.
//

import SwiftUI
import simd

@available(iOS 13.0, *)
public struct HexColor {
    public var red: Double
    public var blue: Double
    public var green: Double
    public var alpha: Double
    
    public var uiColor: UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    public var cgColor: CGColor {
        CGColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    public var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
    public var hex: String {
        "#\(String(format:"%02X", Int(red*255)))\(String(format:"%02X", Int(green*255)))\(String(format:"%02X", Int(blue*255)))"
    }
    public var simd4: SIMD4<Float> {
        SIMD4<Float>(Float(red), Float(green), Float(blue), Float(alpha))
    }
    public var simd3: SIMD3<Float> {
        SIMD3<Float>(Float(red), Float(green), Float(blue))
    }
    
    public func brightness(scale: Double) -> HexColor {
        let red = min(1, red * scale)
        let green = min(1, green * scale)
        let blue = min(1, blue * scale)
        return HexColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public init(red: Double, green: Double, blue: Double, alpha: Double = 1){
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.red = Double(r) / 255
        self.green = Double(g) / 255
        self.blue = Double(b) / 255
        self.alpha = Double(a) / 255
    }
    public init(){
        self.red = 0.75
        self.green = 0.75
        self.blue = 0.75
        self.alpha = 1
    }
}
