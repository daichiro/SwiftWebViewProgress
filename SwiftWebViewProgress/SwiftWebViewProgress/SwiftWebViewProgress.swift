//
//  SwiftWebViewProgress.swift
//  SwiftWebViewProgress
//
//  Created by Daichi Ichihara on 2014/12/03.
//  Copyright (c) 2014 MokuMokuCloud. All rights reserved.
//

import UIKit

protocol WebViewProgressDelegate {
    func webViewProgress(webViewProgress: WebViewProgress, updateProgress progress: Float)
}

class WebViewProgress: NSObject, UIWebViewDelegate {
    
    var progressDelegate: WebViewProgressDelegate?
    var webViewProxyDelegate: UIWebViewDelegate?
    var progress: Float = 0.0
    
    private var loadingCount: Int!
    private var maxLoadCount: Int!
    private var currentUrl: NSURL?
    private var interactive: Bool!
    
    private let InitialProgressValue: Float = 0.1
    private let InteractiveProgressValue: Float = 0.5
    private let FinalProgressValue: Float = 0.9
    private let completePRCURLPath = "/webviewprogressproxy/complete"
    
    // MARK: Initializer
    override init() {
        super.init()
        maxLoadCount = 0
        loadingCount = 0
        interactive = false
    }
    
    // MARK: Private Method
    private func startProgress() {
        if progress < InitialProgressValue {
            setProgress(InitialProgressValue)
        }
    }
    
    private func incrementProgress() {
        var progress = self.progress
        var maxProgress = interactive == true ? FinalProgressValue : InteractiveProgressValue
        
        let remainPercent = Float(loadingCount / maxLoadCount)
        let increment = (maxProgress - progress) / remainPercent
        progress += increment
        progress = fmin(progress, maxProgress)
        setProgress(progress)
    }
    
    private func completeProgress() {
        setProgress(1.0)
    }
    
    private func setProgress(progress: Float) {
        if progress > self.progress || progress == 0 {
            self.progress = progress
            progressDelegate?.webViewProgress(self, updateProgress: progress)
        }
    }
    
    // MARK: Public Method
    func reset() {
        maxLoadCount = 0
        loadingCount = 0
        interactive = false
        setProgress(0.0)
    }
    
    // MARK: - UIWebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.URL.path == completePRCURLPath {
            completeProgress()
            return false
        }
        
        var ret = true
        if webViewProxyDelegate!.respondsToSelector("webView:shouldStartLoadWithRequest:navigationType:") {
            ret = webViewProxyDelegate!.webView!(webView, shouldStartLoadWithRequest: request, navigationType: navigationType)
        }
        
        var isFragmentJump = false
        if let fragmentURL = request.URL.fragment {
            let nonFragmentURL = request.URL.absoluteString?.stringByReplacingOccurrencesOfString("#"+fragmentURL, withString: "")
            isFragmentJump = nonFragmentURL == webView.request!.URL.absoluteString
        }
        
        var isTopLevelNavigation = request.mainDocumentURL! == request.URL
        var isHTTP = request.URL.scheme == "http" || request.URL.scheme == "https"
        if ret && !isFragmentJump && isHTTP && isTopLevelNavigation {
            currentUrl = request.URL
            reset()
        }
        return ret
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        if webViewProxyDelegate!.respondsToSelector("webViewDidStartLoad:") {
            webViewProxyDelegate!.webViewDidStartLoad!(webView)
        }
        
        loadingCount = loadingCount + 1
        maxLoadCount = Int(fmax(Double(maxLoadCount), Double(loadingCount)))
        startProgress()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if webViewProxyDelegate!.respondsToSelector("webViewDidFinishLoad:") {
            webViewProxyDelegate!.webViewDidFinishLoad!(webView)
        }
        
        loadingCount = loadingCount - 1
        // incrementProgress()
        
        let readyState = webView.stringByEvaluatingJavaScriptFromString("document.readyState")
        
        var interactive = readyState == "interactive"
        if interactive {
            self.interactive = true
            let waitForCompleteJS = "window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '\(webView.request?.mainDocumentURL?.scheme)://\(webView.request?.mainDocumentURL?.host)\(completePRCURLPath)'; document.body.appendChild(iframe);  }, false);"
            webView.stringByEvaluatingJavaScriptFromString(waitForCompleteJS)
        }
        
        var isNotRedirect: Bool
        if let _currentUrl = currentUrl {
            if _currentUrl == webView.request?.mainDocumentURL {
                isNotRedirect = true
            } else {
                isNotRedirect = false
            }
        } else {
            isNotRedirect = false
        }
        
        var complete = readyState == "complete"
        if complete && isNotRedirect {
            completeProgress()
        }
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        if webViewProxyDelegate!.respondsToSelector("webView:didFailLoadWithError:") {
            webViewProxyDelegate!.webView!(webView, didFailLoadWithError: error)
        }
        
        loadingCount = loadingCount - 1
        // incrementProgress()
        
        let readyState = webView.stringByEvaluatingJavaScriptFromString("document.readyState")
        
        var interactive = readyState == "interactive"
        if interactive {
            self.interactive = true
            let waitForCompleteJS = "window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '\(webView.request?.mainDocumentURL?.scheme)://\(webView.request?.mainDocumentURL?.host)\(completePRCURLPath)'; document.body.appendChild(iframe);  }, false);"
            webView.stringByEvaluatingJavaScriptFromString(waitForCompleteJS)
        }
        
        var isNotRedirect: Bool
        if let _currentUrl = currentUrl {
            if _currentUrl == webView.request?.mainDocumentURL {
                isNotRedirect = true
            } else {
                isNotRedirect = false
            }
        } else {
            isNotRedirect = false
        }
        
        var complete = readyState == "complete"
        if complete && isNotRedirect {
            completeProgress()
        }
    }
}
