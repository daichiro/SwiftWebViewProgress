# SwiftWebViewProgress
[![Version](https://img.shields.io/cocoapods/v/SwiftWebViewProgress.svg?style=flat)](http://cocoapods.org/pods/SwiftWebViewProgress)
[![License](https://img.shields.io/cocoapods/l/SwiftWebViewProgress.svg?style=flat)](http://cocoapods.org/pods/SwiftWebViewProgress)
[![Platform](https://img.shields.io/cocoapods/p/SwiftWebViewProgress.svg?style=flat)](http://cocoapods.org/pods/SwiftWebViewProgress)

_This is WIP Project._

SwiftWebViewProgress is a progress interface library for UIWebView.

This is nearly porting NJKWebViewProgress to Swift.
- see: https://github.com/ninjinkun/NJKWebViewProgress

## Requirements
- iOS8 or later
- Xcode8 or later (Swift 3.0)

## Install
Via CocoaPods:
- Add `pod SwiftWebViewProgress` to your Podfile
- run `pod install` on command-line
 
Or:

- import `SwiftWebViewProgress.swift` in your Project.
- (Optionally, import `SwiftWebViewProgressView.swift`

## Usage
```
progressProxy = WebViewProgress()
webView.delegate = progressProxy
progressProxy.webViewProxyDelegate = self
progressProxy.progressDelegate = self
```

After loading webView, `WebViewProgress` call delegate method.

```
func webViewProgress(webViewProgress: WebViewProgress, updateProgress progress: Float) {
    progressView.setProgress(progress, animated: true)
}
```

## License
MIT license.
