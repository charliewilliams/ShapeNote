
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

use_frameworks!
# inhibit_all_warnings!

target 'ShapeNote' do
    
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'TwitterKit'
    # pod 'Instructions', :git => 'git@github.com:ephread/Instructions.git', :branch => 'swift3'
    # pod 'SwiftSpinner'
#    pod 'STTwitter'
    pod 'JFADoubleSlider'
    # pod 'MMDB-Swift', :git => 'git@github.com:charliewilliams/MMDB-Swift.git', :commit => '97f99ca3a12b44b802dffc355786d79020d87c7b'

end

target 'ShapeNoteTests' do
   
   inherit! :search_paths
end

post_install do |installer|
    installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
        configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
    end
end
