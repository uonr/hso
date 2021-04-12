//
//  GLSLFilter.swift
//  metal vs glsl kernel
//
//  Created by Dan Pashchenko on 2/8/18.
//  Copyright © 2018 https://ios-engineer.com. All rights reserved.
//
import Foundation
import CoreImage

class GLSLFilter: CIFilter {
    
    var inputImage: CIImage?
    private let kernel = CIKernel(source: """
kernel vec4 do_nothing(sampler image) {
    vec2 dc = destCoord();
    return sample(image, samplerTransform(image, dc));
}
""")
    
    override var outputImage: CIImage? {
        guard let inputImage = inputImage else { abort() }
        print("hello")
        
        let inputExtent = inputImage.extent
        
        let roiCallback: CIKernelROICallback = { _, rect -> CGRect in  // (4)
            return rect
        }
        
        return self.kernel?.apply(extent: inputExtent,
                                 roiCallback: roiCallback,
                                 arguments: [inputImage])
    }
}
