import Foundation
import AVFoundation

enum PhotoCaptureError: String {
    case none, captureError
}

enum PhotoCaptureStage: String {
    case willBeginCapture,
         willCapturePhoto,
         didCapturePhoto,
         didFinishProcessingPhoto,
         didFinishCapture
}

// https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/capturing_still_and_live_photos/tracking_photo_capture_progress

// https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/capturing_still_and_live_photos Handle Capture Results

@available(iOS 13, *)
class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate, ObservableObject {
    @Published var error: PhotoCaptureError = .none
    @Published var stage: PhotoCaptureStage = .willBeginCapture
    
    // This value is valid after stage .willBeginCapture
    @Published var maxPhotoProcessingTime: CMTime = CMTimeMake(value: 0, timescale: 1)
    @Published var captureDone = false
    
    typealias cleanUpHandlerType = () -> Void
    var cleanUpHandler: cleanUpHandlerType?
    
    @Published var photoData: Data?

    private let debug = false

    override init() {
        if debug {
            print("Init a PhotoCaptureProcessor")
        }
    }
    
    deinit {
        if debug {
            print("Deinit a PhotoCaptureProcessor")
        }
    }
    
    // 1. Notifies the delegate that the capture output has resolved settings and will soon begin its capture process.
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // https://developer.apple.com/documentation/avfoundation/avcaptureresolvedphotosettings/3183001-photoprocessingtimerange?language=objc
        // The .start field of the CMTimeRange is zero-based. In other words, if photoProcessingTimeRange.start is equal to .5 seconds, then the minimum processing time for this photo is .5 seconds. The .start field plus the .duration field of the CMTimeRange indicate the max expected processing time for this photo.
        setMaxPhotoProcessingTime(resolvedSettings.photoProcessingTimeRange.start + resolvedSettings.photoProcessingTimeRange.duration)
        setStage(.willBeginCapture)
    }
    
    // 2. Notifies the delegate that photo capture is about to occur.
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        setStage(.willCapturePhoto)
    }
    
    // 3.
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        setStage(.didCapturePhoto)
    }
    
    // https://developer.apple.com/documentation/avfoundation/avcapturephotocapturedelegate
    // 4. Your delegate must implement the photoOutput(_:didFinishProcessingPhoto:error:) method
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error: fail to capture photo \(error)")
            setError(err: .captureError)
        } else {
            DispatchQueue.main.async {
                self.photoData = photo.fileDataRepresentation()
            }
        }
   
        setStage(.didFinishProcessingPhoto)
        setCaptureDone()
    }
    
    // 5. Use this time to clean up any resources you’ve allocated that relate to this capture request.
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        setStage(.didFinishCapture)
        self.cleanUpHandler?()
    }
    
    private func setStage(_ stage: PhotoCaptureStage) {
        if debug {
            print("Stage \(stage)")
        }
        DispatchQueue.main.async {
            self.stage = stage
        }
    }
    
    private func setError(err: PhotoCaptureError) {
        DispatchQueue.main.async {
            self.error = err
        }
    }
    
    private func setCaptureDone() {
        DispatchQueue.main.async {
            self.captureDone = true
        }
    }
    
    private func setMaxPhotoProcessingTime(_ maxPhotoProcessingTime: CMTime) {
        DispatchQueue.main.async {
            self.maxPhotoProcessingTime = maxPhotoProcessingTime
        }
    }
}
