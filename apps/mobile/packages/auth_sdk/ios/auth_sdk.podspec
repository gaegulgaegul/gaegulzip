Pod::Spec.new do |s|
  s.name             = 'auth_sdk'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for auth_sdk iOS integration'
  s.homepage         = 'https://github.com/gaegulgaegul/gaegulzip'
  s.license          = { :type => 'MIT' }
  s.author           = { 'gaegulzip' => 'dev@gaegulzip.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.0'

  s.dependency 'Flutter'
  s.dependency 'NidThirdPartyLogin', '~> 5.0.0'
end
