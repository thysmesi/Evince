//
//  EVSceneView.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/27/21.
//

import SwiftUI
import MetalKit
import Surrow

struct EVSceneView: View {
    let mtkView = MTKView(frame: UIScreen.main.bounds, device: MTLCreateSystemDefaultDevice()!)
    let renderer: EVRenderer
    
    @State var mtkViewRepresentable: MTKViewRepresentable!
    
    public init(scene: EVScene) {
        let device = MTLCreateSystemDefaultDevice()!
        
        renderer = EVRenderer(device: device)
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
        .ignoresSafeArea()
    }
}

struct MTKViewRepresentable: UIViewRepresentable {
    typealias UIViewType = MTKView
    var mtkView: MTKView

    func makeUIView(context: Context) -> MTKView {
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        mtkView.colorPixelFormat = .rgba16Float
//        mtkView.framebufferOnly = true
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
    }
}

//@available(iOS 13.0, *)
//private struct MTKViewRepresentable: UIViewRepresentable {
//    typealias UIViewType = MTKView
//    var mtkView: MTKView
//
//    func makeUIView(context: Context) -> MTKView {
//        mtkView.depthStencilPixelFormat = .depth32Float
//        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
//        mtkView.colorPixelFormat = .rgba32Uint
//
//        return mtkView
//    }
//
//    func updateUIView(_ uiView: MTKView, context: Context) {
//    }
//}
