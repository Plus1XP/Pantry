//
//  String.swift
//  Pantry
//
//  Created by nabbit on 01/11/2023.
//

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

extension String {
    var isBlank: Bool { allSatisfy({ $0.isWhitespace }) }
    
    func onlyEmoji() -> String {
        return self.filter({$0.isEmoji})
    }

    func ToImage(fontSize:CGFloat = 40, bgColor:UIColor = UIColor.clear, imageSize:CGSize? = nil) -> UIImage?
    {
        if !self.isBlank && self.first?.isEmoji ?? false {
            let font = UIFont.systemFont(ofSize: fontSize) // you can change your font size here
            let attributes = [NSAttributedString.Key.font: font]
            let imageSize = imageSize ?? self.size(withAttributes: attributes)
            
            UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
            bgColor.set()
            let rect = CGRect(origin: CGPoint(), size: imageSize) // set rect size
            UIRectFill(rect)
            self.draw(at: CGPoint.zero, withAttributes: [.font: font]) // draw text within rect
            let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
            UIGraphicsEndImageContext() //  end image context
            return image
        } else {
            return UIImage(systemName: "questionmark.square") ?? UIImage()
        }
    }
}
