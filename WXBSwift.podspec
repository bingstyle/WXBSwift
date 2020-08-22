#
#  Be sure to run `pod spec lint WXBSwift.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "WXBSwift"
  spec.version      = "1.0.1"
  spec.swift_version = '5.0'
  spec.summary      = "A set of useful extensions and tools for Swift"

  spec.homepage     = "https://github.com/bingstyle/WXBSwift"


  spec.license      = { :type => "MIT", :file => "./LICENSE" }
  spec.author             = { "WeiXinbing" => "183292352@qq.com" }
  spec.social_media_url = 'http://weixinbing.top/'
  
  spec.source       = { :git => "https://github.com/bingstyle/WXBSwift.git", :tag => "#{spec.version}" }
  spec.ios.deployment_target = '13.0'

  #spec.source_files  = "Classes", "Classes/**/*.{h,m}"

  spec.subspec 'Extensions' do |ss|
    #ss.source_files = 'Sources/Extensions/*.swift'
    
    ss.subspec 'CoreGraphics' do |sss|
        sss.source_files = 'Sources/Extensions/CoreGraphics/*.swift'
    end
    ss.subspec 'Foundation' do |sss|
        sss.source_files = 'Sources/Extensions/Foundation/*.swift'
    end
    ss.subspec 'Shared' do |sss|
        sss.source_files = 'Sources/Extensions/Shared/*.swift'
    end
    ss.subspec 'SwiftStdlib' do |sss|
        sss.source_files = 'Sources/Extensions/SwiftStdlib/*.swift'
    end
    ss.subspec 'UIKit' do |sss|
        sss.source_files = 'Sources/Extensions/UIKit/*.swift'
    end
  end

  spec.subspec 'Tools' do |ss|
    ss.source_files = 'Sources/Tools/*.swift'
  end
  

end
