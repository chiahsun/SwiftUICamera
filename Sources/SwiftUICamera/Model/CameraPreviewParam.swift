import Foundation
import UIKit
import AVFoundation

public struct CameraPreviewParam {
    let color: UIColor
    let preset: AVCaptureSession.Preset
    let gravity: AVLayerVideoGravity
}

extension CameraPreviewParam {
    public static func makeParam(color: UIColor = .black, preset: AVCaptureSession.Preset = .high, gravity: AVLayerVideoGravity = .resizeAspectFill) -> CameraPreviewParam {
        return CameraPreviewParam(
            color: color,
            preset: preset,
            // 1. https://stackoverflow.com/questions/42609861/how-can-i-set-the-correct-camera-image-size-on-a-preview-layer
            // 2. See tensorflow lite iOS demo on object detection
            gravity: gravity
        )
    }
}
