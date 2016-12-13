
Pod::Spec.new do |s|
  s.name             = 'Matrioska'
  s.version          = '0.1.0'
  s.summary          = 'Dynamically build UI like if you were playing with dolls 🎎'

  s.description      = <<-DESC
Dynamically build UI like if you were playing with dolls 🎎
                       DESC

  s.homepage         = 'https://github.com/runtastic/Matrioska'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alex Manzella' => 'alex.manzella@runtastic.com' }
  s.source           = { :git => 'https://github.com/runtastic/Matrioska.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Source/**/*'
  s.dependency 'SnapKit', '~> 3.0'
end
