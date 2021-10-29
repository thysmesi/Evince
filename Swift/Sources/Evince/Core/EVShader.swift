import MetalKit

@available(iOS 13.0, *)
public class EVShader {
    public var function: MTLFunction!
    public init(name: String, functionName: String) {
        self.function = EVEngine.defaultLibrary.makeFunction(name: functionName)
        self.function.label = name
    }
    
}
