Pod::Spec.new do |s|
  s.name         = 'CFFoundation'
  s.version      = '1.0.0'
  s.license      =  { :type => 'MIT' }
  s.homepage     = 'https://github.com/robss88/CFFoundation-iOS'
  s.authors      = {
    'Robert Avellar' => 'robertavellar@gmail.com'
  }
  s.summary      = 'CFFoundation for iOS'

# Source Info
  s.source       =  {
    :git => 'https://github.com/robss88/CFFoundation-iOS.git',
    :tag => s.version
  }
  s.source_files = 'Classes/**/*.swift'

  s.ios.deployment_target = '10.0'
  s.ios.dependency 'Socket.IO-Client-Swift'
  s.ios.dependency 'Alamofire', '~> 5.0.0-beta.5'

  s.requires_arc = true
end