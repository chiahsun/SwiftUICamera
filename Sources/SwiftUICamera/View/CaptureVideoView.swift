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
    @ObservedObject public var model = CaptureVideoModel() // Need to use @ObservedObject to propagate observed change. No the usage in // https://www.hackingwithswift.com/quick-start/swiftui/whats-the-difference-between-observedobject-state-and-environmentobject
    // @StateObject public var model = CaptureVideoModel()

    let cameraPreviewParam: CameraPreviewParam

    var enableSampleVideoView = false
    var debug = false

    public init(enableSampleVideoView: Bool = false, cameraPreviewParam: CameraPreviewParam = CameraPreviewParam.makeParam(), debug: Bool = false) {
        self.enableSampleVideoView = enableSampleVideoView
        self.cameraPreviewParam = cameraPreviewParam
        self.debug = debug
    }

    var sampleVideoView: AnyView {
        if let videoImage = videoImage, enableSampleVideoView {
            return AnyView(Image(uiImage: videoImage)
                .byProportion(proportion: 0.2, x: 4, y: 4))
        } else {
            return AnyView(EmptyView())
        }
    }

    var cameraPreview: some View {
        CameraPreview(session: cameraModel.session, param: self.cameraPreviewParam)
        .onAppear {
            if debug {
                print("CameraPreview onAppear +++ in cancellable \(cancellables.count)")
            }
            cameraModel.requestAccess()

            let cameraFeed = CameraFeedManager()
            cameraModel.setCameraFeed(cameraFeed: cameraFeed)
            cameraFeed.$pixelBuffer.sink(receiveValue: { pixelBuffer in
                guard let pixelBuffer = pixelBuffer else { return }
                videoImage = pixelBuffer.toUIImage()
                DispatchQueue.main.async {
                    model.pixelBuffer = pixelBuffer
                }
            }).store(in: &cancellables)

            // https://stackoverflow.com/questions/64286306/how-to-stop-storing-anycancellable-after-swift-combine-sink-has-received-at-leas
            cameraModel.$permissionGranted.first().sink { receiveValue in
                if debug {
                    print("$permissionGranted.sink called") // This get called multiple times if nav in and out, nav in and out previously
                }
                if receiveValue {
                    cameraModel.startSession()
                }
            }.store(in: &cancellables)

            if debug {
                print("CameraPreview onAppear --- in cancellable \(cancellables.count)")
            }
        }
        .onDisappear {
            videoImage = nil
            cameraModel.stopSession()
            // We need to remove all sinks when disappear; otherwise, previous sinks would still exist
            cancellables.removeAll()
            if debug {
                print("CameraPreview onDisappear in cancellable \(cancellables.count)")
            }
        }
    }

    public var body: some View {
        // This ZStack + sampleVideoView would cause CameraPreview call appear when navigating to another view
        ZStack {
            cameraPreview

            // TODO: Add button to stop seesion and resume session
            // Debug use            
            /*GeometryReader { metrics in
                Rectangle().position(x: metrics.size.width/2, y: metrics.size.height/2)
                    .frame(width: metrics.size.width, height: metrics.size.height)
                     .foregroundColor(Color.red.opacity(0.4))
                     .border(Color.red.opacity(0.8), width: 4)

            }*/

            // TODO: This cause cameraPreview.onAppear called when navigating to another view. Any workaround for ZStack?
            sampleVideoView
        }
    }
}

struct CaptureVideoView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureVideoView()
    }
}
