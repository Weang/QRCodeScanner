//
//  QRCodeGenerator.swift
//  QRCodeScanner_Example
//
//  Created by Mr.Wang on 2020/1/7.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import CoreImage

public enum QRCodeCorrectionLevel: String {
    case low = "L"
    case medium = "M"
    case quailty = "Q"
    case higher = "H"
}

public enum LogoBorderType {
    case none
    case round
    case cornerRadius(CGFloat)
}

public class QRCodeGenerator {
    
    let stringValue: String
    var color: UIColor?
    public var correctionLevel: QRCodeCorrectionLevel = .higher
    public var foregroundColor = UIColor.black.cgColor
    public var exportSize: CGFloat = 400
    
    public var logo: UIImage?
    public var logoSize: CGFloat = 80
    public var logoBorderWidth: CGFloat = 20
    public var logoBorderColor = UIColor.white
    
    public init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    public func exportQrCodeImage() -> UIImage? {
        guard let data = stringValue.data(using: .utf8),
            let filter = CIFilter(name: "CIQRCodeGenerator") else {
                return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(correctionLevel.rawValue, forKey: "inputCorrectionLevel")
        
        guard let outPutImage = filter.outputImage else {
            return nil
        }
         
        let parameters = ["inputImage": outPutImage,
                          "inputColor0": CIColor(cgColor: foregroundColor),
                          "inputColor1": CIColor(cgColor: UIColor.clear.cgColor)]
        let colorFilter = CIFilter(name: "CIFalseColor", parameters: parameters)
        
        guard let newOutPutImage = colorFilter?.outputImage else {
            return nil
        }
        
        let scale = exportSize / newOutPutImage.extent.width
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let output = newOutPutImage.transformed(by: transform)
        let QRCodeImage = UIImage(ciImage: output)
        
        guard let logo = drawLogoImage() else {
            return QRCodeImage
        }
        
        UIGraphicsGetCurrentContext()
        
        let logoSize = self.logoSize + self.logoBorderWidth * 2
        
        let imageSize = QRCodeImage.size
        UIGraphicsBeginImageContext(imageSize)
        QRCodeImage.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let fillRect = CGRect(x: (exportSize - logoSize) * 0.5,
                              y: (exportSize - logoSize) * 0.5,
                              width: logoSize,
                              height: logoSize)
        logo.draw(in: fillRect)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return QRCodeImage }
        UIGraphicsEndImageContext()
        return newImage
    }
    
    public func drawLogoImage() -> UIImage? {
        guard let logo = logo else { return nil }
        let imageSize = self.logoSize + self.logoBorderWidth * 2
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageSize, height: imageSize), false, 0.0)
        UIGraphicsGetCurrentContext()
        
        let bezierPath = UIBezierPath.init(roundedRect: CGRect(x: 0, y: 0, width: imageSize, height: imageSize), cornerRadius: 0)
        logoBorderColor.setFill()
        bezierPath.fill()
        logo.draw(in: CGRect(x: logoBorderWidth, y: logoBorderWidth, width: logoSize, height: logoSize))
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }
}
