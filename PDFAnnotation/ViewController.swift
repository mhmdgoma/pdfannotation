//
//  ViewController.swift
//  PDFAnnotation
//
//  Created by Mohammed Gomaa on 6/2/20.
//  Copyright © 2020 Mohammed Gomaa. All rights reserved.
//

import PDFKit
import UIKit

class ViewController: UIViewController, PDFDocumentDelegate {
    var documentURL: URL?
    @IBOutlet var documentView: PDFView! {
        didSet {
            documentView.autoScales = true
            documentView.displayDirection = .vertical
            documentView.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    @IBOutlet weak var thumbnailView: PDFThumbnailView! {
        didSet {
            thumbnailView.pdfView = documentView
            thumbnailView.thumbnailSize = CGSize(width: 30, height: 80)
            thumbnailView.layoutMode = .vertical
        }
    }
    
    var signatureAnnotation: PDFAnnotation?
    var panAnnotationGesture: UIPanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    private func openDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(
            documentTypes: ["com.adobe.pdf"],
            in: .import
        )
        documentPicker.delegate = self
        present(documentPicker, animated: false)
    }
    
    var customGesture: PDFDrawingGestureRecognizer!
    
    private func updateDocumentUI() {
        guard let documentUrl = documentURL else { return }
        let document = PDFDocument(url: documentUrl)
        document!.delegate = self
        documentView.document = document
        if documentView.document == nil {
            return
        }
        documentView.goToLastPage(nil)
        customGesture = PDFDrawingGestureRecognizer(target: self, action: #selector(tap(_:)))
        customGesture.pdfView = documentView
        documentView.addGestureRecognizer(customGesture)
//        let pdfURL = NSURL(fileURLWithPath: documentUrl.absoluteString)
//        if let pdf:CGPDFDocument = CGPDFDocument(pdfURL as CFURL) { // Create a PDF Document
//            let _newURL = documentUrl.absoluteString
//            //"\(documentUrl.director)/\(self.selectedFile.name)"; // New URL to save editable PDF
//            let _url = NSURL(fileURLWithPath: _newURL)
//            var _mediaBox:CGRect = CGRect(x: 0, y: 0, width: 400, height: 500); // mediabox which will set the height and width of page
//            let _writeContext = CGContext(_url, mediaBox: &_mediaBox, nil) // get the context
//
//            //Run a loop to the number of pages you want
//            if let pageCount = documentView.document?.pageCount {
//                for i in 0..<pageCount
//                {
//
//                    if let _page = pdf.page(at: i) { // get the page number
//                        var _pageRect:CGRect = _page.getBoxRect(CGPDFBox.mediaBox) // get the page rect
//                        _writeContext!.beginPage(mediaBox: &_pageRect); // begin new page with given page rect
//                        _writeContext!.drawPDFPage(_page); // draw content in page
//                        _writeContext!.endPage(); // end the current page
//                    }
//                }
//            }
//        }
        addInkAnnotation()
    }
    func addInkAnnotation() {
        let rect = CGRect(x: 0, y: 0, width: 300.0, height: 60.0)
        let annotation = PDFAnnotation(bounds: rect, forType: .ink, withProperties: nil)
        annotation.backgroundColor = .red
        
        let pathRect = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
        let path = UIBezierPath(rect: pathRect)
        annotation.add(path)
        
        // Add annotation to the first page
        documentView.document?.page(at: 0)?.addAnnotation(annotation)
    }
    private let signatureWidthInPage: CGFloat = 124
    private let signatureHeightInPage: CGFloat = 38

    
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer ) {
        guard gestureRecognizer.state == .ended else { return }
        let signatureImage = #imageLiteral(resourceName: "signPlaceholder")
        let centerInView = gestureRecognizer.location(in: documentView)
        guard let page = documentView.page(for: centerInView, nearest: false) else { return }
        let centerInPage = documentView.convert(centerInView, to: page)
        let signatureSizeInPage = CGSize(width: signatureWidthInPage, height: signatureHeightInPage)
        let rectInPage = CGRect(origin: CGPoint(x: centerInPage.x - signatureSizeInPage.width / 2,
                                                y: centerInPage.y - signatureSizeInPage.height / 2),
                                size: signatureSizeInPage)
        let adjustedBounds = rectInPage.adjust(inside: page.bounds(for: .cropBox))
        
        let annotation = ImageAnnotation(image: signatureImage, bounds: adjustedBounds, properties: nil)
//        // OVER HERE 🙂
//        let path = UIBezierPath()
//        path.apply(CGAffineTransform(scaleX: 1.0, y: -1.0))
//        path.apply(CGAffineTransform(translationX: 0, y: adjustedBounds.size.height))
//        annotation.add(path)
//        let annotationPDFRect = annotation.bounds
//        documentView.convert(annotationPDFRect, to: page)
        page.addAnnotation(annotation)
        
     
        
        customGesture.currentAnnotation = annotation
        updateSignatureAnnotation(annotation)
    }
    
    private func updateSignatureAnnotation(_ newAnnotation: PDFAnnotation) {
        if let annotation = signatureAnnotation {
            annotation.page?.removeAnnotation(annotation)
        }
        signatureAnnotation = newAnnotation
    }
    
    @IBAction func addDcoument(_ sender: UIButton) {
        openDocumentPicker()
    }
    
    // 2. Return your custom PDFPage class
    /// - Tag: ClassForPage
    func classForPage() -> AnyClass {
        return WatermarkPage.self
    }

}

extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
        ) {
        guard let url = urls.first else { return }
        print("Document URL: \(url.absoluteString)")
        self.documentURL = url
        updateDocumentUI()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Canceled")
        dismiss(animated: true, completion: nil)
    }
}

class WatermarkPage: PDFPage {
    
    // 3. Override PDFPage custom draw
    /// - Tag: OverrideDraw
    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        
        // Draw original content
        super.draw(with: box, to: context)
        
        // Draw rotated overlay string
        UIGraphicsPushContext(context)
        context.saveGState()
        
        let pageBounds = self.bounds(for: box)
        context.translateBy(x: 0.0, y: pageBounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: CGFloat.pi / 4.0)
        
        let string: NSString = "XYXYXY"
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1),
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 64)
        ]
        
        string.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        
        context.restoreGState()
        UIGraphicsPopContext()
        
    }
}


