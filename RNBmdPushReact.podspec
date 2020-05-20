
Pod::Spec.new do |s|
  s.name         = "RNBmdPushReact"
  s.version      = "1.0.0"
  s.summary      = "RNBmdPushReact"
  s.description  = "RNBmdPushReact"
  s.homepage     = "https://github.com/ibm-bluemix-mobile-services/bms-push-react-native"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "agirijak@in.ibm.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/author/RNBmdPushReact.git", :tag => "master" }
  s.source_files  = "ios/*.{h,m,swift}"
  s.requires_arc = true
  s.xcconfig = {
    "HEADER_SEARCH_PATHS" => "${PODS_ROOT}/Headers/Public/React"
  }
  s.static_framework = true  

  s.dependency "React"
  #s.dependency "others"
  s.dependency 'BMSPush', '~> 3.6'
  s.swift_versions = "4.0"

end

  
