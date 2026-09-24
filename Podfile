platform :ios, '15.0'
#use_frameworks!
source 'https://github.com/CocoaPods/Specs.git'

target 'PopulationClock' do
pod 'MBProgressHUD', '~> 1.2'
pod 'SBTickerView'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
