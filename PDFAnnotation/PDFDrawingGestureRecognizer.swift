//
//  PDFDrawingGestureRecognizer.swift
//  PDFAnnotation
//
//  Created by Mohammed Gomaa on 6/2/20.
//  Copyright © 2020 Mohammed Gomaa. All rights reserved.
//

import Foundation
import PDFKit

class PDFDrawingGestureRecognizer: UIGestureRecognizer {
    
    weak var pdfView: PDFView!
    private var lastPoint = CGPoint()
    var currentAnnotation : PDFAnnotation?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first,
            let numberOfTouches = event?.allTouches?.count, pdfView.document != nil,
            numberOfTouches == 1 {
            state = .began
            let position = touch.location(in: pdfView)
            let convertedPoint = pdfView.convert(position, to: pdfView.currentPage!)
            lastPoint = convertedPoint
        } else {
            state = .failed
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .changed
        guard let position = touches.first?.location(in: pdfView) else { return }
        let convertedPoint = pdfView.convert(position, to: pdfView.currentPage!)
        lastPoint = convertedPoint
        
        guard let annotation = currentAnnotation else {
            return
        }
        let initialBounds = annotation.bounds
        // Set the center of the annotation to the spot of our finger
        annotation.bounds = CGRect(x: lastPoint.x - (initialBounds.width / 2), y: lastPoint.y - (initialBounds.height / 2), width: initialBounds.width, height: initialBounds.height)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let position = touches.first?.location(in: pdfView) else {
            state = .ended
            return
        }
        let convertedPoint = pdfView.convert(position, to: pdfView.currentPage!)
        let path = UIBezierPath()
        path.move(to: lastPoint)
        path.addLine(to: convertedPoint)
        currentAnnotation?.add(path)
        currentAnnotation = nil
        state = .ended
    }
}
