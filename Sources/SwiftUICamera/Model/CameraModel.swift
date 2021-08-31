import Foundation
import AVFoundation

enum ConfigureSessionStatus: String {
    case unknown, failure, success
}

@available(iOS 13, *)
final class CameraModel: ObservableObject {
    // Call startSession after granted changes to true
    @Published var permissionGranted = false
    // Take photo after isSessionRunning turns true
    @Published var isSessionRunning = false

    @Published var configureSessionStatus: ConfigureSessionStatus = .unknown

    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!

    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "session")
    
    private var cameraFeedManager: AVCaptureVideoDataOutputSampleBufferDelegate?

    private var keyValueObservations = [NSKeyValueObservation]()
    
    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    private var photoOutput = AVCapturePhotoOutput()

    private var videoDataOutput = AVCaptureVideoDataOutput()

    func requestAccess() {
        // https://developer.apple.com/documentation/avfoundation/avcapturedevice/1624613-authorizationstatus
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.permissionGranted = true
        case .notDetermined:
            // The completion handler is called on an arbitrary dispatch queue. It is the client's responsibility to ensure that any UIKit-related updates are called on the main queue or main thread as a result.
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                    DispatchQueue.main.async {
                        self.permissionGranted = granted
                    }
                }
            )
        default:
            self.permissionGranted = false
        }
    }
    
    func startSession() {
        sessionQueue.async {
            self.configureSession()
            // https://developer.apple.com/documentation/avfoundation/avcapturesession/1388185-startrunning
            // The startRunning() method is a blocking call which can take some time, therefore you should perform session setup on a serial queue so that the main queue isn't blocked (which keeps the UI responsive).
            self.session.startRunning()
        }
    }
    
    // https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/setting_up_a_capture_session
    private func configureSession() {
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!) else {
            updateConfigureSessionStatus(.failure)
            return
        }
        
        // Call beginConfiguration() before changing a session’s inputs or outputs, and call commitConfiguration() after making changes.
        session.beginConfiguration()
        defer {
            session.commitConfiguration()
        }
        
        // TODO: Only add this when changing camera
        // https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/avcam_building_a_camera_app#//apple_ref/doc/uid/DTS40010112
        // Remove the existing device input first, because AVCaptureSession doesn't support
        // simultaneous use of the rear and front cameras.
        // self.session.removeInput(self.videoDeviceInput)
        
        guard addVideoInput(videoDeviceInput: videoDeviceInput) else { return }
        guard addVideoOutput() else { return }
        guard addPhotoOutput() else { return }
        
        // https://developer.apple.com/documentation/avfoundation/avcapturesession/1388133-isrunning
        // You can observe the value of this property using Key-value observing.
        let isRunningObservation = session.observe(\.isRunning, options: .new) { _, change in
            DispatchQueue.main.async {
                guard let newValue = change.newValue else { return }
                
                self.isSessionRunning = newValue
            }
        }
        keyValueObservations.append(isRunningObservation)
        updateConfigureSessionStatus(.success)
    }
    
    private func addVideoInput(videoDeviceInput: AVCaptureDeviceInput!) -> Bool {
        // https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/capturing_still_and_live_photos
        guard session.canAddInput(videoDeviceInput) else {
            print("Fail to configure session")
            updateConfigureSessionStatus(.failure)
            return false
        }
        session.addInput(videoDeviceInput)
        self.videoDeviceInput = videoDeviceInput
        return true
    }
    
    private func addVideoOutput() -> Bool {
        if cameraFeedManager == nil {
            // This means we don't need to do anything, let it continue next steps
            return true
        }

        let bufferQueue = DispatchQueue(label: "bufferQueue")
        videoDataOutput.setSampleBufferDelegate(cameraFeedManager, queue:  bufferQueue)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        // TODO: check format
        videoDataOutput.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): kCMPixelFormat_32BGRA]

        guard session.canAddOutput(videoDataOutput) else { return false }

        session.addOutput(videoDataOutput)
        videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
        return true
    }

    private func addPhotoOutput() -> Bool {
        let photoOutput = AVCapturePhotoOutput()
        photoOutput.isHighResolutionCaptureEnabled = true

        guard session.canAddOutput(photoOutput) else { return false }
        
        self.photoOutput = photoOutput
        session.sessionPreset = .photo
        session.addOutput(photoOutput)
        return true
    }
    
    func setCameraFeed(cameraFeed: AVCaptureVideoDataOutputSampleBufferDelegate) {
        self.cameraFeedManager = cameraFeed
    }

    // See: https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/avcam_building_a_camera_app#//apple_ref/doc/uid/DTS40010112 Capture a Photo
    func capturePhoto(_ photoCaptureProcessor: PhotoCaptureProcessor) {
        sessionQueue.async {
            self.capturePhotoInner(photoCaptureProcessor)
        }
    }
    

    private func capturePhotoInner(_ photoCaptureProcessor: PhotoCaptureProcessor) {
        if let photoOutputConnection = self.photoOutput.connection(with: .video) {
            // TODO
            //  photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            photoOutputConnection.videoOrientation = .portrait
        } // TODO: handle nil case
        
        // https://developer.apple.com/documentation/avfoundation/avcapturephotocapturedelegate
        // You must use a unique AVCapturePhotoSettings object for each capture request.
        // https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/capturing_still_and_live_photos
        let photoSettings: AVCapturePhotoSettings

        // Capture HEIF photos when supported. Enable auto-flash and high-resolution photos.
        if  self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            photoSettings = AVCapturePhotoSettings()
        }

        if self.videoDeviceInput.device.isFlashAvailable {
            photoSettings.flashMode = .auto
        }
        // settings.highResolutionPhotoEnabled may not be YES unless self.highResolutionCaptureEnabled is YES'
        // photoSettings.isHighResolutionPhotoEnabled = true
        
        if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
        }

        // photoSettings.photoQualityPrioritization = .quality // TODO
        photoSettings.photoQualityPrioritization = .speed

        // Important: We need to add inProgressPhotoCaptureDelegates for strong reference; otherwise, the callback for delegation won't be called
        // We release the reference after the callback for photoOutput(output:didFinishCaptureFor: error)
        self.inProgressPhotoCaptureDelegates[photoSettings.uniqueID] = photoCaptureProcessor
        photoCaptureProcessor.cleanUpHandler =  {
            self.sessionQueue.async {
                self.inProgressPhotoCaptureDelegates[photoSettings.uniqueID] = nil
            }
        }
        self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
    }

    // Publishing changes from background threads is not allowed; make sure to publish values from the main thread
    private func updateConfigureSessionStatus(_ status: ConfigureSessionStatus) {
        DispatchQueue.main.async {
            self.configureSessionStatus = status
        }
    }
    
}
