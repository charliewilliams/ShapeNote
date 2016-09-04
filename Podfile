
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

use_frameworks!
# inhibit_all_warnings!

target 'ShapeNote' do
pod 'Parse'
pod 'ParseFacebookUtils'
pod 'Bolts'
pod 'Instructions'
pod 'SwiftSpinner'
pod 'STTwitter'
pod 'JFADoubleSlider'

end

post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
end
