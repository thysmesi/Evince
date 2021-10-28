//
//  EVSceneView.swift
//  EVTesting
//
//  Created by Corbin Bigler on 10/27/21.
//

import SwiftUI
import MetalKit
import Surrow

@available(iOS 13.0, *)
public struct EVSceneView: View {
    public let mtkView = MTKView(frame: UIScreen.main.bounds, device: MTLCreateSystemDefaultDevice()!)
    public let renderer: EVRenderer
    
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
        .edgesIgnoringSafeArea(.all)
    }
}

@available(iOS 13.0, *)
public struct MTKViewRepresentable: UIViewRepresentable {
    public typealias UIViewType = MTKView
    public var mtkView: MTKView

    public func makeUIView(context: Context) -> MTKView {
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        mtkView.colorPixelFormat = .rgba16Float
        return mtkView
    }
    
    public func updateUIView(_ uiView: MTKView, context: Context) {
    }
}
