
Pod::Spec.new do |s|
  s.name             = 'Matrioska'
  s.version          = '0.1.0-alpha1'
  s.summary          = '🎎 create your layout and define the content of your app in a simple way'

  s.description      = <<-DESC
The vision of Matrioska is to let you build and prototype your app easily, reusing views and layouts as well as dynamically define the content of your app. With Matrioska you can go as far as specifing the content and layout of your views from an external source (e.g. JSON). With this power you can easily change the structure of your app, do A/B testing, staged rollout or prototype.
                       DESC

  s.homepage         = 'https://github.com/runtastic/Matrioska'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alex Manzella' => 'manzopower@icloud.com' }
  s.source           = { :git => 'https://github.com/runtastic/Matrioska.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'Source/**/*'
  s.dependency 'SnapKit', '~> 3.0'
end
