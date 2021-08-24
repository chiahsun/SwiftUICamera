import Foundation

enum PhotoPreviewResult {
    case tbd, ok, again
}

public final class PreviewModel: ObservableObject {
    @Published var result = PhotoPreviewResult.tbd
    public init() { }
}
