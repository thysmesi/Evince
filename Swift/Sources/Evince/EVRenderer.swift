import MetalKit

@available(iOS 10.0, *)
public class EVRenderer: NSObject {
    public static var screenSize = SIMD2<Float>(0,0)
    public static var aspectRatio: Float {
        return screenSize.x / screenSize.y
    }
    
    public var evince: Evince!
    
    public init(mtkView: MTKView, evince: Evince) {
        super.init()
        mtkView.isOpaque = false
        updateScreenSize(view: mtkView)
        self.evince = evince
    }
    
}

@available(iOS 10.0, *)
extension EVRenderer: MTKViewDelegate{
    
    public func updateScreenSize(view: MTKView){
        EVRenderer.screenSize = SIMD2<Float>(Float(view.bounds.width), Float(view.bounds.height))
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateScreenSize(view: view)
    }
    
    public func draw(in view: MTKView) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        let commandBuffer = evince.commandQueue.makeCommandBuffer()
        
        let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        
        evince.render(renderCommandEncoder: renderCommandEncoder!, deltaTime: 1 / Float(view.preferredFramesPerSecond))
        
        renderCommandEncoder?.endEncoding()
        commandBuffer?.present(view.currentDrawable!)
        commandBuffer?.commit()
    }
    
}
