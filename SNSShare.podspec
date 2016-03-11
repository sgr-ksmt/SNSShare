Pod::Spec.new do |s|

  s.name         = "SNSShare"
  s.version      = "1.0.0"
  s.summary      = "Text/Image/URL share to Twitter/Facebook/LINE from App in Swift."
  s.homepage = "https://github.com/sgr-ksmt/SNSShare"

  s.license = "MIT"

  s.author = "Suguru Kishimoto"

  s.platform = :ios, "8.0"
  s.ios.deployment_target = "8.0"

  s.source = { :git => "https://github.com/sgr-ksmt/SNSShare.git", :tag => s.version.to_s }


  s.source_files  = "SNSShare/**/*.swift"

  s.requires_arc = true

end
