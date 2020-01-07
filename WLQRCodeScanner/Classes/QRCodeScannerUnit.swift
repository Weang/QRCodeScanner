//
//  QRCodeScannerUnit.swift
//  QRCodeScanner_Example
//
//  Created by Mr.Wang on 2020/1/7.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

public protocol QRCodeScannerUnitDelegate: class {
    
    func scannerUnit(_ scannerUnit: QRCodeScannerUnit, didAccessTo code: String)
    func scannerUnit(_ scannerUnit: QRCodeScannerUnit, brightnessChanged brightness: Double)
    func scannerUnit(_ scannerUnit: QRCodeScannerUnit, torchModeChanged torchMode: AVCaptureDevice.TorchMode)
    
}

open class QRCodeScannerUnit: NSObject {

    private let session = AVCaptureSession()
    private var device: AVCaptureDevice?
    private var preViewLayer: AVCaptureVideoPreviewLayer?

    private let videoDataOut = AVCaptureVideoDataOutput()
    private let metadataOutput = AVCaptureMetadataOutput()
    
    public weak var delegate: QRCodeScannerUnitDelegate?
    
    public var scanRect: CGRect = .zero
    
    public var isFlashOn: Bool {
        guard let device = device else { return false }
        return device.torchMode == .on
    }
    
    public init(delegate: QRCodeScannerUnitDelegate? = nil) {
        super.init()
        
        self.delegate = delegate
        
        guard let device = AVCaptureDevice.devices(for: .video).first else {
            return
        }
        
        self.device = device
        
        if let input = try? AVCaptureDeviceInput.init(device: device) ,
            session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canSetSessionPreset(.high) {
            session.canSetSessionPreset(.high)
        }
        
        videoDataOut.setSampleBufferDelegate(self, queue: DispatchQueue.init(label: "videoDataOut"))
        if session.canAddOutput(videoDataOut) {
            session.addOutput(videoDataOut)
        }
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.init(label: "outputQueue"))
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
        }
        metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        preViewLayer = AVCaptureVideoPreviewLayer.init(session: session)
        preViewLayer?.videoGravity = .resizeAspectFill
        
        try? device.lockForConfiguration()
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        
        if device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
        }
        device.unlockForConfiguration()
        
        device.addObserver(self, forKeyPath: "torchMode", options: .new, context: nil)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "torchMode",
            let device = self.device else {
                return
        }
        delegate?.scannerUnit(self, torchModeChanged: device.torchMode)
    }
    
    public func showPreviewOn(_ view: UIView) {
        guard let preViewLayer = preViewLayer else { return }
        preViewLayer.frame = view.bounds
        view.layer.insertSublayer(preViewLayer, at: 0)
        scanRect = view.bounds
    }
    
    public func startRunning() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [weak self] in
            guard let self = self,
                let preViewLayer = self.preViewLayer else { return }
            self.session.startRunning()
            self.metadataOutput.rectOfInterest = preViewLayer.metadataOutputRectConverted(fromLayerRect: self.scanRect)
        }
    }
    
    public func stopRunning() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { [weak self] in
            self?.session.stopRunning()
        }
    }
    
    public func changeFlashStatus() {
        guard let device = device else { return }
        
        try? device.lockForConfiguration()
        if device.torchMode == .on {
            device.torchMode = .off
        } else {
            device.torchMode = .on
        }
        device.unlockForConfiguration()
    }
    
    deinit {
        device?.removeObserver(self, forKeyPath: "torchMode", context: nil)
    }
    
}

extension QRCodeScannerUnit: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metatdataObject = metadataObjects.first,
            let readableObject = metatdataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue else { return }
        
//        self.session.stopRunning()
        DispatchQueue.main.async {
            self.delegate?.scannerUnit(self, didAccessTo: stringValue)
        }
        
    }
    
}

extension QRCodeScannerUnit: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let metadata = CMCopyDictionaryOfAttachments(allocator: nil,
                                                           target: sampleBuffer,
                                                           attachmentMode: kCMAttachmentMode_ShouldPropagate),
            let exifMetadata = (metadata as NSDictionary).object(forKey: kCGImagePropertyExifDictionary) as? NSDictionary,
            let brightnessValue = exifMetadata.object(forKey: kCGImagePropertyExifBrightnessValue) as? Double else {
                return
        }
        DispatchQueue.main.async {
            self.delegate?.scannerUnit(self, brightnessChanged: brightnessValue)
        }
    }
    
}
