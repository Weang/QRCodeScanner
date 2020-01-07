//
//  QRCodeParser.swift
//  QRCodeScanner_Example
//
//  Created by Mr.Wang on 2020/1/7.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

public class QRCodeParser {
    
    public class func parserQRCodeFrom(image: UIImage) -> [String?] {
        guard let ciImage = CIImage(image:image),
            let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: CIContext(options: nil), options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else {
                return []
        }
        let features = detector.features(in: ciImage) as? [CIQRCodeFeature] ?? []
        return features.map{ $0.messageString }
    }
}
