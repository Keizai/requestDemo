# Podfile
platform :ios, '11.0'  # Adjust minimum iOS version as needed
use_frameworks!

target 'RequestDemo' do
  # Pods for YourAppTarget
  pod 'Adjust', '~> 4.38.4'
  pod 'CryptoSwift'
  
  # Uncomment the next line if you're using SwiftUI
  # pod 'CryptoSwift', :git => 'https://github.com/krzyzanowskim/CryptoSwift.git', :branch => 'master'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'  # Match platform version
      # For Swift 5 compatibility (if needed)
      config.build_settings['SWIFT_VERSION'] = '5.0'
    end
  end
end
