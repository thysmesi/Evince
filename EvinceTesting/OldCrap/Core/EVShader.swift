import MetalKit

@available(iOS 13.0, *)
public class EVShader {
    public var function: MTLFunction!
    public init(name: String, functionName: String) {
        self.function = EVEngine.defaultLibrary.makeFunction(name: functionName)
        self.function.label = name
    }
    public init(name: String, functionName: String, library: MTLLibrary) {
        self.function = library.makeFunction(name: functionName)
        self.function.label = name
    }
}
