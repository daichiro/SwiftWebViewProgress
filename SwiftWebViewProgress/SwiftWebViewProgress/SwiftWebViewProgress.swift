//
//  SwiftWebViewProgress.swift
//  SwiftWebViewProgress
//
//  Created by Daichi Ichihara on 2014/12/03.
//  Copyright (c) 2014 MokuMokuCloud. All rights reserved.
//

import UIKit

public protocol WebViewProgressDelegate {
    func webViewProgress(webViewProgress: WebViewProgress, updateProgress progress: Float)
}

public class WebViewProgress: NSObject {
    
    public var progressDelegate: WebViewProgressDelegate?
    public var webViewProxyDelegate: UIWebViewDelegate?
    public var progress: Float = 0.0
    
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
        let maxProgress = interactive == true ? FinalProgressValue : InteractiveProgressValue
        let remainPercent = Float(Float(loadingCount) / Float(maxLoadCount))
        let increment = (maxProgress - progress) * remainPercent
        progress += increment
        progress = fmin(progress, maxProgress)
        setProgress(progress)
    }
    
    private func completeProgress() {
        setProgress(1.0)
    }
    
    private func setProgress(progress: Float) {
        guard progress > self.progress || progress == 0 else {
            return
        }
        self.progress = progress
        progressDelegate?.webViewProgress(self, updateProgress: progress)
    }
    
    // MARK: Public Method
    public func reset() {
        maxLoadCount = 0
        loadingCount = 0
        interactive = false
        setProgress(0.0)
    }
    
}

extension WebViewProgress: UIWebViewDelegate {
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.URL else {
            return false
        }
        if url.path == completePRCURLPath {
            completeProgress()
            return false
        }
        
        var ret = true
        if webViewProxyDelegate!.respondsToSelector("webView:shouldStartLoadWithRequest:navigationType:") {
            ret = webViewProxyDelegate!.webView!(webView, shouldStartLoadWithRequest: request, navigationType: navigationType)
        }
        
        var isFragmentJump = false
        if let fragmentURL = url.fragment {
            let nonFragmentURL = url.absoluteString.stringByReplacingOccurrencesOfString("#"+fragmentURL, withString: "")
            isFragmentJump = nonFragmentURL == webView.request!.URL!.absoluteString
        }
        
        let isTopLevelNavigation = request.mainDocumentURL! == request.URL
        let isHTTP = url.scheme == "http" || url.scheme == "https"
        if ret && !isFragmentJump && isHTTP && isTopLevelNavigation {
            currentUrl = request.URL
            reset()
        }
        return ret
    }
    
    public func webViewDidStartLoad(webView: UIWebView) {
        if webViewProxyDelegate!.respondsToSelector("webViewDidStartLoad:") {
            webViewProxyDelegate!.webViewDidStartLoad!(webView)
        }
        
        loadingCount = loadingCount + 1
        maxLoadCount = Int(fmax(Double(maxLoadCount), Double(loadingCount)))
        startProgress()
    }
    
    public func webViewDidFinishLoad(webView: UIWebView) {
        if webViewProxyDelegate!.respondsToSelector("webViewDidFinishLoad:") {
            webViewProxyDelegate!.webViewDidFinishLoad!(webView)
        }
        
        loadingCount = loadingCount - 1
        incrementProgress()
        
        let readyState = webView.stringByEvaluatingJavaScriptFromString("document.readyState")
        
        let interactive = readyState == "interactive"
        if interactive {
            self.interactive = true
            let waitForCompleteJS = "window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '\(webView.request?.mainDocumentURL?.scheme)://\(webView.request?.mainDocumentURL?.host)\(completePRCURLPath)'; document.body.appendChild(iframe);  }, false);"
            webView.stringByEvaluatingJavaScriptFromString(waitForCompleteJS)
        }
        
        let isNotRedirect: Bool
        if let currentUrl = currentUrl {
            isNotRedirect = currentUrl == webView.request?.mainDocumentURL
        } else {
            isNotRedirect = false
        }
        
        let complete = readyState == "complete"
        if complete && isNotRedirect {
            completeProgress()
        }
    }
    
    public func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if webViewProxyDelegate!.respondsToSelector("webView:didFailLoadWithError:") {
            webViewProxyDelegate!.webView!(webView, didFailLoadWithError: error)
        }
        
        loadingCount = loadingCount - 1
        incrementProgress()
        
        let readyState = webView.stringByEvaluatingJavaScriptFromString("document.readyState")
        
        let interactive = readyState == "interactive"
        if interactive {
            self.interactive = true
            let waitForCompleteJS = "window.addEventListener('load',function() { var iframe = document.createElement('iframe'); iframe.style.display = 'none'; iframe.src = '\(webView.request?.mainDocumentURL?.scheme)://\(webView.request?.mainDocumentURL?.host)\(completePRCURLPath)'; document.body.appendChild(iframe);  }, false);"
            webView.stringByEvaluatingJavaScriptFromString(waitForCompleteJS)
        }
        
        let isNotRedirect: Bool
        if let currentUrl = currentUrl {
            isNotRedirect = currentUrl == webView.request?.mainDocumentURL
        } else {
            isNotRedirect = false
        }
        
        let complete = readyState == "complete"
        if complete && isNotRedirect {
            completeProgress()
        }
    }
}
