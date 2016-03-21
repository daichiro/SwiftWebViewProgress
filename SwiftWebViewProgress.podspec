Pod::Spec.new do |s|
  s.name         = "SwiftWebViewProgress"
  s.version      = "0.1.0"
  s.summary      = "UIWebView progress interface library for Swift"
  s.description  = <<-DESC
This is WIP Project.

SwiftWebViewProgress is a progress interface library for UIWebView.

This is nearly porting NJKWebViewProgress to Swift.
                   DESC

  s.homepage     = "https://github.com/mokumoku/SwiftWebViewProgress"
  s.license      = "MIT"
  s.author       = { "mokumoku" => "da1lawmoku2@gmail.com" }
  s.source       = { :git => "https://github.com/mokumoku/SwiftWebViewProgress.git", :tag => s.version.to_s }
  s.source_files  = "SwiftWebViewProgress/SwiftWebViewProgress/**/*.swift"

  s.ios.deployment_target = '8.0'
end
