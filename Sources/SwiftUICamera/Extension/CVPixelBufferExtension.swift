import Foundation
import AVFoundation
import SwiftUI

extension CVPixelBuffer {
    public func toUIImage() -> UIImage {
        let ciimage = CIImage(cvPixelBuffer: self)
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciimage, from: ciimage.extent)!
        return UIImage(cgImage: cgImage)
    }
}
