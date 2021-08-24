import SwiftUI
import Combine

public struct CaptureAndPreview: View {
    @State var toPhotoPreviewPhotoData: Data?
    @StateObject var previewModel = PreviewModel()
    @State var cancellables: Set<AnyCancellable> = []

    @Binding var resultPhotoData: Data?
    
    public init(resultPhotoData: Binding<Data?>) {
        self._resultPhotoData = resultPhotoData
    }
    
    public var body: some View {
        ZStack {
            if toPhotoPreviewPhotoData == nil {
                CapturePhotoView(toPhotoPreviewPhotoData: $toPhotoPreviewPhotoData)
            } else {
                PhotoPreview(photoData: toPhotoPreviewPhotoData, model: previewModel, resultPhotoData: $resultPhotoData)
                    .onAppear {
                        previewModel.result = .tbd
                        previewModel.$result.sink(receiveValue: { result in
                            switch result {
                            case .again:
                                toPhotoPreviewPhotoData = nil
                            case .ok:
                                print("OK")
                            default:
                                break
                            }
                        }).store(in: &cancellables)
                    }
            }
            Text("Data: " + "\(String(describing: toPhotoPreviewPhotoData))")
                .foregroundColor(.red)
        }
    }
}

struct CaptureAndPreview_Previews: PreviewProvider {
    @State static var resultPhotoData: Data?
    static var previews: some View {
        CaptureAndPreview(resultPhotoData: $resultPhotoData)
    }
}
