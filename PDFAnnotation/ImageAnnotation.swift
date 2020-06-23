//
//  ImageAnnotation.swift
//  PDFAnnotation
//
//  Created by Mohammed Gomaa on 6/2/20.
//  Copyright © 2020 Mohammed Gomaa. All rights reserved.
//

import PDFKit
import UIKit

class ImageAnnotation: PDFAnnotation {
    let image: UIImage
    
    init(image: UIImage, bounds: CGRect, properties: [AnyHashable: Any]?) {
        self.image = image
        super.init(
            bounds: bounds,
            forType: PDFAnnotationSubtype.stamp,
            withProperties: properties
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
        guard let cgImage = self.image.cgImage else { return }
        context.draw(cgImage, in: bounds)

//        context.saveGState()
//        context.translateBy(x: 0, y: bounds.height)
//        context.concatenate(CGAffineTransform.init(scaleX: 1, y: -1))
//        context.draw(cgImage, in: bounds)
//        context.restoreGState()
        
//        UIGraphicsPushContext(context)
//        context.saveGState()
//        // context flipping
//        context.translateBy(x: 0.0, y: bounds.height)
////        context.scaleBy(x: 1.0, y: -1.0)
//        context.rotate(by: CGFloat.pi)
//
//        // text drawing
//        context.draw(cgImage, in: bounds)
//        context.restoreGState()
//        UIGraphicsPopContext()
    }
}

extension CGRect {
    func adjust(inside bigRect: CGRect) -> CGRect {
        var dx: CGFloat = 0
        var dy: CGFloat = 0
        if origin.x < 0 {
            dx = -origin.x
        }
        if maxX > bigRect.maxX {
            dx = bigRect.maxX - maxX
        }
        if origin.y < 0 {
            dy = -origin.y
        }
        if maxY > bigRect.maxY {
            dy = bigRect.maxY - maxY
        }
        return offsetBy(dx: dx, dy: dy)
    }
}
