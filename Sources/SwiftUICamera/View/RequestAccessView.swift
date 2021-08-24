import SwiftUI

@available(iOS 13, *)
public struct RequestAccessView: View {
    @StateObject var model = CameraModel()

    public init() {}

    public var body: some View {
        ZStack {
            CameraPreview(session: model.session)
            // https://developer.apple.com/documentation/swiftui/view/onappear(perform:)
            .onAppear {
                model.requestAccess()
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
    @available(iOS 13.0.0, *)
    static var previews: some View {
        RequestAccessView()
    }
}
