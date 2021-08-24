import Foundation
import UIKit

struct Photo {
    var data: Data
    
    func resizeImage(targetWidth: CGFloat) -> UIImage? {
        guard let image = UIImage(data: data) else { return nil }
        
        let orignalSize = image.size
        let originalAspectRatio = orignalSize.height / orignalSize.width
        let targetSize = CGSize(width: targetWidth, height: targetWidth * originalAspectRatio)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resultImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        return resultImage
    }
}
