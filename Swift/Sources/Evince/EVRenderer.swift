import MetalKit

@available(iOS 13.0, *)
public class EVRenderer: NSObject {
    public static var screenSize = SIMD2<Float>(0,0)
    public static var aspectRatio: Float {
        return screenSize.x / screenSize.y
    }
    
    public var scene: EVScene?
    
    public init(mtkView: MTKView, scene: EVScene) {
        super.init()
        updateScreenSize(view: mtkView)
        self.scene = scene
    }
    
}

@available(iOS 13.0, *)
extension EVRenderer: MTKViewDelegate{
    
    public func updateScreenSize(view: MTKView){
        EVRenderer.screenSize = SIMD2<Float>(Float(view.bounds.width), Float(view.bounds.height))
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateScreenSize(view: view)
    }
    
    public func draw(in view: MTKView) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        let commandBuffer = EVEngine.commandQueue.makeCommandBuffer()
        
        let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        scene?.render(renderCommandEncoder: renderCommandEncoder!, deltaTime: 1 / Float(view.preferredFramesPerSecond))
        
        renderCommandEncoder?.endEncoding()
        commandBuffer?.present(view.currentDrawable!)
        commandBuffer?.commit()
    }
    
}
