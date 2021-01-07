Pod::Spec.new do |s|
  s.name             = "RxExpect"
  s.version          = "2.0.0"
  s.summary          = "The RxSwift testing framework"
  s.homepage         = "https://github.com/devxoul/RxExpect"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Suyeol Jeon" => "devxoul@gmail.com" }
  s.source           = { :git => "https://github.com/devxoul/RxExpect.git",
                         :tag => s.version.to_s }
  s.source_files     = "Sources/**/*.swift"
  s.requires_arc     = true
  s.swift_version    = "5.0"
  s.frameworks       = "XCTest"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  
  s.dependency "RxSwift", "~> 6.0"
  s.dependency "RxCocoa", "~> 6.0"
  s.dependency "RxTest", "~> 6.0"
end
