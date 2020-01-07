
Pod::Spec.new do |s|
  s.name             = 'QRCodeScanner'
  s.version          = '1.0.0'
  s.summary          = 'A short description of QRCodeScanner.'

  s.homepage         = 'https://github.com/Weang/QRCodeScanner'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'w704444178@qq.com' => 'w704444178@qq.com' }
  s.source           = { :git => 'https://github.com/Weang/QRCodeScanner.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '8.0'
  s.swift_versions = "5.0"
  s.source_files = 'QRCodeScanner/Classes/**/*'
  s.frameworks = 'AVFoundation'
end
