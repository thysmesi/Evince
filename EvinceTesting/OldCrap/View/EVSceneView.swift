import SwiftUI
import MetalKit

@available(iOS 13.0, *)
public struct EVSceneView: View {
    public let mtkView = MTKView(frame: UIScreen.main.bounds, device: MTLCreateSystemDefaultDevice()!)
    public let renderer: EVRenderer
    
    @State var mtkViewRepresentable: MTKViewRepresentable!
    
    public init(scene: EVScene) {
        renderer = EVRenderer(mtkView: mtkView, scene: scene)
        renderer.scene = scene
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
}

@available(iOS 13.0, *)
public struct MTKViewRepresentable: UIViewRepresentable {
    public typealias UIViewType = MTKView
    public var mtkView: MTKView

    public func makeUIView(context: Context) -> MTKView {
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        return mtkView
    }
    
    public func updateUIView(_ uiView: MTKView, context: Context) {
    }
}
