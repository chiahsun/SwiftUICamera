import XCTest
// @testable import SwiftUICamera
import SwiftUI
import SwiftUICamera

final class SwiftUICameraTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        // XCTAssertEqual(SwiftUICamera().text, "Hello, World!")
    }
}

    
struct CapturePhotoView_Previews: PreviewProvider {
    @State static var toPhotoPreviewPhotoData: Data?
        
    static var previews: some View {
        CapturePhotoView(toPhotoPreviewPhotoData: $toPhotoPreviewPhotoData)
    }
}

struct PhotoPreview_Previews: PreviewProvider {
    @StateObject static var model = PreviewModel()
    @State static var resultPhotoData: Data?
    static var previews: some View {
        PhotoPreview(photoData: nil, model: model, resultPhotoData: $resultPhotoData)
        // Text("Hello")
    }
}
