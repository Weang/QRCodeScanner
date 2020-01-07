//
//  QRCodeScannerController.swift
//  QRCodeScanner_Example
//
//  Created by Mr.Wang on 2020/1/7.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

public class QRCodeScannerController: UIViewController {
    
    let flashButton = UIButton()
    var scanUnit: QRCodeScannerUnit?
    
    var scanRect: CGRect {
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let scanWidth = screenWidth * 0.65
        return CGRect(x: (screenWidth - scanWidth) * 0.5, y: (screenHeight - scanWidth) * 0.5, width: scanWidth, height: scanWidth)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        scanUnit = QRCodeScannerUnit.init(delegate: self)
        scanUnit?.showPreviewOn(self.view)
        scanUnit?.scanRect = scanRect
        scanUnit?.startRunning()
        
        self.view.backgroundColor = .black
        
        flashButton.isHidden = true
        flashButton.setImage(UIImage.init(named: "flash_close"), for: .normal)
        flashButton.setImage(UIImage.init(named: "flash_open"), for: .selected)
        flashButton.addTarget(self, action: #selector(flushButtonClick), for: .touchUpInside)
        flashButton.showsTouchWhenHighlighted = false
        flashButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(flashButton)
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: flashButton, attribute: .centerX, relatedBy: .equal,
                                    toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: flashButton, attribute: .bottom, relatedBy: .equal,
                                    toItem: view, attribute: .bottom, multiplier: 1, constant: -70),
            NSLayoutConstraint.init(item: flashButton, attribute: .width, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40),
            NSLayoutConstraint.init(item: flashButton, attribute: .height, relatedBy: .equal,
                                    toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40)
        ])
        
        drawPath()
    }
    
    func drawPath() {
        let fillPath = UIBezierPath(roundedRect: self.view.bounds, cornerRadius: 0)
        let circlePath = UIBezierPath(roundedRect: scanRect, cornerRadius: 0)
        fillPath.append(circlePath)
        fillPath.usesEvenOddFillRule = true

        let fillLayer = CAShapeLayer()
        fillLayer.path = fillPath.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.4
        self.view.layer.addSublayer(fillLayer)
        
        let linePath = UIBezierPath(roundedRect: scanRect, cornerRadius: 0)
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.lineWidth = 0.5
        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.opacity = 1
        self.view.layer.addSublayer(lineLayer)
    }
    
    @objc func flushButtonClick() {
        scanUnit?.changeFlashStatus()
    }
}

extension QRCodeScannerController: QRCodeScannerUnitDelegate {
    
    public func scannerUnit(_ scannerUnit: QRCodeScannerUnit, didAccessTo code: String) {
        
    }
    
    public func scannerUnit(_ scannerUnit: QRCodeScannerUnit, brightnessChanged brightness: Double) {
        flashButton.isHidden = !(brightness < -1 || (self.scanUnit?.isFlashOn ?? true))
    }
    
    public func scannerUnit(_ scannerUnit: QRCodeScannerUnit, torchModeChanged torchMode: AVCaptureDevice.TorchMode) {
        flashButton.isSelected = torchMode == .on
    }
    
}
