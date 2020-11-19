//
//  ViewController.swift
//  QRCodeScanner
//
//  Created by w704444178@qq.com on 01/07/2020.
//  Copyright (c) 2020 w704444178@qq.com. All rights reserved.
//

import UIKit
import AVFoundation
import WLQRCodeScanner

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let a = QRCodeGenerator.init(stringValue: "https://www.baidu.com")
        a.logo = UIImage.init(named: "1024iPhoneSpootlight5_29pt")
        let i = a.exportQrCodeImage()
        let imageview = UIImageView.init(frame: CGRect(x: 30, y: 30, width: 100, height: 100))
        self.view.addSubview(imageview)
        imageview.image = i
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

