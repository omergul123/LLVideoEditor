Pod::Spec.new do |s|
  s.name         = "LLVideoEditor"
  s.version      = "1.0.0"
  s.summary      = "An easy to use library for editing videos"
  s.description  = <<-DESC
                   LLVideoEditor is a library for rotating, cropping, adding layers (watermark) and as well as adding audio (music) to the videos.
                   DESC

  s.homepage     = "https://github.com/omergul123/LLVideoEditor"
  s.license      = { :type => 'APACHE', :file => 'LICENSE' }
  s.author       = { "Ömer Faruk Gül" => "omer@omerfarukgul.com" }
  s.platform     = :ios,'7.0'
  s.source       = { :git => "https://github.com/omergul123/LLVideoEditor.git", :tag => "v1.0.0" }
  s.source_files = 'LLVideoEditor/**/*.{h,m}'
  s.requires_arc = true
  s.framework = 'AVFoundation'
end
