import SwiftUI
import MetalKit

@available(iOS 13.0, *)
public struct EvinceView: View {
    public let mtkView = MTKView(frame: UIScreen.main.bounds, device: MTLCreateSystemDefaultDevice()!)
    public let renderer: EVRenderer
    
    @State var mtkViewRepresentable: MTKViewRepresentable!
    
    public init(evince: Evince) {
        renderer = EVRenderer(mtkView: mtkView, evince: evince)
        mtkView.delegate = renderer
    }
    
    public var body: some View {
        GeometryReader { geometry in
            if let mtkViewRepresentable = mtkViewRepresentable {
                mtkViewRepresentable
            }
        }
        .onAppear {
            if mtkViewRepresentable == nil {
                mtkViewRepresentable = MTKViewRepresentable(mtkView: mtkView)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func clearColor(_ color: MTLClearColor) {
        mtkView.clearColor = color
    }
}

@available(iOS 13.0, *)
public struct MTKViewRepresentable: UIViewRepresentable {
    public typealias UIViewType = MTKView
    public var mtkView: MTKView

    public func makeUIView(context: Context) -> MTKView {
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        return mtkView
    }
    
    public func updateUIView(_ uiView: MTKView, context: Context) {
    }
}
