//
//  ViewController.swift
//  SwiftWebViewProgress
//
//  Created by Daichi Ichihara on 2014/12/03.
//  Copyright (c) 2014 MokuMokuCloud. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, WebViewProgressDelegate {
    private var webView: UIWebView!
    private var progressView: WebViewProgressView!
    private var progressProxy: WebViewProgress!

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        webView = UIWebView(frame: self.view.bounds)
        self.view.addSubview(webView)
        
        progressProxy = WebViewProgress()
        webView.delegate = progressProxy
        progressProxy.webViewProxyDelegate = self
        progressProxy.progressDelegate = self
        
        let progressBarHeight: CGFloat = 2.0
        let navigationBarBounds = self.navigationController!.navigationBar.bounds
        let barFrame = CGRect(x: 0, y: navigationBarBounds.size.height - progressBarHeight, width: navigationBarBounds.width, height: progressBarHeight)
        progressView = WebViewProgressView(frame: barFrame)
        progressView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        
        loadApple()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.addSubview(progressView)
    }
    
    // MARK: Private Method
    fileprivate func loadApple() {
        let request = URLRequest(url: URL(string: "http://apple.com")!)
        webView.loadRequest(request)
    }
    
    // MARK: - WebViewProgressDelegate
    func webViewProgress(_ webViewProgress: WebViewProgress, updateProgress progress: Float) {
        progressView.setProgress(progress, animated: true)
    }
}

