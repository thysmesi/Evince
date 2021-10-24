//
//  EVSceneView.swift
//  EvinceTest
//
//  Created by Corbin Bigler on 10/23/21.
//

import SwiftUI
import MetalKit
import Surrow

struct EVSceneView: View {
//    let scene: EVScene
    let mtkView = MTKView(frame: UIScreen.main.bounds, device: MTLCreateSystemDefaultDevice()!)
    let renderer: EVRenderer
    
    init(scene: EVScene) {
        self.renderer = EVRenderer(device: MTLCreateSystemDefaultDevice()!)
        scene.children.append(EVShape(Box(position: Point(100, 100), size: Size(100, 100)), color: Color.red, device: renderer.device))
        self.renderer.scene = scene
        mtkView.delegate = self.renderer
    }
    
    var body: some View {
        MTKViewRepresentable(mtkView: mtkView)
    }
}

private struct MTKViewRepresentable: UIViewRepresentable {
    typealias UIViewType = MTKView
    var mtkView: MTKView

    func makeUIView(context: Context) -> MTKView {
        mtkView.depthStencilPixelFormat = .depth32Float
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
    }
}

struct EVSceneView_Previews: PreviewProvider {
    static var previews: some View {
        EVSceneView(scene: EVScene(device: MTLCreateSystemDefaultDevice()!))
    }
}
