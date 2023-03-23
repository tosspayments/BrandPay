Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #

  s.name         = "BrandPay"
  s.version      = `cat version`
  s.summary      = "BrandPay SDK from TossPayments"

  s.description  = <<-DESC
                   BrandPay SDK from TossPayments

                   You can install Pay module easily.
                   DESC

  s.homepage     = "https://www.tosspayments.com"
  s.license      = { :type => 'Proprietary', :text => 'Copyright 2023 TossPayments Ltd. All rights reserved.' }
  s.author       = { "Jinkyu Kim" => "mqz@toss.im" }
  s.platform     = :ios
  s.ios.deployment_target = '11.0'
  s.source       = { :git => "https://github.com/tosspayments/BrandPay.git", :tag => s.version.to_s }

  # s.ios.frameworks = 'UIKit'
  
  # s.ios.preserve_paths = [
  #   'Library/*.xcframework'
  # ]
  # s.ios.vendored_frameworks = [
  #   'Library/*.xcframework'
  # ]

  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.ios.preserve_paths = [
      'Library/BrandPayBase.xcframework'
    ]
    ss.ios.vendored_frameworks = [
      'Library/BrandPayBase.xcframework'
    ]
  end

  s.subspec 'Biometric' do |ss|
    ss.ios.preserve_paths = [
      'Library/BiometricInterface.xcframework'
    ]
    ss.ios.vendored_frameworks = [
      'Library/BiometricInterface.xcframework'
    ]

    ss.dependency 'BrandPay/Core'
  end

  s.subspec 'OCR' do |ss|
    ss.ios.preserve_paths = [
      'Library/FinCubeOcrSDK.xcframework',
      'Library/OCRInterface.xcframework'
    ]
    ss.ios.vendored_frameworks = [
      'Library/FinCubeOcrSDK.xcframework',
      'Library/OCRInterface.xcframework'
    ]
    
    ss.dependency 'BrandPay/Core'
  end
end
