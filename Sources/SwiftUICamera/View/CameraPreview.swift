import SwiftUI
import AVFoundation

// https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/setting_up_a_capture_session
class PreviewView: UIView {
    override class var layerClass: AnyClass {
        // https://developer.apple.com/documentation/avfoundation/avcapturevideopreviewlayer
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        // https://developer.apple.com/documentation/uikit/uiview/1622436-layer
        // The actual class of the object is determined by the value returned in the layerClass property.
        return layer as! AVCaptureVideoPreviewLayer
    }
}

@available(iOS 13.0, *)
struct CameraPreview: UIViewRepresentable {
    typealias UIViewType = PreviewView
    
    let session: AVCaptureSession
        
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
    }
}

struct CameraPreview_Previews: PreviewProvider {
    @available(iOS 13.0, *)
    static var previews: some View {
        CameraPreview(session: AVCaptureSession())
    }
}
