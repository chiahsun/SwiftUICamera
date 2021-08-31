import SwiftUI
import Combine

public struct CapturePhotoView: View {
    @StateObject var model = CameraModel()
    @State var cancellables: Set<AnyCancellable> = []
    @State var hideButton = false
    @State var numPhotoTaken = 0
    @State var captureStage: PhotoCaptureStage = .willBeginCapture
    @Binding var toPhotoPreviewPhotoData: Data?
    
    public init(toPhotoPreviewPhotoData: Binding<Data?>) {
        self._toPhotoPreviewPhotoData = toPhotoPreviewPhotoData
    }
    
    public var body: some View {
        ZStack {
            CameraPreview(session: model.session)
            .onAppear {
                print("CameraPreview onAppear")
                print("binding: \($toPhotoPreviewPhotoData)")
                model.requestAccess()
                model.$permissionGranted.sink { receiveValue in
                    if receiveValue {
                        model.startSession()
                    }
                }.store(in: &cancellables)
            }
            .onDisappear {
                print("CameraPreview onDisappear")
            }
            
            VStack {
                Text(String("\(captureStage)"))
                Text(String(numPhotoTaken))
                Spacer()
            }
            .padding()
            .foregroundColor(.white)
            .font(.largeTitle)

            // TODO: show UI is the model is capturing
            // TODO: show result image after capturing photo
            // TODO: change UI automatically(to another view) (Do this in another demo, not this demo)
            if (model.isSessionRunning && !hideButton) {
                Button(action: {
                    hideButton = true

                    let photoCaptureProcessor = PhotoCaptureProcessor()
                    photoCaptureProcessor.$captureDone.sink(receiveValue: { capturingDone in
                        if (capturingDone) {
                            hideButton = false
                            numPhotoTaken += 1
                        }
                    }).store(in: &cancellables)
                    photoCaptureProcessor.$stage.sink(receiveValue: { stage in
                        captureStage = stage
                    }).store(in: &cancellables)
                    photoCaptureProcessor.$photoData.sink(receiveValue: { photoData in
                        if let photoData = photoData {
                            print("Photo data is ready")
                            toPhotoPreviewPhotoData = photoData
                        } else {
                            // TODO: show error and let user capture photo again
                            print("Photo data is nil")
                        }
                    }).store(in: &cancellables)
              
                    model.capturePhoto(photoCaptureProcessor)
                }, label: {
                    Image(systemName: "camera.aperture")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 130)
                        .foregroundColor(.white)
                })
            }
        }
    }
}

struct CapturePhotoView_Previews: PreviewProvider {
    @State static var toPhotoPreviewPhotoData: Data?
    
    static var previews: some View {
        CapturePhotoView(toPhotoPreviewPhotoData: $toPhotoPreviewPhotoData)
    }
}
