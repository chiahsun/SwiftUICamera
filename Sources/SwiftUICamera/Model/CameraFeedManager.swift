import Foundation
import AVFoundation

class CameraFeedManager: NSObject, ObservableObject {
    @Published var count = 0
    @Published var pixelBuffer: CVPixelBuffer?
}

extension CameraFeedManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)

        // guard let pixelBuffer = pixelBuffer else { return }
        self.pixelBuffer = pixelBuffer
        count += 1
    }
}
