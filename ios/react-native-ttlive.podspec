require 'json'

package = JSON.parse(File.read(File.join(__dir__, '../package.json')))

Pod::Spec.new do |s|
  s.name           = 'react-native-ijkplayer'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.source         = { :git => 'https://github.me.yiii/react-native-ijkplayer', :tag => s.version }

  s.requires_arc   = true
  s.platform       = :ios, '8.0'

  s.preserve_paths = 'LICENSE', 'README.md', 'package.json', 'index.js'
  s.source_files   = '**/*.{h,m}'
  s.resource     = 'libIJKPlayerSDK/libIJKPlayerSDK/LiveSDKResource.bundle'
  s.vendored_libraries  = 'libIJKPlayerSDK/libIJKPlayerSDK/libIJKPlayerSDK.a'
  s.frameworks = "AVFoundation", "CoreMedia", 'VideoToolbox', 'Accelerate', 'AudioToolbox', 'Foundation','GLKit'
  s.libraries = 'c++'
  s.dependency 'React'
  # s.dependency 'IJKPlayerSDK'
end
