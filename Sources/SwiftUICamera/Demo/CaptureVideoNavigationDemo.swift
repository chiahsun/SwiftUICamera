import SwiftUI
import Combine
import AVFoundation

struct CaptureVideoNavigationDemo: View {
    @State var cancellables: Set<AnyCancellable> = []
    @State var videoImage: UIImage?

    var videoView: some View {
        let cameraPreviewParam = CameraPreviewParam.makeParam(gravity: AVLayerVideoGravity.resizeAspectFill)
        let view = CaptureVideoView(enableSampleVideoView: true, cameraPreviewParam: cameraPreviewParam, debug: true)
        return view.onAppear(perform: {
            view.model.$pixelBuffer.sink(receiveValue: { pixelBuffer in
                guard let pixelBuffer = pixelBuffer else { return }
                videoImage = pixelBuffer.toUIImage()
            }).store(in: &cancellables)
        }).onDisappear(perform: {
            cancellables.removeAll()
            videoImage = nil
        })
    }

    var capturedVideoView: some View {
        if let videoImage = videoImage {
            return AnyView(Image(uiImage: videoImage).byProportion(proportion: 0.2, x: 4, y: 4))
        }
        return AnyView(EmptyView())
    }

    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    videoView
                    NavigationLink(destination: Text("Hello World")) {
                        Text("Click me!").font(.largeTitle)
                    }
                    capturedVideoView
                }
            }
        }
    }
}

struct CaptureVideoNavigationDemo_Previews: PreviewProvider {
    static var previews: some View {
        CaptureVideoNavigationDemo()
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            .previewDisplayName("iPhone 11")
    }
}
