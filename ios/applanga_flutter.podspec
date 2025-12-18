#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint applanga_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'applanga_flutter'
  s.version          = '3.0.61'
  s.summary          = 'Enables over-the-air translations for Android and iOS.'
  s.description      = <<-DESC
With ApplangaFlutter you can get all your translations over the air. It's also
  suitable to update and download your newest translations from and to the flutter project via
  the command line.
                       DESC
  s.homepage         = 'https://github.com/applanga/applanga_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Applanga' => 'developer@applanga.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Applanga', '2.0.218'

  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
