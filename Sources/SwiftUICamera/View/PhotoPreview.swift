import SwiftUI

struct ControlButton: View {
    let systemImageName: String
    let action: () -> Void
    let frameSize: CGFloat? = 75
    var body: some View {
        Button(action: action, label: {
            Image(systemName: systemImageName)
                .resizable()
                .foregroundColor(.blue)
                .aspectRatio(contentMode: .fit)
                .frame(width: frameSize, height: frameSize)
                .padding()
        })
    }
}

public struct PhotoPreview: View {
    let photoData: Data?
    let model: PreviewModel
    @Binding var resultPhotoData: Data?
    
    public init (photoData: Data?, model: PreviewModel, resultPhotoData: Binding<Data?>) {
        self.photoData = photoData
        self.model = model
        self._resultPhotoData = resultPhotoData
    }
    
    
    var uiImage: UIImage? {
        guard let data = photoData else { return nil }
        let photo = Photo(data: data)
        return photo.resizeImage(targetWidth: 300)
    }
    
    var image: Image {
        // return Image("icybay")
        if let uiImage = uiImage {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "exclamationmark.circle")
                .resizable()
        }
    }
    
    public var body: some View {
        VStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.red)
                // .padding()
            HStack(spacing: 50) {
                ControlButton(systemImageName: "goforward", action: {
                    model.result = .again
                })
                ControlButton(systemImageName: "checkmark", action: {
                    resultPhotoData = photoData
                    model.result = .ok
                })
            }
           
        }
    }
}


struct PhotoPreview_Previews: PreviewProvider {
    @StateObject static var model = PreviewModel()
    @State static var resultPhotoData: Data?
    static var previews: some View {
        PhotoPreview(photoData: nil, model: model, resultPhotoData: $resultPhotoData)
    }
}
