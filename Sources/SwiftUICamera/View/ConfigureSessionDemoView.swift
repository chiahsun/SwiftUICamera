import SwiftUI
import Combine

@available(iOS 13, *)
public struct ConfigureSessionDemoView: View {
    @StateObject var model = CameraModel()
    @State var cancellable: Cancellable?

    var previewMode = false
    
    public init(previewMode: Bool = false) {
        self.previewMode = previewMode
    }
    
    var configurationSessionStatusString: String {
        return model.configureSessionStatus.rawValue
    }
    
    public var body: some View {
        ZStack {
            CameraPreview(session: model.session)
            .onAppear {
                if (!previewMode) {
                    model.requestAccess()
                }
                cancellable = model.$permissionGranted.sink { receiveValue in
                    if receiveValue {
                        model.startSession()
                    }
                }
            }
            
            VStack {
                HStack {
                    Text(configurationSessionStatusString)
                        .foregroundColor(.red)
                        .font(.largeTitle)
                    Spacer()
                    Image(systemName: model.permissionGranted ? "camera.metering.center.weighted" : "camera.metering.unknown")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, alignment: .center)
                        .foregroundColor(.red)
                }
             
                Image(systemName: model.isSessionRunning ? "video" : "video.slash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, alignment: .center)
                    .foregroundColor(.red)
                Spacer()
            }
            .padding()
        }
    }
}
struct ConfigureSessionDemoView_Previews: PreviewProvider {
    @available(iOS 13, *)
    static var previews: some View {
        ConfigureSessionDemoView(previewMode: true)
    }
}
