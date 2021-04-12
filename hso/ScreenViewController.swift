import SwiftUI
import AVFoundation
import AVKit
import MetalKit
import AppKit

class ScreenViewController: NSViewController {
    private let screenInput = AVCaptureScreenInput()
    let captureSession = AVCaptureSession()
    let previewLayer = AVCaptureVideoPreviewLayer()
    let captureOutput = AVCaptureVideoDataOutput()
    let colorblindFilter = GLSLFilter()
    
    var backCamera : AVCaptureDevice!
    var frontCamera : AVCaptureDevice!
    var backInput : AVCaptureInput!
    var frontInput : AVCaptureInput!
    
    
    
    //metal
    let metalDevice : MTLDevice = MTLCreateSystemDefaultDevice()!
    var metalCommandQueue : MTLCommandQueue!
    
    //core image
    var ciContext : CIContext!
    
    var currentCIImage : CIImage?
    
    
    let mtkView = MTKView(frame: NSMakeRect(0, 0, 400, 400))
    
    override func loadView() {
        self.view = mtkView
        
        NSLayoutConstraint.activate([
        ])
    }
    
    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetal()
        setupCoreImage()
        setupAndStartCaptureSession()
    }
    
    //MARK:- Camera Setup
    func setupAndStartCaptureSession() {
        DispatchQueue.global(qos: .userInitiated).async{
            //start configuration
            self.captureSession.beginConfiguration()
            self.captureSession.canAddInput(self.screenInput)
            self.captureSession.addInput(self.screenInput)
            let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
            self.captureOutput.setSampleBufferDelegate(self, queue: videoQueue)
            self.captureOutput.connections.first?.videoOrientation = .portrait
            self.captureSession.addOutput(self.captureOutput)
            
            //commit configuration
            self.captureSession.commitConfiguration()
            //start running it
            self.captureSession.startRunning()
        }
    }
    //MARK:- Metal
    func setupMetal() {
        //fetch the default gpu of the device (only one on iOS devices)
        
        //tell our MTKView which gpu to use
        mtkView.device = metalDevice
        
        //tell our MTKView to use explicit drawing meaning we have to call .draw() on it
        mtkView.isPaused = true
        mtkView.enableSetNeedsDisplay = false
        
        //create a command queue to be able to send down instructions to the GPU
        metalCommandQueue = metalDevice.makeCommandQueue()
        
        //conform to our MTKView's delegate
        mtkView.delegate = self
        
        //let it's drawable texture be writen to
        mtkView.framebufferOnly = false
    }
    
    //MARK:- Core Image
    func setupCoreImage(){
        ciContext = CIContext(mtlDevice: metalDevice)
    }
    
    
    func applyFilters(inputImage image: CIImage) -> CIImage? {
        
        return image
    }

}

extension ScreenViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // try and get a CVImageBuffer out of the sample buffer
        guard let cvBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // get a CIImage out of the CVImageBuffer
        let ciImage = CIImage(cvImageBuffer: cvBuffer)
        
        // filter it
        //guard let filteredCIImage = applyFilters(inputImage: ciImage) else {
        //    return
        //}
        
        self.currentCIImage = ciImage
        
        mtkView.draw()
    }
}

extension ScreenViewController : MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // tells us the drawable's size has changed
    }
    
    func draw(in view: MTKView) {
        //create command buffer for ciContext to use to encode it's rendering instructions to our GPU
        guard let commandBuffer = metalCommandQueue.makeCommandBuffer() else {
            return
        }
        
        //make sure we actually have a ciImage to work with
        guard let ciImage = currentCIImage else {
            return
        }
        
        //make sure the current drawable object for this metal view is available (it's not in use by the previous draw cycle)
        guard let currentDrawable = view.currentDrawable else {
            return
        }

        //make sure frame is centered on screen
        let heightOfciImage = ciImage.extent.height
        let heightOfDrawable = view.drawableSize.height
        let yOffsetFromBottom = (heightOfDrawable - heightOfciImage)/2
        
        //render into the metal texture
        self.ciContext.render(ciImage,
                              to: currentDrawable.texture,
                   commandBuffer: commandBuffer,
                          bounds: CGRect(origin: CGPoint(x: 0, y: -yOffsetFromBottom), size: view.drawableSize),
                      colorSpace: CGColorSpaceCreateDeviceRGB())
        
        //register where to draw the instructions in the command buffer once it executes
        commandBuffer.present(currentDrawable)
        //commit the command to the queue so it executes
        commandBuffer.commit()
    }
}

