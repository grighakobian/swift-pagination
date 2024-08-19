
Pod::Spec.new do |s|
  s.name             = 'Pagination'
  s.version          = '0.1.0'
  s.summary          = 'An elegant pagination framework written in Swift.'
  s.homepage         = 'https://github.com/grighakobian/Paginator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Grigor Hakobyan' => 'grighakobian@gmail.com' }
  s.source           = { :git => 'https://github.com/grighakobian/Paginator.git', :tag => s.version.to_s }
  
  s.swift_version = '5.0'
  s.ios.deployment_target = '12.0'
  s.source_files = 'Sources/Paginator'
  
end
