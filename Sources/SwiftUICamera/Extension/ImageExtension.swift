import Foundation
import SwiftUI

extension Image {
    // proportion: (0, 1]
    public func byProportion(proportion: CGFloat, x: Int, y: Int) -> some View {
        GeometryReader { metrics in
            self.resizable()
                // .aspectRatio(contentMode: .fit)
                .aspectRatio(contentMode: .fill)
                .frame(width: metrics.size.width * proportion, height: metrics.size.height * proportion)
                .position(x: metrics.size.width * (CGFloat(x) + 0.5) * proportion, y: metrics.size.height * (CGFloat(y) + 0.5) * proportion)
        }
    }
}
