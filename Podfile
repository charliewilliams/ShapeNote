
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

use_frameworks!

pod 'Parse', :inhibit_warnings => true
pod 'ParseFacebookUtils', :inhibit_warnings => true
pod 'Bolts', :inhibit_warnings => true
pod 'Instructions', :inhibit_warnings => true
pod 'SwiftSpinner'
pod 'STTwitter', :inhibit_warnings => true
pod 'JFADoubleSlider'

post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
end
