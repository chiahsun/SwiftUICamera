import SwiftUI
import AVFoundation

@available(iOS 13, *)
public struct RequestAccessDemoView: View {
    @StateObject var model = CameraModel()

    let cameraPreviewParam: CameraPreviewParam

    // This flag is used to disable requesting access when preview since we cannot and camera permission in a Swift pacakge
    var previewMode = false
    public init(previewMode: Bool = false, cameraPreviewParam: CameraPreviewParam = CameraPreviewParam.makeParam()) {
        self.previewMode = previewMode
        self.cameraPreviewParam = cameraPreviewParam
    }

    public var body: some View {
        ZStack {
            CameraPreview(session: model.session, param: self.cameraPreviewParam)
            // https://developer.apple.com/documentation/swiftui/view/onappear(perform:)
            .onAppear {
                if (!previewMode) {
                    model.requestAccess()
                }
            }
            
            Image(systemName: model.permissionGranted ? "camera.metering.center.weighted" : "camera.metering.unknown")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, alignment: .center)
                .foregroundColor(.red)
        }
    }
}

struct RequestAccessView_Previews: PreviewProvider {
    @available(iOS 13.0, *)
    static var previews: some View {
        RequestAccessDemoView(previewMode: true)
    }
}
