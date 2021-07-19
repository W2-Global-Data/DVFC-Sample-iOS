# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

source 'https://github.com/W2-Global-Data/cocoapods-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

pre_install do |installer|
	installer.analysis_result.specifications.each do |s|
        if s.name == 'Alamofire'
            s.swift_version = '5.3'
        end
    end
end

target 'w2-example-ios' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for w2-example-ios
  w2sdk_version = "1.9.0"
  puts "Using version #@w2sdk_version of W2SDK from the feeds"
  pod 'W2SDK/W2DocumentVerificationClient', w2sdk_version
  pod 'W2SDK/W2DocumentVerificationClientCapture', w2sdk_version
  pod 'W2SDK/W2FacialComparisonClientCapture', w2sdk_version
  pod 'W2SDK/W2FacialComparisonClient', w2sdk_version

end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if ['AcuantiOSSDKV11', 'KeychainAccess', 'Socket.IO-Client-Swift', 'Starscream', 'SwiftyJSON'].include? target.name
        target.build_configurations.each do |config|
          config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        end
      end
      target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.3'
    end
  end
end