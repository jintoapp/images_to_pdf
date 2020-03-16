import Flutter
import UIKit
import PDFKit

public class SwiftImagesToPdfPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "images_to_pdf", binaryMessenger: registrar.messenger())
    let instance = SwiftImagesToPdfPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    if (call.method == "createPdf") {
        let arguments = call.arguments as! [Any?]
        let pages = arguments[0] as! [NSDictionary];
        let output = arguments[1] as! String;
        
          // Create an empty PDF document
        if #available(iOS 11.0, *) {
            print("Starting PDF generation")
            let pdfDocument = PDFDocument()
            
            for (index, page) in pages.enumerated() {
                let path = page["path"] as! String
                let size = page["size"] as! [Double]?;
                let compressionQuality = page["compressionQuality"] as! Double?;
               
                print("Adding page from image at path '\(path)' to index \(index) in document")
                var image = UIImage(contentsOfFile: path)!
                
                if let size = size {
                    let width = CGFloat(size[0])
                    let height = CGFloat(size[1])
                    print("Resizing image at size \(width)*\(height)")
                    
                    let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
                    imageView.contentMode = .scaleAspectFill
                   imageView.image = image
                    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, image.scale)
                   let context = UIGraphicsGetCurrentContext()
                   imageView.layer.render(in:context!)
                   image = UIGraphicsGetImageFromCurrentImageContext()!
                   UIGraphicsEndImageContext()
                }
                
                if let compressionQuality = compressionQuality {
                    let quality = CGFloat(compressionQuality)
                    print("Compressing image with \(quality) quality")
                    let jpeg = image.jpegData(compressionQuality: quality)!;
                    image = UIImage(data: jpeg)!;
                }
                let pdfPage = PDFPage(image: image)
                
                
                pdfDocument.insert(pdfPage!, at: index)
            }
            
            print("Saving PDF file to '\(output)'")
            let data = pdfDocument.dataRepresentation()
            let url = URL(fileURLWithPath: output)
            try! data!.write(to: url)
            result(true);
        } else {
            result(false);
        }
    }

    
  }
}
