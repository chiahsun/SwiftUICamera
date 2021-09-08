import SwiftUI
import Combine

public struct CaptureVideoDemo: View {
    @State var count: Int = 0
    @State var cancellables: Set<AnyCancellable> = []

    public init() { }
    
    var captureVideoView: some View {
        let view = CaptureVideoView(enableSampleVideoView: true)
        return view.onAppear(perform: {
            view.model.$pixelBuffer.sink(receiveValue: { _ in
                count += 1
            }).store(in: &cancellables)
        })
    }

    public var body: some View {
        VStack {
            captureVideoView
            Text("\(count)").foregroundColor(.red)
        }
    }
}

struct CaptureVideoDemo_Previews: PreviewProvider {
    static var previews: some View {
        CaptureVideoDemo()
    }
}
