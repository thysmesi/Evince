//
//  EVSceneView.swift
//  EvinceTest
//
//  Created by Corbin Bigler on 10/23/21.
//

import SwiftUI
import MetalKit
import Surrow

@available(iOS 14.0, *)
public struct EVSceneView: View {
    public let mtkView = MTKView(frame: UIScreen.main.bounds, device: MTLCreateSystemDefaultDevice()!)
    public let renderer: EVRenderer
    
    public init(scene: EVScene) {
        self.renderer = EVRenderer(device: MTLCreateSystemDefaultDevice()!)
        self.renderer.scene = (scene)
        mtkView.delegate = self.renderer
    }
    public init(scene: EVScene, renderer: EVRenderer) {
        self.renderer = renderer
        self.renderer.scene = (scene)
        mtkView.delegate = self.renderer
    }
    
    public var body: some View {
        MTKViewRepresentable(mtkView: mtkView)
    }
}

@available(iOS 13.0, *)
private struct MTKViewRepresentable: UIViewRepresentable {
    typealias UIViewType = MTKView
    var mtkView: MTKView

    func makeUIView(context: Context) -> MTKView {
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.colorPixelFormat = .rgba32Sint
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
    }
}
