import Foundation
import CoreImage
class MetalFilter: CIFilter {

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let kernel: CIKernel
    dynamic var inputImage: CIImage?

    override init() {
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        let data = try! Data(contentsOf: url)
        kernel = try! CIKernel(functionName: "colorblind", fromMetalLibraryData: data)
        print("world")
        super.init()
    }


    override var outputImage: CIImage? {
        guard let inputImage = self.inputImage else {
            print("no input image")
            return nil
        }
        let inputExtent = inputImage.extent

        let roiCallback: CIKernelROICallback = { _, rect -> CGRect in  // (4)
            return rect
        }
        
        return self.kernel.apply(extent: inputExtent,
                                 roiCallback: roiCallback,
                                 arguments: [inputImage])
    }
}
