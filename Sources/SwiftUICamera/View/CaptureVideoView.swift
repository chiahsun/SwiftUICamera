import SwiftUI
import Combine
import AVFoundation

public class CaptureVideoModel: ObservableObject {
    @Published public var pixelBuffer: CVPixelBuffer?
}

public struct CaptureVideoView: View {
    @StateObject var cameraModel = CameraModel()
    @State var cancellables: Set<AnyCancellable> = []
    @State var videoImage: UIImage?
    @ObservedObject public var model = CaptureVideoModel()
    
    let cameraPreviewParam: CameraPreviewParam

    var enableSampleVideoView = false
    public init(enableSampleVideoView: Bool = false, cameraPreviewParam: CameraPreviewParam = CameraPreviewParam.makeParam()) {
        self.enableSampleVideoView = enableSampleVideoView
        self.cameraPreviewParam = cameraPreviewParam
    }
    
    var sampleVideoView: AnyView {
        if let videoImage = videoImage {
            return AnyView(Image(uiImage: videoImage)
                .byProportion(proportion: 0.2, x: 4, y: 4))
        } else {
            return AnyView(Image(systemName: "circle").frame(width: 0))
        }
    }

    public var body: some View {
        ZStack {
            CameraPreview(session: cameraModel.session, param: self.cameraPreviewParam)
            .onAppear {
                print("CameraPreview onAppear")
                cameraModel.requestAccess()

                // TODO: handle resume
                let cameraFeed = CameraFeedManager()
                cameraModel.setCameraFeed(cameraFeed: cameraFeed)
                cameraFeed.$pixelBuffer.sink(receiveValue: { pixelBuffer in
                    guard let pixelBuffer = pixelBuffer else { return }
                    videoImage = pixelBuffer.toUIImage()
                    DispatchQueue.main.async {
                        model.pixelBuffer = pixelBuffer
                    }
                }).store(in: &cancellables)

                cameraModel.$permissionGranted.sink { receiveValue in
                    if receiveValue {
                        cameraModel.startSession()
                    }
                }.store(in: &cancellables)
            }
            .onDisappear {
                print("CameraPreview onDisappear")
            }
            // Debug use            
            /*GeometryReader { metrics in
                Rectangle().position(x: metrics.size.width/2, y: metrics.size.height/2)
                    .frame(width: metrics.size.width, height: metrics.size.height)
                     .foregroundColor(Color.red.opacity(0.4))
                     .border(Color.red.opacity(0.8), width: 4)

            }*/
            if (enableSampleVideoView) {
                sampleVideoView
            }
        }
    }
}

struct CaptureVideoView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureVideoView()
    }
}
