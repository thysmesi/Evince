
import SwiftUI

@available(iOS 14.0, *)
extension Color {
    var simd: SIMD4<Float> {

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        guard UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            return SIMD4<Float>()
        }

        return SIMD4<Float>(Float(r), Float(g), Float(b), Float(o))
    }
}
