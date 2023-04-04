# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'CyberMe' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CyberMe
  flutter_application_path = '../cyberme_flutter'
  load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')
  install_all_flutter_pods(flutter_application_path)
  
  target 'CyberMeTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'CyberMeWidgetExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CyberMeWidgetExtension

end

post_install do |installer|
  flutter_post_install(installer) if defined?(flutter_post_install)
end
